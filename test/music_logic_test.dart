import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/core/data/fake_db.dart';
import 'package:total_fit_gym/core/models/app_models.dart';
import 'package:total_fit_gym/features/music/data/music_api.dart';
import 'package:total_fit_gym/features/music/state/gym_player.dart';
import 'package:total_fit_gym/features/music/state/liked.dart';

Track _t(String id) => Track(
      id: id,
      title: 'T $id',
      artist: 'A',
      artwork: '',
      stream: 'https://x/$id.mp3',
      duration: const Duration(minutes: 3),
      genre: 'Pop',
    );

void main() {
  group('liked songs', () {
    testWidgets('toggle adds then removes, order preserved',
        (t) async {
      late WidgetRef ref;
      await t.pumpWidget(ProviderScope(
          child: Consumer(builder: (context, r, child) {
        ref = r;
        return const SizedBox();
      })));
      expect(toggleLike(ref, _t('1')), isTrue);
      expect(toggleLike(ref, _t('2')), isTrue);
      expect(ref.read(likedTracksProvider).keys.toList(),
          ['1', '2']);
      expect(toggleLike(ref, _t('1')), isFalse);
      expect(
          ref.read(likedTracksProvider).keys.toList(), ['2']);
    });
  });

  group('track kinds', () {
    test('isMix flags 20min+ mixes only', () {
      expect(
          _t('a')
              .copyWithTest(const Duration(minutes: 19, seconds: 59))
              .isMix,
          isFalse);
      expect(
          _t('b')
              .copyWithTest(const Duration(minutes: 20))
              .isMix,
          isTrue);
      expect(
          _t('c')
              .copyWithTest(
                  const Duration(minutes: 103, seconds: 18))
              .isMix,
          isTrue);
    });
  });

  group('player lifecycle without platform', () {
    test('stop clears queue and state, toggle/next/prev are safe', () async {
      final player = GymPlayer();
      addTearDown(player.dispose);
      // No platform calls made — all safe no-ops.
      await player.toggle();
      await player.next();
      await player.previous();
      await player.seek(const Duration(seconds: 10));
      expect(player.current, isNull);
      await player.stop();
      expect(player.queue, isEmpty);
      expect(player.playing, isFalse);
      expect(player.consumeError(), isNull);
    });
  });

  group('gym timing + rush', () {
    test('rush aggregates hours, peak found, labels format', () {
      final db = FakeDb();
      final counts = db.rushByHour();
      // Seed: 7-9 x2, 6-8, 7-8, 17-19, 18-20, 18-21
      expect(counts[7], 4); // u_active, u_expired, u_m1, u_m3
      expect(counts[18], 3); // u_expiring, u_m2, u_m4
      final peak = db.peakHour()!;
      expect(peak.hour, 7);
      expect(peak.count, 4);
      expect(FakeDb.hourLabel(7), '7 AM');
      expect(FakeDb.hourLabel(18), '6 PM');
      expect(FakeDb.hourLabel(0), '12 AM');
    });

    test('slotLabel + saveSlot round-trip', () {
      final db = FakeDb();
      db.saveSlot('u_active', 'Evening', 18, 20);
      final u = db.users['u_active']!;
      expect(u.slotLabel, 'Evening · 6 PM–8 PM');
      expect(db.membersWithSlot(), isNotEmpty);
    });

    test('membership status derives from endAt', () {
      final now = DateTime.now();
      Membership m(DateTime end) => Membership(
          uid: 'x',
          userName: 'n',
          phone: 'p',
          planId: 'pl',
          planName: 'Monthly',
          startAt: now.subtract(const Duration(days: 30)),
          endAt: end);
      expect(m(now.add(const Duration(days: 30))).status, 'active');
      expect(m(now.add(const Duration(days: 3))).status,
          'expiring_soon');
      expect(
          m(now.subtract(const Duration(days: 1))).status, 'expired');
    });
  });
}

extension on Track {
  Track copyWithTest(Duration d) => Track(
        id: id,
        title: title,
        artist: artist,
        artwork: artwork,
        stream: stream,
        duration: d,
        genre: genre,
        isFull: isFull,
      );
}
