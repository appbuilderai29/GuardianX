
package com.example.guardianx

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import kotlin.math.sqrt
import android.app.PendingIntent
import android.content.ComponentName
class BackTapService : Service(), SensorEventListener {

    companion object {
        const val ACTION_START =
            "com.example.guardianx.action.START_PROTECTION"
        const val ACTION_STOP =
            "com.example.guardianx.action.STOP_PROTECTION"

        private const val CHANNEL_ID = "guardianx_protection"
        private const val NOTIFICATION_ID = 1001
        private const val SOS_NOTIFICATION_ID = 2001
    }

    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null

    private var tapCount = 0
    private var lastTapTime = 0L
    private var lastAlertTime = 0L
    private var aboveThreshold = false

    override fun onCreate() {
        super.onCreate()

        sensorManager =
            getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer =
            sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "GuardianX Protection",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                sensorManager.unregisterListener(this)
                stopForeground(true)
                stopSelf()
                return START_NOT_STICKY
            }

            ACTION_START -> {
                val notification = if (
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ) {
                    Notification.Builder(this, CHANNEL_ID)
                } else {
                    @Suppress("DEPRECATION")
                    Notification.Builder(this)
                }
                    .setSmallIcon(android.R.drawable.ic_dialog_alert)
                    .setContentTitle("GuardianX Protection Active")
                    .setContentText("Emergency motion monitoring is enabled")
                    .setOngoing(true)
                    .build()

                startForeground(NOTIFICATION_ID, notification)

                val sensor = accelerometer
                if (sensor == null) {
                    stopSelf()
                    return START_NOT_STICKY
                }

                sensorManager.unregisterListener(this)
                sensorManager.registerListener(
                    this,
                    sensor,
                    SensorManager.SENSOR_DELAY_GAME
                )
            }

            else -> return START_NOT_STICKY
        }

        return START_STICKY
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        val x = event.values[0].toDouble()
        val y = event.values[1].toDouble()
        val z = event.values[2].toDouble()
        val magnitude = sqrt(x * x + y * y + z * z)

        // Heuristic only: sudden movement is not proof of a back tap.
        val threshold = 16.0
        val now = SystemClock.elapsedRealtime()

        if (magnitude > threshold && !aboveThreshold) {
            if (now - lastTapTime > 1200L) {
                tapCount = 0
            }

            tapCount++
            lastTapTime = now

            if (tapCount >= 3 && now - lastAlertTime > 5000L) {
                tapCount = 0
                lastAlertTime = now
                showGestureNotification()
            }
        }

        aboveThreshold = magnitude > threshold

        if (now - lastTapTime > 1200L) {
            tapCount = 0
        }
    }

private fun showGestureNotification() {
    val launchIntent = packageManager
        .getLaunchIntentForPackage(packageName)
       
        ?.apply {
            putExtra("guardianx_gesture_sos", true)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
                android.util.Log.d(
        "GuardianX",
        "Gesture SOS notification launch intent prepared"
    )
        }

    val pendingIntent = launchIntent?.let {
        PendingIntent.getActivity(
            this,
            2001,
            it,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
        )
    }

    val builder = if (
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
    ) {
        Notification.Builder(this, CHANNEL_ID)
    } else {
        @Suppress("DEPRECATION")
        Notification.Builder(this)
    }

    builder
        .setSmallIcon(android.R.drawable.ic_dialog_alert)
        .setContentTitle("GuardianX: Possible SOS Gesture")
        .setContentText("Tap to open GuardianX and review the alert.")
        .setAutoCancel(true)
        .setContentIntent(pendingIntent)

    val manager =
        getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager

    manager.notify(SOS_NOTIFICATION_ID, builder.build())
}

   

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onDestroy() {
        if (::sensorManager.isInitialized) {
            sensorManager.unregisterListener(this)
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
