package com.example.flux_app

import android.app.Activity
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

/**
 * Copies a recording into the phone's public gallery (Movies/Flux) so it shows
 * up in the system gallery app. Uses MediaStore on API 29+, and the legacy
 * public-storage path (with a runtime WRITE permission) on API 24–28.
 */
class GallerySaverHandler(
    private val context: Context,
    private val activity: Activity,
) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "flux_app/gallery_saver"
        const val REQUEST_WRITE = 5001
        private const val ALBUM = "Flux"

        private val mainHandler = Handler(Looper.getMainLooper())
    }

    private var pendingResult: MethodChannel.Result? = null
    private var pendingPath: String? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "saveToGallery") {
            result.notImplemented()
            return
        }
        val videoPath = call.argument<String>("videoPath")
        if (videoPath == null) {
            result.error("bad_args", "videoPath missing", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q || hasWritePermission()) {
            saveAsync(videoPath, result)
        } else {
            // API 24–28: request the legacy write permission first.
            pendingResult = result
            pendingPath = videoPath
            activity.requestPermissions(
                arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_WRITE,
            )
        }
    }

    /** Forwarded from MainActivity.onRequestPermissionsResult. */
    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_WRITE) return false
        val result = pendingResult
        val path = pendingPath
        pendingResult = null
        pendingPath = null
        if (result == null || path == null) return true
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (granted) {
            saveAsync(path, result)
        } else {
            result.error("permission_denied", "Storage permission denied", null)
        }
        return true
    }

    private fun saveAsync(videoPath: String, result: MethodChannel.Result) {
        Thread {
            try {
                val saved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    saveWithMediaStore(videoPath)
                } else {
                    saveLegacy(videoPath)
                }
                mainHandler.post { result.success(saved) }
            } catch (e: Exception) {
                mainHandler.post {
                    result.error("save_failed", e.message ?: "Save failed", null)
                }
            }
        }.start()
    }

    private fun saveWithMediaStore(videoPath: String): String {
        val src = File(videoPath)
        if (!src.exists()) throw IOException("Source missing")
        val resolver = context.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Video.Media.DISPLAY_NAME, src.name)
            put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
            put(
                MediaStore.Video.Media.RELATIVE_PATH,
                "${Environment.DIRECTORY_MOVIES}/$ALBUM",
            )
            put(MediaStore.Video.Media.IS_PENDING, 1)
        }
        val collection =
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri = resolver.insert(collection, values)
            ?: throw IOException("MediaStore insert failed")

        resolver.openOutputStream(uri).use { out ->
            requireNotNull(out) { "Null output stream" }
            src.inputStream().use { it.copyTo(out) }
        }
        values.clear()
        values.put(MediaStore.Video.Media.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
        return uri.toString()
    }

    private fun saveLegacy(videoPath: String): String {
        val src = File(videoPath)
        if (!src.exists()) throw IOException("Source missing")
        val dir = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES),
            ALBUM,
        )
        if (!dir.exists() && !dir.mkdirs()) throw IOException("Cannot create album dir")

        var dest = File(dir, src.name)
        if (dest.exists()) {
            val base = src.name.removeSuffix(".mp4")
            dest = File(dir, "${base}_${System.currentTimeMillis()}.mp4")
        }
        src.copyTo(dest, overwrite = false)
        MediaScannerConnection.scanFile(
            context,
            arrayOf(dest.absolutePath),
            arrayOf("video/mp4"),
            null,
        )
        return dest.absolutePath
    }

    private fun hasWritePermission(): Boolean =
        context.checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
            PackageManager.PERMISSION_GRANTED
}
