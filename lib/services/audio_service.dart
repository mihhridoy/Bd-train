import 'package:audioplayers/audioplayers.dart';

/// Optional sound effects (feature flag `FF_AUDIO`). Failures are swallowed:
/// audio must never break the app.
abstract interface class AudioService {
  Future<void> playHorn();
  Future<void> startRailLoop();
  Future<void> stopRailLoop();
  Future<void> dispose();
}

class AudioplayersAudioService implements AudioService {
  AudioPlayer? _horn;
  AudioPlayer? _loop;

  @override
  Future<void> playHorn() async {
    try {
      final p = _horn ??= AudioPlayer();
      await p.stop();
      await p.play(AssetSource('sounds/horn.wav'));
    } catch (_) {}
  }

  @override
  Future<void> startRailLoop() async {
    try {
      final p = _loop ??= AudioPlayer();
      await p.setReleaseMode(ReleaseMode.loop);
      await p.setVolume(0.25);
      await p.play(AssetSource('sounds/rail_loop.wav'));
    } catch (_) {}
  }

  @override
  Future<void> stopRailLoop() async {
    try {
      await _loop?.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    try {
      await _horn?.dispose();
      await _loop?.dispose();
    } catch (_) {}
  }
}

class SilentAudioService implements AudioService {
  const SilentAudioService();
  @override
  Future<void> playHorn() async {}
  @override
  Future<void> startRailLoop() async {}
  @override
  Future<void> stopRailLoop() async {}
  @override
  Future<void> dispose() async {}
}
