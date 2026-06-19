package com.example.flux_app

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest

/**
 * Generates a cached JPEG thumbnail for a recorded MP4 using the platform
 * MediaMetadataRetriever (no third-party dependency). Work runs off the main
 * thread; the result is posted back on the main thread.
 */
class ThumbnailHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "flux_app/thumbnail"
        private const val MAX_WIDTH = 640
        private const val FRAME_TIME_US = 1_000_000L // grab a frame ~1s in
    }

    private val main = Handler(Looper.getMainLooper())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "generate") {
            result.notImplemented()
            return
        }
        val videoPath = call.argument<String>("videoPath")
        if (videoPath == null) {
            result.success(null)
            return
        }
        Thread {
            val path = try {
                generate(videoPath)
            } catch (e: Exception) {
                null
            }
            main.post { result.success(path) }
        }.start()
    }

    private fun generate(videoPath: String): String? {
        val source = File(videoPath)
        if (!source.exists() || source.length() <= 0) return null

        val dir = File(context.cacheDir, "thumbs").apply { mkdirs() }
        val out = File(dir, hash(videoPath + source.lastModified()) + ".jpg")
        if (out.exists() && out.length() > 0) return out.absolutePath

        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(videoPath)
            val frame: Bitmap = retriever.getFrameAtTime(
                FRAME_TIME_US,
                MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
            ) ?: retriever.frameAtTime ?: return null

            val scaled = scale(frame)
            FileOutputStream(out).use { scaled.compress(Bitmap.CompressFormat.JPEG, 75, it) }
            return out.absolutePath
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun scale(bmp: Bitmap): Bitmap {
        if (bmp.width <= MAX_WIDTH) return bmp
        val ratio = MAX_WIDTH.toFloat() / bmp.width
        return Bitmap.createScaledBitmap(bmp, MAX_WIDTH, (bmp.height * ratio).toInt(), true)
    }

    private fun hash(input: String): String =
        MessageDigest.getInstance("MD5")
            .digest(input.toByteArray())
            .joinToString("") { "%02x".format(it) }
}
