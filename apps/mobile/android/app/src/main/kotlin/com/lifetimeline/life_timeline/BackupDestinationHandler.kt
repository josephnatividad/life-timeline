package com.lifetimeline.life_timeline

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.security.MessageDigest

class BackupDestinationHandler(private val activity: Activity) {
    private companion object {
        const val BACKUP_CHANNEL = "life_timeline/backup_destination"
        const val CREATE_BACKUP_DOCUMENT = 47621
    }

    private data class PendingBackup(
        val source: File,
        val suggestedName: String,
        val expectedSha256: ByteArray,
        val result: MethodChannel.Result,
    )

    private var pendingBackup: PendingBackup? = null

    fun register(binaryMessenger: BinaryMessenger) {
        MethodChannel(binaryMessenger, BACKUP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveBackup" -> beginBackupSave(
                    call.argument<String>("sourcePath"),
                    call.argument<String>("suggestedName"),
                    call.argument<String>("expectedSha256"),
                    result,
                )
                else -> result.notImplemented()
            }
        }
    }

    private fun beginBackupSave(
        sourcePath: String?,
        suggestedName: String?,
        expectedSha256: String?,
        result: MethodChannel.Result,
    ) {
        if (pendingBackup != null) {
            result.error("backup_destination_busy", "A destination picker is already open.", null)
            return
        }
        val source = sourcePath?.let(::File)
        val expected = try {
            expectedSha256?.let { Base64.decode(it, Base64.URL_SAFE or Base64.NO_WRAP) }
        } catch (_: IllegalArgumentException) {
            null
        }
        val cacheRoot = activity.cacheDir.canonicalFile
        val canonicalSource = try {
            source?.canonicalFile
        } catch (_: Exception) {
            null
        }
        if (
            canonicalSource == null ||
            !canonicalSource.isFile ||
            !canonicalSource.path.startsWith(cacheRoot.path + File.separator) ||
            suggestedName.isNullOrBlank() ||
            expected == null ||
            expected.size != 32
        ) {
            result.error("backup_destination_invalid", "The prepared backup is invalid.", null)
            return
        }

        pendingBackup = PendingBackup(canonicalSource, suggestedName, expected, result)
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, suggestedName)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        }
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, CREATE_BACKUP_DOCUMENT)
        } catch (_: Exception) {
            pendingBackup = null
            result.error("backup_destination_unavailable", "No document destination is available.", null)
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != CREATE_BACKUP_DOCUMENT) {
            return false
        }
        val pending = pendingBackup ?: return true
        pendingBackup = null
        if (resultCode != Activity.RESULT_OK) {
            pending.result.success(null)
            return true
        }
        val destination = data?.data
        if (destination == null) {
            pending.result.error("backup_destination_write_failed", "The destination was unavailable.", null)
            return true
        }
        Thread { saveAndVerify(destination, pending) }.start()
        return true
    }

    private fun saveAndVerify(destination: Uri, pending: PendingBackup) {
        try {
            FileInputStream(pending.source).use { input ->
                activity.contentResolver.openOutputStream(destination, "wt").use { output ->
                    requireNotNull(output)
                    input.copyTo(output)
                    output.flush()
                }
            }
            val digest = MessageDigest.getInstance("SHA-256")
            activity.contentResolver.openInputStream(destination).use { input ->
                requireNotNull(input)
                val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    digest.update(buffer, 0, count)
                }
            }
            if (!MessageDigest.isEqual(digest.digest(), pending.expectedSha256)) {
                completeWithError(
                    pending,
                    "backup_destination_verification_failed",
                    "The saved backup did not match the prepared backup.",
                )
                return
            }
            activity.runOnUiThread {
                pending.result.success(
                    mapOf("displayPath" to pending.suggestedName, "verified" to true),
                )
            }
        } catch (_: Exception) {
            completeWithError(
                pending,
                "backup_destination_write_failed",
                "The backup could not be written and verified.",
            )
        }
    }

    private fun completeWithError(pending: PendingBackup, code: String, message: String) {
        activity.runOnUiThread { pending.result.error(code, message, null) }
    }
}
