package dev.bdrail.bd_train_tracker

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bd_train_tracker/settings")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openInternet" -> result.success(openNetworkSettings())
                    else -> result.notImplemented()
                }
            }
    }

    /** Opens wireless/network settings, falling back to the main Settings screen. */
    private fun openNetworkSettings(): Boolean {
        val candidates = listOf(Settings.ACTION_WIRELESS_SETTINGS, Settings.ACTION_SETTINGS)
        for (action in candidates) {
            try {
                startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                return true
            } catch (_: Exception) {
                // try next
            }
        }
        return false
    }
}
