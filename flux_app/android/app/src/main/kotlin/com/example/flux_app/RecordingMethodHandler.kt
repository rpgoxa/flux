package com.example.flux_app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges the Dart [MethodChannel]/[EventChannel] to the native capture engine.
 * Method calls drive [ScreenRecordService]; ticks and errors are pushed back
 * over the event sink (always on the main thread).
 */
class RecordingMethodHandler(
    private val activity: Activity,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "flux_app/recording"
        const val EVENT_CHANNEL = "flux_app/recording/events"
        const val REQUEST_CODE = 4097

        private val mainHandler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        fun emitTick(seconds: Int) {
            val sink = eventSink ?: return
            mainHandler.post { sink.success(mapOf("type" to "tick", "seconds" to seconds)) }
        }

        fun emitError(message: String) {
            val sink = eventSink ?: return
            mainHandler.post { sink.success(mapOf("type" to "error", "message" to message)) }
        }
    }

    private var pendingResult: MethodChannel.Result? = null
    private var pendingQuality: String = "medium"
    private var pendingAudio: Boolean = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> startCapture(call, result)
            "pause" -> {
                ScreenRecordService.instance?.pauseRecording()
                result.success(null)
            }
            "resume" -> {
                ScreenRecordService.instance?.resumeRecording()
                result.success(null)
            }
            "stop" -> result.success(ScreenRecordService.instance?.stopRecording())
            else -> result.notImplemented()
        }
    }

    private fun startCapture(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            // A permission request is already in flight.
            result.success(false)
            return
        }
        pendingQuality = call.argument<String>("quality") ?: "medium"
        pendingAudio = call.argument<Boolean>("audioEnabled") ?: false
        pendingResult = result
        val mpm = activity
            .getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        activity.startActivityForResult(mpm.createScreenCaptureIntent(), REQUEST_CODE)
    }

    /** Called from MainActivity.onActivityResult. Returns true if it handled the code. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pendingResult ?: return true
        pendingResult = null
        if (resultCode == Activity.RESULT_OK && data != null) {
            ScreenRecordService.start(activity, resultCode, data, pendingQuality, pendingAudio)
            result.success(true)
        } else {
            result.success(false)
        }
        return true
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
