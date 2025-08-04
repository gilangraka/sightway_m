// lib/shared/widgets/audio_player_widget.dart (GANTI SEMUA ISINYA)

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState? _playerState;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isCompleted => _playerState == PlayerState.completed;

  @override
  void initState() {
    super.initState();
    // Tidak perlu setSource di awal, karena play() akan melakukannya
    // _setAudioSource();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle
                    : _isCompleted
                    ? Icons.replay_circle_filled
                    : Icons.play_circle,
              ),
              iconSize: 48.0,
              onPressed: () async {
                if (_isPlaying) {
                  await _audioPlayer.pause();
                } else if (_isCompleted) {
                  // ✅ PERBAIKAN FINAL: Gunakan play(UrlSource) untuk replay
                  await _audioPlayer.play(UrlSource(widget.audioUrl));
                } else {
                  // Cek apakah source sudah di-set atau belum
                  if (_playerState == null ||
                      _playerState == PlayerState.stopped) {
                    await _audioPlayer.play(UrlSource(widget.audioUrl));
                  } else {
                    // Kondisi paused
                    await _audioPlayer.resume();
                  }
                }
              },
            ),
            Expanded(
              child: Column(
                children: [
                  Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble().clamp(
                      0.0,
                      _duration.inSeconds.toDouble(),
                    ),
                    onChanged: (value) async {
                      if (!_isCompleted) {
                        final position = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(position);
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position)),
                        Text(_formatDuration(_duration)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
