package com.lifetimeline.life_timeline

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.security.MessageDigest

class BackupDestinationHandler(private val activity: Activity) {
    private companion object {
        const val BACKUP_CHANNEL = "life_timeline/backup_destination"
        const val CREATE_BACKUP_DOCUMENT = 47621
        const val OPEN_BACKUP_DOCUMENT = 47622
    }

    private data class PendingBackup(
        val source: File,
        val suggestedName: String,
        val expectedSha256: ByteArray,
        val result: MethodChannel.Result,
    )

    private data class PendingImport(
        val result: MethodChannel.Result,
    )

    private var pendingBackup: PendingBackup? = null
    private var pendingImport: PendingImport? = null

    fun register(binaryMessenger: BinaryMessenger) {
        MethodChannel(binaryMessenger, BACKUP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveBackup" -> beginBackupSave(
                    call.argument<String>("sourcePath"),
                    call.argument<String>("suggestedName"),
                    call.argument<String>("expectedSha256"),
                    result,
                )
                "openBackup" -> beginBackupOpen(result)
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
        if (pendingBackup != null || pendingImport != null) {
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

    private fun beginBackupOpen(result: MethodChannel.Result) {
        if (pendingBackup != null || pendingImport != null) {
            result.error("backup_destination_busy", "A document picker is already open.", null)
            return
        }
        pendingImport = PendingImport(result)
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            // Backup contents are authenticated after selection, so accepting
            // every provider MIME type is safer than relying on inconsistent
            // custom-extension mappings for .timelinebackup files.
            type = "*/*"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, OPEN_BACKUP_DOCUMENT)
        } catch (_: Exception) {
            pendingImport = null
            result.error("backup_file_selection_failed", "No document source is available.", null)
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == OPEN_BACKUP_DOCUMENT) {
            val pending = pendingImport ?: return true
            pendingImport = null
            if (resultCode != Activity.RESULT_OK) {
                pending.result.success(null)
                return true
            }
            val source = data?.data
            if (source == null) {
                pending.result.error(
                    "backup_file_selection_failed",
                    "The selected document was unavailable.",
                    null,
                )
                return true
            }
            Thread { copyImportForInspection(source, pending) }.start()
            return true
        }
        if (requestCode != CREATE_BACKUP_DOCUMENT) return false
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

    private fun copyImportForInspection(source: Uri, pending: PendingImport) {
        var target: File? = null
        try {
            val root = File(activity.cacheDir, "backup_import_selection")
            if (!root.exists() && !root.mkdirs()) {
                error("Import cache could not be created")
            }
            root.listFiles()?.forEach { old -> old.delete() }
            val selectedFile = File.createTempFile("selected_", ".timelinebackup", root)
            target = selectedFile
            activity.contentResolver.openInputStream(source).use { input ->
                requireNotNull(input)
                FileOutputStream(selectedFile).use { output ->
                    input.copyTo(output)
                    output.flush()
                }
            }
            if (!selectedFile.isFile || selectedFile.length() == 0L) {
                error("Selected backup was empty")
            }
            val selectedPath = selectedFile.canonicalPath
            activity.runOnUiThread { pending.result.success(selectedPath) }
        } catch (_: Exception) {
            target?.delete()
            activity.runOnUiThread {
                pending.result.error(
                    "backup_file_selection_failed",
                    "The selected backup could not be copied for inspection.",
                    null,
                )
            }
        }
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
