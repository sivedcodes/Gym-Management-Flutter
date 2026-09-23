import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/music_api.dart';

/// Liked songs — session-scoped (resets on restart).
/// Map preserves the order songs were liked in.
final likedTracksProvider =
    StateProvider<Map<String, Track>>((_) => {});

/// Toggle a song's liked state. Returns true when now liked.
bool toggleLike(WidgetRef ref, Track track) {
  final map =
      Map<String, Track>.of(ref.read(likedTracksProvider));
  final liked = !map.containsKey(track.id);
  if (liked) {
    map[track.id] = track;
  } else {
    map.remove(track.id);
  }
  ref.read(likedTracksProvider.notifier).state = map;
  return liked;
}
