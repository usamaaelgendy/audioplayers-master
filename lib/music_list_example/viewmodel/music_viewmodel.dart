import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/notifications.dart';
import 'package:audioplayers_example/music_list_example/model/music_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicViewModel = ChangeNotifierProvider.family(
  (ref, MusicModel model) => MusicViewModel(musicModel: model),
);

class MusicViewModel extends ChangeNotifier {
  MusicViewModel({required this.musicModel}) {
    _initAudioPlayer();
  }

  final MusicModel musicModel;
  late AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  PlayerState? audioPlayerState;
  Duration? durationViewModel;
  Duration? position;

  PlayerState _playerState = PlayerState.STOPPED;
  StreamSubscription? durationSubscription;
  StreamSubscription? positionSubscription;
  StreamSubscription? playerCompleteSubscription;
  StreamSubscription? playerErrorSubscription;
  StreamSubscription? playerStateSubscription;
  StreamSubscription<PlayerControlCommand>? _playerControlCommandSubscription;

  bool get isPlaying => _playerState == PlayerState.PLAYING;

  bool get isPaused => _playerState == PlayerState.PAUSED;

  String get durationText =>
      durationViewModel?.toString().split('.').first ?? '';

  String get positionText => position?.toString().split('.').first ?? '';

  void _initAudioPlayer() async {
    durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      durationViewModel = duration;
      notifyListeners();

      /// TODO :
      // if (Theme.of(Getx.Get.context!).platform == TargetPlatform.iOS) {
      //   // optional: listen for notification updates in the background
      //   audioPlayer.notificationService.startHeadlessService();
      //
      //   // set at least title to see the notification bar on ios.
      //   audioPlayer.notificationService.setNotification(
      //     // title: 'App Name',
      //     // artist: 'Artist or blank',
      //     // albumTitle: 'Name or blank',
      //     imageUrl: 'Image URL or blank',
      //     forwardSkipInterval: const Duration(seconds: 30),
      //     // default is 30s
      //     backwardSkipInterval: const Duration(seconds: 30),
      //     // default is 30s
      //     duration: duration,
      //     enableNextTrackButton: true,
      //     enablePreviousTrackButton: true,
      //   );
      // }
    });

    positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      position = p;
      notifyListeners();
    });

    playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((event) {
      onComplete();
      position = durationViewModel;
      notifyListeners();
    });

    playerErrorSubscription = audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');

      _playerState = PlayerState.STOPPED;
      durationViewModel = const Duration();
      position = const Duration();
      notifyListeners();
    });

    _playerControlCommandSubscription =
        audioPlayer.notificationService.onPlayerCommand.listen((command) {
      print('command: $command');
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        audioPlayerState = state;
        notifyListeners();
      });
    });

    audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        audioPlayerState = state;
        notifyListeners();
      });
    });
  }

  Future<int> play() async {
    final playPosition = (position != null &&
            durationViewModel != null &&
            position!.inMilliseconds > 0 &&
            position!.inMilliseconds < durationViewModel!.inMilliseconds)
        ? position
        : null;
    final result =
        await audioPlayer.play(musicModel.url, position: playPosition);
    if (result == 1) {
      _playerState = PlayerState.PLAYING;
      notifyListeners();
    }

    return result;
  }

  Future<int> pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) {
      _playerState = PlayerState.PAUSED;
      notifyListeners();
    }
    return result;
  }

  Future<int> stop() async {
    final result = await audioPlayer.stop();
    if (result == 1) {
      _playerState = PlayerState.STOPPED;
      position = const Duration();
      notifyListeners();
    }
    return result;
  }

  void onComplete() {
    _playerState = PlayerState.STOPPED;
    notifyListeners();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerErrorSubscription?.cancel();
    playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }
}
