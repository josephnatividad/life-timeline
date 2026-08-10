package com.lifetimeline.life_timeline

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    private lateinit var backupDestinationHandler: BackupDestinationHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        backupDestinationHandler = BackupDestinationHandler(this)
        backupDestinationHandler.register(flutterEngine.dartExecutor.binaryMessenger)
    }

    @Deprecated("Deprecated in Android; retained for Flutter activity result interoperability.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (backupDestinationHandler.handleActivityResult(requestCode, resultCode, data)) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
