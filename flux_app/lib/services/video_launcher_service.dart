import 'package:flutter/services.dart';

/// Opens a recording in the phone's system video player via an Android
/// ACTION_VIEW intent. Replaces the in-app ExoPlayer, which cannot decode
/// MediaRecorder output on some budget hardware decoders.
class VideoLauncherService {
  VideoLauncherService._();
  static final VideoLauncherService instance = VideoLauncherService._();

  static const _channel = MethodChannel('flux_app/video_launcher');

  /// Returns true if a system player was launched. On failure, [errorMessage]
  /// is populated with a user-facing reason.
  Future<VideoLaunchResult> open(String videoPath) async {
    try {
      await _channel.invokeMethod<bool>('open', {'videoPath': videoPath});
      return const VideoLaunchResult(ok: true);
    } on PlatformException catch (e) {
      final reason = switch (e.code) {
        'NO_PLAYER' => 'No video player app found on this device',
        'NOT_FOUND' => 'Recording file is missing',
        _ => 'Could not open this recording',
      };
      return VideoLaunchResult(ok: false, errorMessage: reason);
    }
  }
}

class VideoLaunchResult {
  const VideoLaunchResult({required this.ok, this.errorMessage});
  final bool ok;
  final String? errorMessage;
}
