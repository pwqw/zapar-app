import 'package:app/models/models.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Stub implementation of AudioHandler para web.
/// En web, no se soportan APIs de audio nativas.
class AudioHandlerStub extends BaseAudioHandler with QueueHandler, SeekHandler {
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

  /// Custom methods from KoelAudioHandler (required by the app)
  Future<void> init({
    required dynamic playableProvider,
    required dynamic downloadProvider,
  }) async {}

  void enterRadioMode(AudioPlayer radioPlayer) {}

  void exitRadioMode() {}

  void updateRadioPlaybackState({
    required bool playing,
    required AudioProcessingState processingState,
  }) {}

  void setPlaybackPositionToState(String playableId, num position) {}

  void moveQueueItem(int oldIndex, int newIndex) {}

  Future<void> queueAndPlay(Playable playable) async {}

  Future<void> maybeQueueAndPlay(Playable playable, {position = 0}) async {}

  Future<void> queueAfterCurrent(Playable playable) async {}

  Future<bool> queued(Playable playable) async => false;

  Future<void> clearQueue() async {}

  Future<void> replaceQueue(
    List<Playable> playables, {
    int initialIndex = 0,
    bool shuffle = false,
  }) async {}

  Future<void> queueToBottom(Playable playable) async {}

  Future<void> removeFromQueue(Playable playable) async {}

  num getPlaybackPositionFromState(String playableId) => 0;
}

/// Type alias for compatibility with KoelAudioHandler naming
typedef KoelAudioHandler = AudioHandlerStub;
