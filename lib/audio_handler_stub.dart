import 'package:app/models/models.dart';
import 'package:app/utils/preferences.dart' as preferences;
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Stub implementation of AudioHandler para web.
/// En web, no se soportan APIs de audio nativas.
class AudioHandlerStub extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  AudioPlayer get player => _player;

  var _isRadioMode = false;
  AudioPlayer? _radioPlayer;

  bool get isRadioMode => _isRadioMode;

  late AudioServiceRepeatMode repeatMode;

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
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    this.repeatMode = repeatMode;
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    await _player.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {}

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {}

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {}

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    queue.add(newQueue);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {}

  /// Custom methods from KoelAudioHandler (required by the app)
  Future<void> init({
    required dynamic playableProvider,
    required dynamic downloadProvider,
  }) async {
    repeatMode = preferences.repeatMode;
    await setVolume(preferences.volume);
  }

  void enterRadioMode(AudioPlayer radioPlayer) {
    _isRadioMode = true;
    _radioPlayer = radioPlayer;
    radioPlayer.setVolume(preferences.volume);
  }

  void exitRadioMode() {
    _isRadioMode = false;
    _radioPlayer = null;
  }

  void updateRadioPlaybackState({
    required bool playing,
    required AudioProcessingState processingState,
  }) {}

  void setPlaybackPositionToState(String playableId, num position) {}

  void moveQueueItem(int oldIndex, int newIndex) {}

  Future<void> queueAndPlay(Playable playable) async {}

  Future<void> maybeQueueAndPlay(Playable playable, {position = 0}) async {}

  Future<void> queueAfterCurrent(Playable playable) async {}

  Future<void> playOrPause() async {
    if (playbackState.value.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<bool> queued(Playable playable) async => false;

  Future<void> clearQueue() async {
    await updateQueue([]);
  }

  Future<void> replaceQueue(
    List<Playable> playables, {
    bool shuffle = false,
    bool autoPlay = true,
  }) async {}

  Future<void> queueToBottom(Playable playable) async {}

  Future<void> removeFromQueue(Playable playable) async {}

  Future<void> setVolume(double value) async {
    await _player.setVolume(value);
    await _radioPlayer?.setVolume(value);
    preferences.volume = value;
  }

  Future<AudioServiceRepeatMode> rotateRepeatMode() async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        repeatMode = AudioServiceRepeatMode.all;
        break;
      case AudioServiceRepeatMode.all:
        repeatMode = AudioServiceRepeatMode.one;
        break;
      default:
        repeatMode = AudioServiceRepeatMode.none;
        break;
    }

    preferences.repeatMode = repeatMode;
    await setRepeatMode(repeatMode);

    return repeatMode;
  }

  Future<void> cleanUpUponLogout() async {
    await _player.stop();
    await clearQueue();
  }

  num? getPlaybackPositionFromState(String playableId) => 0;
}

/// Type alias for compatibility with KoelAudioHandler naming
typedef KoelAudioHandler = AudioHandlerStub;
