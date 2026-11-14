package com.example.love_ring

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "loveRing/audio"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var originalRingerMode: Int? = null
    private var originalAlarmVolume: Int? = null
    private var restoreHandler: Handler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkDndPermission" -> {
                    result.success(checkDndPermission())
                }
                "requestDndPermission" -> {
                    requestDndPermission()
                    result.success(null)
                }
                "checkBatteryOptimization" -> {
                    result.success(checkBatteryOptimization())
                }
                "requestBatteryOptimization" -> {
                    requestBatteryOptimization()
                    result.success(null)
                }
                "checkFullScreenIntent" -> {
                    result.success(checkFullScreenIntent())
                }
                "requestFullScreenIntent" -> {
                    requestFullScreenIntent()
                    result.success(null)
                }
                "playLoudSound" -> {
                    playLoudSound()
                    result.success(true)
                }
                "stopLoudSound" -> {
                    stopLoudSound()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkDndPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            return notificationManager.isNotificationPolicyAccessGranted
        }
        return true
    }

    private fun requestDndPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun checkBatteryOptimization(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            return powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return true
    }

    private fun requestBatteryOptimization() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        }
    }

    private fun checkFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) { // API 34+
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            return notificationManager.canUseFullScreenIntent()
        }
        return true
    }

    private fun requestFullScreenIntent() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        }
    }

    private fun playLoudSound() {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

            // Save original volumes and ringer mode
            if (originalRingerMode == null) {
                originalRingerMode = audioManager.ringerMode
            }
            if (originalAlarmVolume == null) {
                originalAlarmVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
            }

            // Override silent/DND mode if permission granted
            if (checkDndPermission()) {
                audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
            }

            // Maximize STREAM_ALARM volume
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVolume, 0)

            // Stop existing player if playing
            stopLoudSound()

            // Play alarm sound
            val alarmUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)

            mediaPlayer = MediaPlayer().apply {
                setDataSource(applicationContext, alarmUri)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                isLooping = true
                prepare()
                start()
            }

            // Auto-restore after 15 seconds if not dismissed
            restoreHandler = Handler(Looper.getMainLooper())
            restoreHandler?.postDelayed({
                stopLoudSound()
            }, 15000)

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopLoudSound() {
        try {
            restoreHandler?.removeCallbacksAndMessages(null)
            restoreHandler = null

            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            }
            mediaPlayer = null

            // Restore original ringer mode & volume
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            originalAlarmVolume?.let {
                audioManager.setStreamVolume(AudioManager.STREAM_ALARM, it, 0)
                originalAlarmVolume = null
            }
            originalRingerMode?.let {
                if (checkDndPermission()) {
                    audioManager.ringerMode = it
                }
                originalRingerMode = null
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        stopLoudSound()
        super.onDestroy()
    }
}
