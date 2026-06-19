import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flux_app/models/recording_state.dart';
import 'package:flux_app/providers/recording_provider.dart';

void main() {
  group('RecordingNotifier state machine', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    RecordingNotifier notifier() =>
        container.read(recordingProvider.notifier);
    RecordingPhase phase() => container.read(recordingProvider).phase;

    test('starts idle', () {
      expect(phase(), RecordingPhase.idle);
    });

    test('full path: idle → countdown → recording → paused → saving → idle',
        () {
      notifier().start();
      expect(phase(), RecordingPhase.countdown);

      notifier().begin();
      expect(phase(), RecordingPhase.recording);

      notifier().pause();
      expect(phase(), RecordingPhase.paused);

      notifier().resume();
      expect(phase(), RecordingPhase.recording);

      notifier().stop();
      expect(phase(), RecordingPhase.saving);

      notifier().save();
      expect(phase(), RecordingPhase.idle);
    });

    test('discard from saving returns to idle', () {
      notifier()
        ..start()
        ..begin()
        ..stop();
      expect(phase(), RecordingPhase.saving);
      notifier().discard();
      expect(phase(), RecordingPhase.idle);
    });

    test('invalid transitions are ignored', () {
      notifier().begin(); // no countdown yet
      expect(phase(), RecordingPhase.idle);
      notifier().pause(); // not recording
      expect(phase(), RecordingPhase.idle);
    });

    test('mic and camera toggles update state', () {
      notifier().setCamera(true);
      expect(container.read(recordingProvider).cameraEnabled, isTrue);
      notifier().setMic(false);
      expect(container.read(recordingProvider).micEnabled, isFalse);
    });
  });
}
