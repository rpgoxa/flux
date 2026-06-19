import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/models/recording_state.dart';
import 'package:flux_app/providers/gallery_provider.dart';
import 'package:flux_app/providers/settings_provider.dart';
import 'package:flux_app/services/recording_service.dart';
import 'package:flux_app/services/storage_service.dart';

/// Injectable screen-capture engine (overridable in tests with a fake).
final recordingServiceProvider =
    Provider<RecordingService>((ref) => RecordingService());

/// Drives the recording state machine and the native capture engine:
/// idle → countdown → recording ⇄ paused → saving → idle.
class RecordingNotifier extends Notifier<RecordingState> {
  StreamSubscription<RecordingEvent>? _sub;

  RecordingService get _service => ref.read(recordingServiceProvider);

  @override
  RecordingState build() {
    ref.onDispose(() => _sub?.cancel());
    return const RecordingState();
  }

  /// idle → countdown, then request permission + start native capture.
  Future<void> start() async {
    if (state.phase != RecordingPhase.idle) return;
    state = state.copyWith(
      phase: RecordingPhase.countdown,
      duration: Duration.zero,
      elapsedSeconds: 0,
      clearError: true,
      clearFilePath: true,
    );

    final settings =
        ref.read(settingsProvider).valueOrNull ?? const SettingsState();
    final ok = await _service.startRecording(
      quality: settings.quality.recordingQuality,
      audioEnabled: state.micEnabled,
    );

    if (!ok) {
      state = const RecordingState(
        errorMessage: 'Screen capture permission denied',
      );
      return;
    }
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = _service.events().listen((event) {
      switch (event) {
        case RecordingTick(:final seconds):
          if (state.isActive) {
            state = state.copyWith(
              elapsedSeconds: seconds,
              duration: Duration(seconds: seconds),
            );
          }
        case RecordingError(:final message):
          state = state.copyWith(errorMessage: message);
      }
    });
  }

  /// countdown → recording.
  void begin() {
    if (state.phase != RecordingPhase.countdown) return;
    state = state.copyWith(phase: RecordingPhase.recording);
  }

  /// recording → paused.
  Future<void> pause() async {
    if (state.phase != RecordingPhase.recording) return;
    await _service.pauseRecording();
    state = state.copyWith(phase: RecordingPhase.paused);
  }

  /// paused → recording.
  Future<void> resume() async {
    if (state.phase != RecordingPhase.paused) return;
    await _service.resumeRecording();
    state = state.copyWith(phase: RecordingPhase.recording);
  }

  /// recording|paused → saving. Stops capture, captures the saved file path.
  Future<void> stop() async {
    if (!state.isActive) return;
    final path = await _service.stopRecording();
    await _sub?.cancel();
    _sub = null;
    state = state.copyWith(phase: RecordingPhase.saving, filePath: path);
  }

  /// saving → idle (keep the file the engine already wrote, refresh gallery).
  void save() {
    if (state.phase != RecordingPhase.saving) return;
    state = const RecordingState();
    // Pick up the new recording without blocking the UI.
    Future.microtask(() => ref.read(galleryProvider.notifier).loadRecordings());
  }

  /// saving → idle (discard the take — delete the file the engine wrote).
  void discard() {
    if (state.phase != RecordingPhase.saving) return;
    final path = state.filePath;
    state = const RecordingState();
    if (path != null) {
      Future.microtask(() => StorageService.instance.deletePath(path));
    }
  }

  /// Reset to idle from any phase.
  void reset() {
    _sub?.cancel();
    _sub = null;
    state = const RecordingState();
  }

  void setMic(bool enabled) => state = state.copyWith(micEnabled: enabled);

  void setCamera(bool enabled) => state = state.copyWith(cameraEnabled: enabled);
}

final recordingProvider =
    NotifierProvider<RecordingNotifier, RecordingState>(RecordingNotifier.new);
