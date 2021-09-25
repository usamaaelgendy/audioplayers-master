import 'package:audioplayers_example/music_list_example/model/music_model.dart';
import 'package:audioplayers_example/music_list_example/viewmodel/music_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerWidget extends ConsumerWidget {
  final MusicModel musicModel;

  const PlayerWidget({
    Key? key,
    required this.musicModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final viewModel = watch(musicViewModel(musicModel));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: viewModel.isPlaying ? null : viewModel.play,
              iconSize: 64.0,
              icon: const Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: viewModel.isPlaying ? viewModel.pause : null,
              iconSize: 64.0,
              icon: const Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: viewModel.isPlaying || viewModel.isPaused
                  ? viewModel.stop
                  : null,
              iconSize: 64.0,
              icon: const Icon(Icons.stop),
              color: Colors.cyan,
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Slider(
                    onChanged: (v) {
                      final duration = viewModel.durationViewModel;
                      if (duration == null) {
                        return;
                      }
                      final Position = v * duration.inMilliseconds;
                      viewModel.audioPlayer
                          .seek(Duration(milliseconds: Position.round()));
                    },
                    value: (viewModel.position != null &&
                            viewModel.durationViewModel != null &&
                            viewModel.position!.inMilliseconds > 0 &&
                            viewModel.position!.inMilliseconds <
                                viewModel.durationViewModel!.inMilliseconds)
                        ? viewModel.position!.inMilliseconds /
                            viewModel.durationViewModel!.inMilliseconds
                        : 0.0,
                  ),
                ],
              ),
            ),
            Text(
              viewModel.position != null
                  ? '${viewModel.positionText} / ${viewModel.durationText}'
                  : viewModel.durationViewModel != null
                      ? viewModel.durationText
                      : '',
              style: const TextStyle(fontSize: 24.0),
            ),
          ],
        ),
        Text('State: ${viewModel.audioPlayerState}'),
      ],
    );
  }
}
