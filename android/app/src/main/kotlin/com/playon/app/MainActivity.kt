package com.playon.app

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.playon.app/timezone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Prevent screenshots and screen recording
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getLocalTimezone") {
                try {
                    val zoneId = TimeZone.getDefault().id ?: "UTC"
                    result.success(zoneId)
                } catch (e: Exception) {
                    result.success("UTC")
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
