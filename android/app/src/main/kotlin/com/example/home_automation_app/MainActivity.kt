package com.example.home_automation_app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.home_automation_app/voice_launcher"
    private var channel: MethodChannel? = null
    private var shouldLaunchVoice = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            if (call.method == "checkLaunchVoice") {
                result.success(shouldLaunchVoice)
                shouldLaunchVoice = false // reset
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (intent != null && intent.getBooleanExtra("launch_voice", false)) {
            shouldLaunchVoice = true
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.getBooleanExtra("launch_voice", false)) {
            shouldLaunchVoice = true
            channel?.invokeMethod("launchVoiceAssistant", null)
        }
    }
}
