import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../data/music_api.dart';
import '../state/gym_player.dart';
import '../state/liked.dart';
import 'player_bar.dart';

/// One playable track row — artwork, title, artist, play button.
/// Shared by search results, playlist detail and album detail.
class TrackRow extends ConsumerWidget {
  final Track track;
  final int index;
  final List<Track> tracks;
  const TrackRow({
    super.key,
    required this.track,
    required this.index,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(gymPlayerProvider);
    final liked = ref.watch(likedTracksProvider).containsKey(track.id);
    final isCurrent =
        player.current?.id == track.id && player.queue.length == tracks.length;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.m),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.m,
          vertical: AppSpace.xs,
        ),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.m),
              child: Image.network(
                track.artwork,
                width: AppSizes.trackArt,
                height: AppSizes.trackArt,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: AppSizes.trackArt,
                  height: AppSizes.trackArt,
                  color: AppColors.surface,
                  child: const Icon(
                    AppIcons.musicNote,
                    color: AppColors.yellow,
                  ),
                ),
              ),
            ),
            if (isCurrent && player.playing)
              Container(
                width: AppSizes.trackArt,
                height: AppSizes.trackArt,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: const Icon(
                  AppIcons.liveEq,
                  color: AppColors.yellow,
                  size: AppIcon.list,
                ),
              ),
          ],
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.title.copyWith(
            color: isCurrent ? AppColors.yellow : AppColors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpace.xs / 2),
          child: Text(
            track.artist + (track.isMix ? ' · DJ Mix' : ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.small,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: liked ? 'Unlike' : 'Like',
              icon: Icon(
                liked ? AppIcons.heart : AppIcons.heartOut,
                color: liked ? AppColors.red : AppColors.faint,
                size: AppIcon.list,
              ),
              onPressed: () {
                final nowLiked = toggleLike(ref, track);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        nowLiked
                            ? 'Added to Liked songs'
                            : 'Removed from Liked songs',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
              },
            ),
            IconButton(
              tooltip: isCurrent && player.playing ? 'Pause' : 'Play',
              icon: Icon(
                isCurrent && player.playing
                    ? AppIcons.pauseFill
                    : AppIcons.playFill,
                color: AppColors.yellow,
                size: AppSizes.mediaTile,
              ),
              onPressed: () => _play(
                ref,
                context,
                isCurrent: isCurrent,
                tracks: tracks,
                index: index,
              ),
            ),
          ],
        ),
        onTap: () {
          if (isCurrent) {
            openPlayerSheet(context);
          } else {
            _play(ref, context, isCurrent: false, tracks: tracks, index: index);
          }
        },
      ),
    );
  }
}

/// Play/toggle with one-shot error feedback. Covers every list
/// entry point (search, playlist, album, liked) in one place.
Future<void> _play(
  WidgetRef ref,
  BuildContext context, {
  required bool isCurrent,
  required List<Track> tracks,
  required int index,
}) async {
  final p = ref.read(gymPlayerProvider);
  if (isCurrent) {
    await p.toggle();
  } else {
    await p.playQueue(tracks, index);
  }
  if (!context.mounted) return;
  final err = p.consumeError();
  if (err != null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(err)));
  }
}
