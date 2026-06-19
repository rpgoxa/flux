import 'dart:async';

import 'package:flutter/services.dart';

/// Quality tier passed to the native engine. Maps to resolution + bitrate
/// on the Android side (see ScreenRecordService.kt).
enum RecordingQuality { low, medium, high, ultra }

/// An event pushed from the native recording engine over the EventChannel.
sealed class RecordingEvent {
  const RecordingEvent();
}

/// Per-second elapsed tick while recording is active.
class RecordingTick extends RecordingEvent {
  const RecordingTick(this.seconds);
  final int seconds;
}

/// Engine-side failure (setup failed, capture interrupted, low storage…).
class RecordingError extends RecordingEvent {
  const RecordingError(this.message);
  final String message;
}

/// Thin platform-channel wrapper over the Android MediaProjection engine.
/// All business logic stays in the provider — this class only marshals calls.
class RecordingService {
  RecordingService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _method = methodChannel ?? const MethodChannel(_methodChannelName),
        _event = eventChannel ?? const EventChannel(_eventChannelName);

  static const _methodChannelName = 'flux_app/recording';
  static const _eventChannelName = 'flux_app/recording/events';

  final MethodChannel _method;
  final EventChannel _event;

  /// Broadcast stream of ticks + errors from the native engine.
  Stream<RecordingEvent> events() {
    return _event.receiveBroadcastStream().map(_mapEvent).where((e) => e != null).cast<RecordingEvent>();
  }

  RecordingEvent? _mapEvent(dynamic raw) {
    if (raw is! Map) return null;
    final type = raw['type'];
    switch (type) {
      case 'tick':
        final seconds = raw['seconds'];
        return RecordingTick(seconds is int ? seconds : 0);
      case 'error':
        final message = raw['message'];
        return RecordingError(message is String ? message : 'Unknown error');
      default:
        return null;
    }
  }

  /// Request screen-capture permission + start the foreground capture service.
  /// Returns false if the user denied the permission dialog or setup failed.
  Future<bool> startRecording({
    required RecordingQuality quality,
    required bool audioEnabled,
  }) async {
    try {
      final ok = await _method.invokeMethod<bool>('start', {
        'quality': quality.name,
        'audioEnabled': audioEnabled,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _method.invokeMethod<void>('pause');
    } on PlatformException {
      // Pause unsupported (API < 24) or no active session — non-fatal.
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _method.invokeMethod<void>('resume');
    } on PlatformException {
      // No-op: nothing to resume.
    }
  }

  /// Stops capture and returns the saved MP4 path, or null on failure.
  Future<String?> stopRecording() async {
    try {
      return await _method.invokeMethod<String>('stop');
    } on PlatformException {
      return null;
    }
  }
}
