package com.example.flux_app

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaCodecInfo
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import java.io.File

/**
 * Foreground service that captures the screen with MediaProjection + MediaRecorder
 * and writes an MP4 to the app's external files dir. Emits per-second ticks and
 * errors back through [RecordingMethodHandler].
 */
class ScreenRecordService : Service() {

    companion object {
        private const val CHANNEL_ID = "flux_recording"
        private const val NOTIF_ID = 1
        private const val ACTION_START = "com.example.flux_app.START"
        private const val EXTRA_RESULT_CODE = "resultCode"
        private const val EXTRA_DATA = "data"
        private const val EXTRA_QUALITY = "quality"
        private const val EXTRA_AUDIO = "audio"

        var instance: ScreenRecordService? = null
            private set

        fun start(
            context: Context,
            resultCode: Int,
            data: Intent,
            quality: String,
            audio: Boolean,
        ) {
            val intent = Intent(context, ScreenRecordService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_RESULT_CODE, resultCode)
                putExtra(EXTRA_DATA, data)
                putExtra(EXTRA_QUALITY, quality)
                putExtra(EXTRA_AUDIO, audio)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }

    private var projection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var recorder: MediaRecorder? = null
    private var outputPath: String? = null
    private var elapsedSeconds = 0
    private var isPaused = false

    private val ticker = Handler(Looper.getMainLooper())
    private val tickRunnable = object : Runnable {
        override fun run() {
            if (!isPaused) {
                elapsedSeconds++
                RecordingMethodHandler.emitTick(elapsedSeconds)
            }
            ticker.postDelayed(this, 1000)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_START) {
            startForegroundNotification()
            val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, Activity.RESULT_CANCELED)
            val data = parcelableData(intent)
            val quality = intent.getStringExtra(EXTRA_QUALITY) ?: "medium"
            val audio = intent.getBooleanExtra(EXTRA_AUDIO, false)
            try {
                requireNotNull(data) { "Missing projection data" }
                startCapture(resultCode, data, quality, audio)
                instance = this
            } catch (e: Exception) {
                RecordingMethodHandler.emitError(e.message ?: "Failed to start recording")
                cleanup()
                stopForegroundCompat()
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    private fun startCapture(resultCode: Int, data: Intent, quality: String, audio: Boolean) {
        val metrics = resources.displayMetrics
        val (width, height, bitrate) = resolveQuality(quality, metrics)
        val useAudio = audio && hasAudioPermission()
        if (audio && !useAudio) {
            RecordingMethodHandler.emitError(
                "Microphone permission missing — recording without audio",
            )
        }

        outputPath = File(
            getExternalFilesDir(null),
            "Flux-Recording-${System.currentTimeMillis()}.mp4",
        ).absolutePath

        recorder = createRecorder(useAudio, width, height, bitrate, outputPath!!)

        val mpm = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        projection = mpm.getMediaProjection(resultCode, data)
        // Required on API 34+: register a callback before creating the display.
        projection?.registerCallback(object : MediaProjection.Callback() {
            override fun onStop() {
                RecordingMethodHandler.emitError("Screen capture stopped")
            }
        }, ticker)

        virtualDisplay = projection?.createVirtualDisplay(
            "FluxCapture",
            width,
            height,
            metrics.densityDpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            recorder!!.surface,
            null,
            null,
        )

        recorder?.start()
        elapsedSeconds = 0
        isPaused = false
        ticker.postDelayed(tickRunnable, 1000)
    }

    private fun createRecorder(
        audio: Boolean,
        width: Int,
        height: Int,
        bitrate: Int,
        path: String,
    ): MediaRecorder {
        val r = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            MediaRecorder(this)
        } else {
            @Suppress("DEPRECATION")
            MediaRecorder()
        }
        if (audio) r.setAudioSource(MediaRecorder.AudioSource.MIC)
        r.setVideoSource(MediaRecorder.VideoSource.SURFACE)
        r.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
        r.setOutputFile(path)
        r.setVideoSize(width, height)
        r.setVideoEncoder(MediaRecorder.VideoEncoder.H264)
        if (audio) r.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
        r.setVideoEncodingBitRate(bitrate)
        r.setVideoFrameRate(30)
        // Force H.264 Baseline profile. The default encoder picks High profile
        // (avc1.640029 — CABAC + B-frames), which budget MediaTek hardware
        // decoders on old phones (Flux's target) cannot start() even though they
        // report the format as supported. Baseline is the universally decodable
        // profile for low-end devices. API 26+; wrap because some encoders reject
        // an explicit profile/level and fall back to their default.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                r.setVideoEncodingProfileLevel(
                    MediaCodecInfo.CodecProfileLevel.AVCProfileBaseline,
                    MediaCodecInfo.CodecProfileLevel.AVCLevel4,
                )
            } catch (e: Exception) {
                RecordingMethodHandler.emitError(
                    "Could not set Baseline profile — using encoder default",
                )
            }
        }
        r.prepare()
        return r
    }

    fun pauseRecording() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && !isPaused) {
            try {
                recorder?.pause()
                isPaused = true
            } catch (e: Exception) {
                RecordingMethodHandler.emitError(e.message ?: "Pause failed")
            }
        }
    }

    fun resumeRecording() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && isPaused) {
            try {
                recorder?.resume()
                isPaused = false
            } catch (e: Exception) {
                RecordingMethodHandler.emitError(e.message ?: "Resume failed")
            }
        }
    }

    /** Stops capture and returns the saved file path (or null on failure). */
    fun stopRecording(): String? {
        ticker.removeCallbacks(tickRunnable)
        val path = outputPath
        try {
            recorder?.stop()
        } catch (e: Exception) {
            // Thrown if stopped before any frame was written (e.g. instant stop).
            RecordingMethodHandler.emitError(e.message ?: "Stop failed")
        }
        cleanup()
        stopForegroundCompat()
        instance = null
        stopSelf()
        return path
    }

    private fun cleanup() {
        try {
            recorder?.reset()
            recorder?.release()
        } catch (_: Exception) {
        }
        recorder = null
        virtualDisplay?.release()
        virtualDisplay = null
        projection?.stop()
        projection = null
    }

    private fun resolveQuality(quality: String, m: DisplayMetrics): Triple<Int, Int, Int> {
        val nativeW = m.widthPixels
        val nativeH = m.heightPixels
        val shortSide = minOf(nativeW, nativeH)
        val (targetShort, bitrate) = when (quality) {
            "low" -> 720 to 2_000_000
            "medium" -> 1080 to 5_000_000
            "high" -> 1080 to 8_000_000
            "ultra" -> shortSide to 12_000_000
            else -> 1080 to 5_000_000
        }
        // Never upscale beyond the device's native resolution.
        val scale = if (shortSide == 0) 1.0 else (targetShort.toDouble() / shortSide).coerceAtMost(1.0)
        // Align to 16. MediaTek/some hardware AVC decoders reject non-16-aligned
        // dimensions at MediaCodec.start() even though ExoPlayer reports the
        // format as supported (e.g. 720x1492 -> 720x1488). Round down so we
        // never exceed the native resolution.
        val width = align16((nativeW * scale).toInt())
        val height = align16((nativeH * scale).toInt())
        return Triple(width, height, bitrate)
    }

    private fun align16(v: Int): Int = (v / 16 * 16).coerceAtLeast(16)

    private fun hasAudioPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            checkSelfPermission(android.Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED

    private fun startForegroundNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Screen Recording",
                NotificationManager.IMPORTANCE_LOW,
            )
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        val notification = builder
            .setContentTitle("Flux")
            .setContentText("Recording screen…")
            .setSmallIcon(android.R.drawable.presence_video_online)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIF_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
            )
        } else {
            startForeground(NOTIF_ID, notification)
        }
    }

    private fun stopForegroundCompat() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    private fun parcelableData(intent: Intent): Intent? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(EXTRA_DATA, Intent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(EXTRA_DATA)
        }

    override fun onDestroy() {
        ticker.removeCallbacks(tickRunnable)
        cleanup()
        instance = null
        super.onDestroy()
    }
}
