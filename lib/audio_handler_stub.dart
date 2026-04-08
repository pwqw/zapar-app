import 'package:audio_service/audio_service.dart';

/// Stub implementation of AudioHandler para web.
/// En web, no se soportan APIs de audio nativas.
class AudioHandlerStub extends BaseAudioHandler {
  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> skipToQueueItem(int index) async {}

  @override
  Future<void> setSpeed(double speed) async {
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {}

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {}

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {}

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {}

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {}

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {}
}
