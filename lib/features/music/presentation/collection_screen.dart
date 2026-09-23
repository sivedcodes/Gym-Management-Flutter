import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/motion.dart';
import '../data/music_api.dart';
import '../state/gym_player.dart';
import 'track_row.dart';

/// Playlist / album detail: header + playable track list.
/// [kind] is 'playlist' or 'album'.
class CollectionScreen extends ConsumerStatefulWidget {
  final String kind;
  final String id;
  const CollectionScreen(
      {super.key, required this.kind, required this.id});

  @override
  ConsumerState<CollectionScreen> createState() =>
      _CollectionScreenState();
}

class _CollectionScreenState
    extends ConsumerState<CollectionScreen> {
  late Future<List<Track>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Track>> _load() {
    // Header meta resolves from the first loaded track.
    return fetchCollectionTracks(MusicCollection(
      id: widget.id,
      name: '',
      artist: '',
      artwork: '',
      trackCount: 0,
      kind: widget.kind,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.kind == 'album' ? 'Album' : 'Playlist')),
      body: MaxWidth(
        child: FutureBuilder<List<Track>>(
          future: _future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: AppSpace.list,
                itemCount: 6,
                itemBuilder: (_, i) => const Padding(
                  padding:
                      EdgeInsets.only(bottom: AppSpace.m),
                  child: Skeleton(height: 72, radius: 16),
                ),
              );
            }
            if (snap.hasError || !(snap.hasData)) {
              return Center(
                child: Padding(
                  padding: AppSpace.screen,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconTile(AppIcons.offline,
                          color: AppColors.faint,
                          size: AppIcon.hero),
                      const SizedBox(height: AppSpace.m),
                      Text(
                        'Could not load this collection.\nCheck internet and retry.',
                        textAlign: TextAlign.center,
                        style: AppText.small,
                      ),
                      const SizedBox(height: AppSpace.m),
                      OutlinedButton.icon(
                        onPressed: () => setState(
                            () => _future = _load()),
                        icon: const Icon(AppIcons.refresh,
                            size: AppIcon.sm),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final tracks = snap.data!;
            if (tracks.isEmpty) {
              return Center(
                  child: Text('No tracks here yet.',
                      style: AppText.small));
            }
            // Header artist/artwork come from the first track.
            final first = tracks.first;
            return ListView.builder(
              padding: AppSpace.list,
              itemCount: tracks.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _Header(
                    artwork: first.artwork,
                    artist: first.artist,
                    count: tracks.length,
                    kind: widget.kind,
                    onPlayAll: () async {
                      final p =
                          ref.read(gymPlayerProvider);
                      await p.playQueue(tracks, 0);
                      if (!context.mounted) return;
                      final err = p.consumeError();
                      if (err != null) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                              SnackBar(content: Text(err)));
                      }
                    },
                  );
                }
                final t = tracks[i - 1];
                return FadeSlideIn(
                  delay: Duration(
                      milliseconds:
                          ((i - 1) * 40).clamp(0, 400)),
                  child: TrackRow(
                      track: t,
                      index: i - 1,
                      tracks: tracks),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String artwork;
  final String artist;
  final int count;
  final String kind;
  final VoidCallback onPlayAll;
  const _Header({
    required this.artwork,
    required this.artist,
    required this.count,
    required this.kind,
    required this.onPlayAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.l),
      padding: AppSpace.card,
      decoration: BoxDecoration(
        gradient: AppGradients.yellowCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
            color:
                AppColors.yellow.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppRadius.m),
            child: Image.network(
              artwork,
              width: AppSizes.collectionArt,
              height: AppSizes.collectionArt,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) =>
                  Container(
                width: AppSizes.collectionArt,
                height: AppSizes.collectionArt,
                color: AppColors.surface,
                child: const Icon(AppIcons.musicNote,
                    color: AppColors.yellow,
                    size: AppIcon.tile),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kind == 'album'
                      ? 'Album · Top tracks'
                      : 'Playlist',
                  style: AppText.eyebrow.copyWith(
                      color: AppColors.yellow),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(artist,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.head),
                const SizedBox(height: AppSpace.xs),
                Text('$count songs · full length',
                    style: AppText.small),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Play all',
              icon: const Icon(AppIcons.play,
                  size: AppSizes.mediaMini,
                  color: AppColors.black),
              onPressed: onPlayAll,
            ),
          ),
        ],
      ),
    );
  }
}
