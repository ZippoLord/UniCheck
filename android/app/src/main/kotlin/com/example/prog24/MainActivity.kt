package com.example.prog24

import android.os.Bundle
import android.preference.PreferenceManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.prog24/hce"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setEmulatedJson" -> {
                    val json = (call.argument<String>("json") ?: "")
                    val sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
                    sharedPref.edit().putString("emulated_json", json).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
