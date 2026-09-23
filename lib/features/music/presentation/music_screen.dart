import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';
import '../data/music_api.dart';
import '../state/liked.dart';
import 'player_bar.dart';
import 'track_row.dart';

/// Gym music: search + Songs | Playlists | Albums.
/// Songs stream full-length via Audius (iTunes previews as fallback).
/// Mini player lives in the member shell; tap it for the full sheet.
class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});
  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  static const _filterLabels = [
    'Songs',
    'Playlists',
    'Albums',
    'Liked'
  ];
  int _mode = 0; // 0 songs · 1 playlists · 2 albums
  int _mood = 0;
  String _query = '';
  Timer? _debounce;
  final _searchCtrl = TextEditingController();

  late Future<List<Track>> _tracksFuture;
  Future<List<MusicCollection>>? _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _tracksFuture = fetchTracks(gymMoods[_mood].term);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _query = v.trim();
        _reload();
      });
    });
  }

  void _reload() {
    if (_mode == 0) {
      _tracksFuture = _query.isEmpty
          ? fetchTracks(gymMoods[_mood].term)
          : fetchTracks(_query);
      _collectionsFuture = null;
    } else if (_mode == 1) {
      _collectionsFuture = fetchPlaylists(_query);
    } else {
      _collectionsFuture = fetchAlbums(_query);
    }
  }

  void _pickMode(int i) {
    setState(() {
      _mode = i;
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pump it up'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final n =
                  ref.watch(likedTracksProvider).length;
              return Badge(
                label: Text('$n'),
                isLabelVisible: n > 0,
                backgroundColor: AppColors.red,
                offset: const Offset(-6, 6),
                child: IconButton(
                  icon: const Icon(AppIcons.heartOut),
                  tooltip: 'Liked songs',
                  onPressed: () {
                    _searchCtrl.clear();
                    _query = '';
                    _pickMode(3);
                  },
                ),
              );
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(AppIcons.queue),
            tooltip: 'Browse',
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppRadius.l),
              side:
                  const BorderSide(color: AppColors.line),
            ),
            onSelected: (i) => _pickMode(i),
            itemBuilder: (_) => [
              _browseMenuItem(
                  0, AppIcons.songs, 'Songs'),
              _browseMenuItem(
                  1, AppIcons.queue, 'Playlists'),
              _browseMenuItem(
                  2, AppIcons.album, 'Albums'),
            ],
          ),
          IconButton(
            icon: const Icon(AppIcons.allEq),
            tooltip: 'Now playing',
            onPressed: () => openPlayerSheet(context),
          ),
        ],
      ),
      body: MaxWidth(
        child: Column(
          children: [
            Padding(
              padding: AppSpace.filterRow,
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText:
                      'Search songs, playlists, artists…',
                  prefixIcon:
                      const Icon(AppIcons.search),
                  suffixIcon: _query.isEmpty &&
                          _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(AppIcons.close,
                              size: AppIcon.sm),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _query = '';
                              _reload();
                            });
                          },
                        ),
                ),
                onChanged: _onSearch,
                onSubmitted: (v) {
                  _debounce?.cancel();
                  setState(() {
                    _query = v.trim();
                    _reload();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.l, AppSpace.s, AppSpace.l, 0),
              child: _query.isEmpty
                  ? SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: gymMoods.length,
                        itemBuilder: (_, i) => Padding(
                          padding: EdgeInsets.only(
                              right: i == gymMoods.length - 1
                                  ? 0
                                  : AppSpace.s),
                          child: AppChoice(
                            gymMoods[i].label,
                            _mode == 0 && _mood == i,
                            () {
                              setState(() {
                                _mode = 0;
                                _mood = i;
                                _tracksFuture = fetchTracks(
                                    gymMoods[i].term);
                              });
                            },
                            icon:
                                _moodIcon(gymMoods[i].label),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection:
                            Axis.horizontal,
                        padding: EdgeInsets.zero,
                        children: [
                          for (var i = 0;
                              i < _filterLabels.length;
                              i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: i ==
                                          _filterLabels
                                                  .length -
                                              1
                                      ? 0
                                      : AppSpace.s),
                              child: AppChoice(
                                  _filterLabels[i],
                                  _mode == i,
                                  () => _pickMode(i)),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: AppSpace.s),
            Expanded(
              child: SingleChildScrollView(
                child: _mode == 0
                    ? _TracksBody(
                        future: _tracksFuture,
                        onRetry: () =>
                            setState(() => _reload()),
                      )
                    : _mode == 3
                        ? const _LikedBody()
                        : _CollectionsBody(
                        future: _collectionsFuture!,
                        kind: _mode == 1
                            ? 'playlist'
                            : 'album',
                        onRetry: () =>
                            setState(() => _reload()),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TracksBody extends StatelessWidget {
  final Future<List<Track>> future;
  final VoidCallback onRetry;
  const _TracksBody({required this.future, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Track>>(
      future: future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: AppSpace.list,
            itemCount: 6,
            itemBuilder: (_, i) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpace.m),
              child: Skeleton(height: 72, radius: 16),
            ),
          );
        }
        if (snap.hasError || !(snap.hasData)) {
          return _ErrorState(onRetry: onRetry);
        }
        final tracks = snap.data!;
        if (tracks.isEmpty) {
          return Center(
              child: Text('No tracks found.',
                  style: AppText.small));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: tracks.length,
          itemBuilder: (_, i) {
            final t = tracks[i];
            return FadeSlideIn(
              delay:
                  Duration(milliseconds: (i * 40).clamp(0, 400)),
              child: TrackRow(
                  track: t, index: i, tracks: tracks),
            );
          },
        );
      },
    );
  }
}

class _CollectionsBody extends StatelessWidget {
  final Future<List<MusicCollection>> future;
  final String kind;
  final VoidCallback onRetry;
  const _CollectionsBody(
      {required this.future,
      required this.kind,
      required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MusicCollection>>(
      future: future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: AppSpace.list,
            itemCount: 6,
            itemBuilder: (_, i) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpace.m),
              child: Skeleton(height: 72, radius: 16),
            ),
          );
        }
        if (snap.hasError || !(snap.hasData)) {
          return _ErrorState(onRetry: onRetry);
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return Center(
              child: Text('Nothing found.',
                  style: AppText.small));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final c = items[i];
            return FadeSlideIn(
              delay:
                  Duration(milliseconds: (i * 40).clamp(0, 400)),
              child: Card(
                margin: const EdgeInsets.only(
                    bottom: AppSpace.m),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                          horizontal: AppSpace.m,
                          vertical: AppSpace.xs),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        AppRadius.m),
                    child: Image.network(
                      c.artwork,
                      width: AppSizes.trackArt,
                      height: AppSizes.trackArt,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          Container(
                        width: AppSizes.trackArt,
                        height: AppSizes.trackArt,
                        color: AppColors.surface,
                        child: Icon(
                          c.kind == 'album'
                              ? AppIcons.musicNote
                              : AppIcons.queue,
                          color: AppColors.yellow,
                        ),
                      ),
                    ),
                  ),
                  title: Text(c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title.copyWith(
                          fontSize: 15)),
                  subtitle: Text(
                    c.artist.isEmpty
                        ? '${c.trackCount} songs'
                        : '${c.artist} · ${c.trackCount} songs',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small,
                  ),
                  trailing: const Icon(AppIcons.next,
                      color: AppColors.grey),
                  onTap: () => context.push(
                      '/music/collection?kind=${c.kind}&id=${c.id}'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Liked songs collection — plays, unlikes inline via TrackRow hearts.
class _LikedBody extends ConsumerWidget {
  const _LikedBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedTracksProvider).values.toList();
    if (liked.isEmpty) {
      return Padding(
        padding: AppSpace.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconTile(AppIcons.heartOut,
                color: AppColors.faint, size: AppIcon.hero),
            const SizedBox(height: AppSpace.m),
            Text('No likes yet',
                style: AppText.head.copyWith(fontSize: 17)),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Tap the heart on any song and it lands here.',
              textAlign: TextAlign.center,
              style: AppText.small,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: liked.length,
      itemBuilder: (_, i) {
        final t = liked[i];
        return FadeSlideIn(
          delay: Duration(milliseconds: (i * 40).clamp(0, 400)),
          child:
              TrackRow(track: t, index: i, tracks: liked),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpace.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconTile(AppIcons.offline,
                color: AppColors.faint, size: AppIcon.hero),
            const SizedBox(height: AppSpace.m),
            Text(
              'Music is offline right now.\nCheck internet and retry.',
              textAlign: TextAlign.center,
              style: AppText.small,
            ),
            const SizedBox(height: AppSpace.m),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(AppIcons.refresh,
                  size: AppIcon.sm),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _moodIcon(String label) => switch (label) {
      'Workout' => AppIcons.bolt,
      'Cardio' => AppIcons.heart,
      'Running' => AppIcons.cardio,
      'Motivation' => AppIcons.fire,
      'HIIT' => AppIcons.timer,
      _ => AppIcons.yoga,
    };

PopupMenuItem<int> _browseMenuItem(
    int value, IconData icon, String label) {
  return PopupMenuItem<int>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: AppIcon.btn, color: AppColors.yellow),
        const SizedBox(width: AppSpace.m),
        Text(label, style: AppText.title.copyWith(fontSize: 15)),
      ],
    ),
  );
}
