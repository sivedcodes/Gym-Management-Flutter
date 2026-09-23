import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../state/gym_player.dart';

String _fmt(Duration d) {
  final h = d.inHours;
  final m =
      d.inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Persistent mini player — sits above the member bottom nav.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(gymPlayerProvider);
    final t = player.current;
    if (t == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => openPlayerSheet(context),
      child: Container(
        margin: AppSpace.miniPlayer,
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardHi,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(
              color: AppColors.yellow.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                t.artwork,
                width: AppSizes.miniArt,
                height: AppSizes.miniArt,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: AppSizes.miniArt,
                  height: AppSizes.miniArt,
                  color: AppColors.surface,
                  child: const Icon(AppIcons.musicNote,
                      color: AppColors.yellow, size: AppIcon.btn),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
                  Text(t.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tiny),
                ],
              ),
            ),
            if (player.buffering)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.yellow),
              )
            else
              IconButton(
                tooltip: player.playing ? 'Pause' : 'Play',
                icon: Icon(
                  player.playing
                      ? AppIcons.pause
                      : AppIcons.play,
                  color: AppColors.yellow,
                  size: AppSizes.mediaMini,
                ),
                onPressed: () =>
                    ref.read(gymPlayerProvider).toggle(),
              ),
          ],
        ),
      ),
    );
  }
}

void openPlayerSheet(BuildContext context) {
  final player = ProviderScope.containerOf(context, listen: false)
      .read(gymPlayerProvider);
  if (player.current == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Pick a track first — choose a mood and hit play.')),
    );
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FullPlayer(),
  );
}

class _FullPlayer extends ConsumerWidget {
  const _FullPlayer();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(gymPlayerProvider);
    final t = player.current;
    if (t == null) return const SizedBox.shrink();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpace.xxl, AppSpace.m, AppSpace.xxl, AppSpace.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.25),
                  blurRadius: 48,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Image.network(
                t.artwork,
                width: AppSizes.playerArt,
                height: AppSizes.playerArt,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: AppSizes.playerArt,
                  height: AppSizes.playerArt,
                  color: AppColors.surface,
                  child: const Icon(
                      AppIcons.musicNote,
                      color: AppColors.yellow,
                      size: AppSizes.artEmpty),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Text(t.title,
              textAlign: TextAlign.center,
              style: AppText.head),
          const SizedBox(height: AppSpace.xs),
          Text(t.artist, style: AppText.small),
          const SizedBox(height: AppSpace.s),
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (_, posSnap) {
              return StreamBuilder<Duration?>(
                stream: player.durationStream,
                builder: (_, durSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final dur = durSnap.data ?? t.duration;
                  final max =
                      dur.inMilliseconds.clamp(1, 1 << 31).toDouble();
                  final val = pos.inMilliseconds
                      .clamp(0, dur.inMilliseconds)
                      .toDouble();
                  return Column(
                    children: [
                      Slider(
                        value: val,
                        max: max,
                        activeColor: AppColors.yellow,
                        inactiveColor: AppColors.line,
                        onChanged: (v) => player.seek(
                            Duration(milliseconds: v.toInt())),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(pos),
                                style: AppText.tiny),
                            Text(_fmt(dur),
                                style: AppText.tiny),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpace.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous track',
                icon: const Icon(AppIcons.prev,
                    size: AppSizes.mediaSkip, color: AppColors.grey),
                onPressed: () =>
                    ref.read(gymPlayerProvider).previous(),
              ),
              const SizedBox(width: AppSpace.m),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip:
                      player.playing ? 'Pause' : 'Play',
                  icon: Icon(
                    player.playing
                        ? AppIcons.pause
                        : AppIcons.play,
                    size: AppSizes.mediaMain,
                    color: AppColors.black,
                  ),
                  onPressed: () =>
                      ref.read(gymPlayerProvider).toggle(),
                ),
              ),
              const SizedBox(width: AppSpace.m),
              IconButton(
                tooltip: 'Next track',
                icon: const Icon(AppIcons.nextTrack,
                    size: AppSizes.mediaSkip, color: AppColors.grey),
                onPressed: () =>
                    ref.read(gymPlayerProvider).next(),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s),
          Text(
            '${t.isMix ? 'DJ MIX · ' : ''}${t.isFull ? 'Full track · Audius' : 'Preview · iTunes'} · ${player.index + 1} of ${player.queue.length}',
            style: AppText.eyebrow,
          ),
        ],
      ),
    );
  }
}
