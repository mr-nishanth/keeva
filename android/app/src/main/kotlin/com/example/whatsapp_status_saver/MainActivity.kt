package com.example.whatsapp_status_saver

import android.content.Intent
import com.example.whatsapp_status_saver.status.AndroidStatusScanner
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Minimal host Activity that delegates platform channel operations
 * to the AndroidStatusScanner native facade.
 */
class MainActivity : FlutterActivity() {

    private lateinit var statusScanner: AndroidStatusScanner

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        statusScanner = AndroidStatusScanner(this)
        statusScanner.registerWith(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (::statusScanner.isInitialized) {
            statusScanner.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun onDestroy() {
        if (::statusScanner.isInitialized) {
            statusScanner.dispose()
        }
        super.onDestroy()
    }
}
