package com.example.flux_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var recordingHandler: RecordingMethodHandler? = null
    private var gallerySaverHandler: GallerySaverHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val handler = RecordingMethodHandler(this)
        recordingHandler = handler
        val saver = GallerySaverHandler(applicationContext, this)
        gallerySaverHandler = saver
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, RecordingMethodHandler.METHOD_CHANNEL)
            .setMethodCallHandler(handler)
        EventChannel(messenger, RecordingMethodHandler.EVENT_CHANNEL)
            .setStreamHandler(handler)
        MethodChannel(messenger, ThumbnailHandler.CHANNEL)
            .setMethodCallHandler(ThumbnailHandler(this))
        MethodChannel(messenger, GallerySaverHandler.CHANNEL)
            .setMethodCallHandler(saver)
    }

    @Deprecated("Forwarding MediaProjection permission result to the handler")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (recordingHandler?.onActivityResult(requestCode, resultCode, data) == true) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (gallerySaverHandler?.onRequestPermissionsResult(requestCode, grantResults) == true) {
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
