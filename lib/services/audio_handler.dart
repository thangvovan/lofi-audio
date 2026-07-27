import 'dart:async';

import 'package:just_audio/just_audio.dart';

class LofiAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  final _skipNextController = StreamController<void>.broadcast();
  final _skipPreviousController = StreamController<void>.broadcast();

  /// Streams for skip control events
  Stream<void> get onSkipNext => _skipNextController.stream;
  Stream<void> get onSkipPrevious => _skipPreviousController.stream;

  AudioPlayer get player => _player;

  bool get playing => _player.playing;

  /// Set the audio source URL
  Future<void> setUrl(String url) async {
    await _player.setUrl(url);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> seek(Duration position) => _player.seek(position);

  void skipToNext() {
    _skipNextController.add(null);
  }

  void skipToPrevious() {
    _skipPreviousController.add(null);
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _skipNextController.close();
    await _skipPreviousController.close();
  }
}
