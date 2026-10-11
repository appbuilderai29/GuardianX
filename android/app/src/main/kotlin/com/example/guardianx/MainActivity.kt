
package com.example.guardianx

import android.content.Intent
import android.app.ActivityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.guardianx/back_tap"
    private var pendingGestureSOS = false

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        pendingGestureSOS =
            intent?.getBooleanExtra("guardianx_gesture_sos", false) == true
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        if (intent.getBooleanExtra("guardianx_gesture_sos", false)) {
            pendingGestureSOS = true
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "startProtection" -> {
                    try {
                        val serviceIntent = Intent(
                            this,
                            BackTapService::class.java
                        ).apply {
                            action = BackTapService.ACTION_START
                        }

                        startForegroundService(serviceIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("START_FAILED", e.message, null)
                    }
                }

                "stopProtection" -> {
                    try {
                        val serviceIntent = Intent(
                            this,
                            BackTapService::class.java
                        ).apply {
                            action = BackTapService.ACTION_STOP
                        }

                        startService(serviceIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("STOP_FAILED", e.message, null)
                    }
                }

                "isProtectionRunning" -> {
                    val activityManager =
                        getSystemService(ACTIVITY_SERVICE) as ActivityManager

                    val running = activityManager
                        .getRunningServices(Int.MAX_VALUE)
                        .any {
                            it.service.className ==
                                BackTapService::class.java.name
                        }

                    result.success(running)
                }

                "getPendingGestureSOS" -> {
                    result.success(pendingGestureSOS)
                }

                "clearPendingGestureSOS" -> {
                    pendingGestureSOS = false
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}
