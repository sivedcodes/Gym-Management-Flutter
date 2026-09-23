import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../data/music_api.dart';

/// App-wide gym music player. Queue = current mood's tracks.
///
/// Lifecycle guarantees:
/// - Platform player is created lazily on first play (app startup
///   never touches the audio plugin — web-safe).
/// - Rapid play taps are serialized via a generation guard: only the
///   latest request drives the player.
/// - Every platform call is guarded; failures land in [error] and
///   never crash the UI.
/// - [stop] clears the queue (used on logout so no ghost playback
///   survives without UI).
/// - just_audio auto-advances through the queue; the end of the
///   queue surfaces as paused-at-end (normal player behavior).
class GymPlayer extends ChangeNotifier {
  AudioPlayer? _p;
  List<StreamSubscription> _subs = [];
  List<Track> queue = [];
  int index = -1;
  bool playing = false;
  bool buffering = false;
  String? error;
  int _gen = 0;

  AudioPlayer _ensure() {
    final existing = _p;
    if (existing != null) return existing;
    final p = AudioPlayer();
    _p = p;
    _subs = [
      p.playerStateStream.listen((s) {
        playing = s.playing;
        buffering = s.processingState == ProcessingState.loading ||
            s.processingState == ProcessingState.buffering;
        notifyListeners();
      }),
      p.currentIndexStream.listen((i) {
        if (i != null && i != index) {
          index = i;
          notifyListeners();
        }
      }),
    ];
    return p;
  }

  Stream<Duration> get positionStream =>
      _p?.positionStream ?? const Stream.empty();
  Stream<Duration?> get durationStream =>
      _p?.durationStream ?? const Stream.empty();

  Track? get current =>
      (index >= 0 && index < queue.length) ? queue[index] : null;

  Future<void> playQueue(List<Track> tracks, int start) async {
    final g = ++_gen;
    error = null;
    try {
      queue = tracks;
      index = start;
      notifyListeners();
      final src = tracks
          .map((t) => AudioSource.uri(Uri.parse(t.stream)))
          .toList();
      await _ensure().setAudioSources(src,
          initialIndex: start, initialPosition: Duration.zero);
      if (g != _gen) return; // superseded by a newer request
      await _p!.play();
    } catch (_) {
      if (g != _gen) return;
      error = 'Could not play this track. Check internet and retry.';
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    final p = _p;
    if (p == null || current == null) return;
    try {
      if (playing) {
        await p.pause();
      } else {
        await p.play();
      }
    } catch (_) {
      error = 'Playback hit a snag. Try again.';
      notifyListeners();
    }
  }

  Future<void> next() async {
    final p = _p;
    try {
      if (p != null && p.hasNext) await p.seekToNext();
    } catch (_) {
      error = 'Could not skip. Try again.';
      notifyListeners();
    }
  }

  Future<void> previous() async {
    final p = _p;
    try {
      if (p != null && p.hasPrevious) await p.seekToPrevious();
    } catch (_) {
      error = 'Could not go back. Try again.';
      notifyListeners();
    }
  }

  Future<void> seek(Duration d) async {
    try {
      await _p?.seek(d);
    } catch (_) {
      // Slider scrub during buffering — safely ignored.
    }
  }

  /// Full stop + queue clear. Called on logout.
  Future<void> stop() async {
    _gen++;
    try {
      await _p?.stop();
    } catch (_) {}
    queue = [];
    index = -1;
    playing = false;
    buffering = false;
    error = null;
    notifyListeners();
  }

  /// Read-and-clear the pending error (for one-shot snackbars).
  String? consumeError() {
    final e = error;
    error = null;
    return e;
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _p?.dispose();
    super.dispose();
  }
}

final gymPlayerProvider =
    ChangeNotifierProvider<GymPlayer>((_) => GymPlayer());
