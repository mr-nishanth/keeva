package io.nishvanta.keeva

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.nishvanta.keeva.auth.BiometricEnrollmentGuard
import io.nishvanta.keeva.status.AndroidStatusScanner

/**
 * Host Activity for Keeva.
 *
 * [FlutterFragmentActivity] is required so Android BiometricPrompt, used by
 * the local_auth plugin, has a FragmentActivity to attach to.
 */
class MainActivity : FlutterFragmentActivity() {

    private lateinit var statusScanner: AndroidStatusScanner

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        statusScanner = AndroidStatusScanner(this)
        statusScanner.registerWith(flutterEngine.dartExecutor.binaryMessenger)
        BiometricEnrollmentGuard.register(flutterEngine.dartExecutor.binaryMessenger)
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
