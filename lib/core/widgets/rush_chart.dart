import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/session.dart';
import '../data/fake_db.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'chips.dart';

/// Hourly rush chart (5 AM – 10 PM). Peak bar glows yellow, rest are
/// muted. Horizontally scrollable with equal 16px start/end margins.
/// Tap a bar to pin its exact headcount.
class RushChart extends StatefulWidget {
  final List<int> counts;
  final int? peak;
  const RushChart({super.key, required this.counts, this.peak});

  @override
  State<RushChart> createState() => _RushChartState();
}

class _RushChartState extends State<RushChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate(
      FakeDb.dayEnd - FakeDb.dayStart,
      (i) => FakeDb.dayStart + i,
    );
    final max = widget.counts.fold<int>(1, (m, c) => c > m ? c : m);
    final sel = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
            itemCount: hours.length,
            itemBuilder: (_, i) {
              final h = hours[i];
              final c = h < widget.counts.length ? widget.counts[h] : 0;
              final isPeak = widget.peak == h;
              final isSel = sel == h;
              final frac = max == 0 ? 0.0 : c / max;
              return GestureDetector(
                onTap: () => setState(() => _selected = sel == h ? null : h),
                child: Container(
                  width: 44,
                  margin: EdgeInsets.only(
                    right: i == hours.length - 1 ? 0 : AppSpace.s,
                  ),
                  decoration: isSel
                      ? BoxDecoration(
                          color: AppColors.yellow.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.s),
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$c',
                        style:
                            (isPeak || isSel
                                    ? AppText.label.copyWith(
                                        color: AppColors.yellow,
                                      )
                                    : AppText.tiny)
                                .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Expanded(
                        child: FractionallySizedBox(
                          heightFactor: (0.08 + 0.92 * frac).clamp(0.0, 1.0),
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            width: 26,
                            decoration: BoxDecoration(
                              gradient: isPeak
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD54D),
                                        Color(0xFFE0A800),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : null,
                              color: isPeak ? null : AppColors.cardHi,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7),
                              ),
                              border: Border.all(
                                color: isPeak
                                    ? AppColors.yellow
                                    : AppColors.line,
                              ),
                              boxShadow: isPeak
                                  ? [
                                      BoxShadow(
                                        color: AppColors.yellow.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        FakeDb.hourLabel(h),
                        style: AppText.tiny.copyWith(
                          fontSize: 10,
                          color: isPeak ? AppColors.yellow : AppColors.faint,
                          fontWeight: isPeak
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (sel != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.l,
              AppSpace.s,
              AppSpace.l,
              0,
            ),
            child: Text(
              '${FakeDb.hourLabel(sel)} – ${FakeDb.hourLabel(sel + 1)} · ${sel < widget.counts.length ? widget.counts[sel] : 0} member(s) in gym',
              style: AppText.small.copyWith(
                color: AppColors.yellow,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

/// Peak-rush summary line shown above the chart.
class RushSummary extends StatelessWidget {
  final int? peakHour;
  final int peakCount;
  final int total;
  const RushSummary({
    super.key,
    required this.peakHour,
    required this.peakCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (peakHour == null) {
      return Text(
        'No timings declared yet — the chart fills up as members respond.',
        style: AppText.body.copyWith(color: AppColors.grey),
      );
    }
    return RichText(
      text: TextSpan(
        style: AppText.small,
        children: [
          const TextSpan(text: 'Peak rush '),
          TextSpan(
            text:
                '${FakeDb.hourLabel(peakHour!)} – ${FakeDb.hourLabel(peakHour! + 1)}',
            style: const TextStyle(
              color: AppColors.yellow,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: ' · $peakCount member(s) · $total responded'),
        ],
      ),
    );
  }
}

/// "What is your gym timing?" dialog — session + from/to hours.
/// Used on member home (first-run nudge) and profile (edit).
Future<void> showSlotDialog(
  BuildContext context,
  WidgetRef ref, {
  String? initialSession,
  int? initialFrom,
  int? initialTo,
}) {
  var session = initialSession ?? 'Morning';
  var from = initialFrom ?? 7;
  var to = initialTo ?? 9;
  final hours = List<int>.generate(
    FakeDb.dayEnd - FakeDb.dayStart,
    (i) => FakeDb.dayStart + i,
  );

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: const Text('Your gym timing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'When do you usually train? This powers the rush chart for everyone.',
                style: AppText.body.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: AppSpace.m),
              Row(
                children: [
                  for (final s in ['Morning', 'Evening'])
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: s == 'Morning' ? AppSpace.s : 0,
                        ),
                        child: AppChoice(
                          s,
                          session == s,
                          () => setD(() => session = s),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.m),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: from,
                      decoration: const InputDecoration(
                        labelText: 'From',
                        prefixIcon: Icon(AppIcons.forward),
                      ),
                      items: hours
                          .map(
                            (h) => DropdownMenuItem(
                              value: h,
                              child: Text(FakeDb.hourLabel(h)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setD(() {
                        from = v ?? from;
                        if (to <= from) to = from + 1;
                      }),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: to,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        prefixIcon: Icon(AppIcons.forward),
                      ),
                      items:
                          List<int>.generate(
                                FakeDb.dayEnd - from,
                                (i) => from + 1 + i,
                              )
                              .map(
                                (h) => DropdownMenuItem(
                                  value: h,
                                  child: Text(FakeDb.hourLabel(h)),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setD(() => to = v ?? to),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              final uid = ref.read(currentUidProvider);
              if (uid != null) {
                ref.read(fakeDbProvider).saveSlot(uid, session, from, to);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Timing saved. Thanks!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
