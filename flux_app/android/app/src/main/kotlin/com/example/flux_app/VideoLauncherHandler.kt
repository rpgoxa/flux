package com.example.flux_app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Opens a recorded MP4 in the phone's default system video player via an
 * ACTION_VIEW intent. Replaces the in-app ExoPlayer, which fails to decode
 * MediaRecorder output on budget MediaTek hardware decoders even though the
 * files play fine in the native player.
 */
class VideoLauncherHandler(private val activity: Activity) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "flux_app/video_launcher"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "open") {
            result.notImplemented()
            return
        }
        val path = call.argument<String>("videoPath")
        if (path.isNullOrEmpty()) {
            result.error("BAD_ARGS", "videoPath is required", null)
            return
        }
        val file = File(path)
        if (!file.exists()) {
            result.error("NOT_FOUND", "File does not exist: $path", null)
            return
        }
        try {
            val uri = FileProvider.getUriForFile(
                activity,
                "${activity.packageName}.fileprovider",
                file,
            )
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "video/mp4")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            val chooser = Intent.createChooser(intent, "Play with")
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            activity.startActivity(chooser)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            result.error("NO_PLAYER", "No app available to play video", null)
        } catch (e: Exception) {
            result.error("LAUNCH_FAILED", e.message ?: "Could not open video", null)
        }
    }
}
