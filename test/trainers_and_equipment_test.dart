import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/core/auth/session.dart';
import 'package:total_fit_gym/core/data/fake_db.dart';
import 'package:total_fit_gym/core/models/app_models.dart';
import 'package:total_fit_gym/features/equipment/presentation/equipment_issues_screen.dart';
import 'package:total_fit_gym/features/trainers/presentation/trainers_screen.dart';

void main() {
  group('Trainers & PT batches logic', () {
    test('seed trainers loaded and queryable', () {
      final db = FakeDb();
      expect(db.trainers.isNotEmpty, isTrue);
      final list = db.trainersList();
      expect(list.length, greaterThanOrEqualTo(3));
      expect(list.first.experienceYears, greaterThanOrEqualTo(list.last.experienceYears));
    });

    test('trainer assignment and lookup roundtrip', () {
      final db = FakeDb();
      final trainerId = db.trainers.keys.first;

      // Assign new member
      db.assignMemberToTrainer(trainerId, 'test_member_1');
      expect(db.trainerOf('test_member_1')?.id, trainerId);

      // Unassign member
      db.removeMemberFromTrainer(trainerId, 'test_member_1');
      expect(db.trainerOf('test_member_1'), isNull);
    });

    test('trainer CRUD', () {
      final db = FakeDb();
      const t = GymTrainer(
        id: 'trainer_custom',
        name: 'Rohit Sharma',
        specialization: 'CrossFit',
        phone: '9988776655',
        shift: 'Morning (6 AM – 11 AM)',
        experienceYears: 5,
      );
      db.saveTrainer(t);
      expect(db.trainers['trainer_custom']?.name, 'Rohit Sharma');

      db.deleteTrainer('trainer_custom');
      expect(db.trainers['trainer_custom'], isNull);
    });
  });

  group('Equipment issues & maintenance logic', () {
    test('seed issues loaded and active count computed', () {
      final db = FakeDb();
      expect(db.equipmentIssues.isNotEmpty, isTrue);
      expect(db.activeIssueCount(), greaterThan(0));
    });

    test('report new issue and update status', () {
      final db = FakeDb();
      final newIssue = EquipmentIssue(
        id: 'eq_test',
        title: 'Spin Bike #4 Pedal Cracked',
        category: 'Cardio',
        severity: 'urgent',
        reportedByUid: 'u_active',
        reportedByName: 'Rahul',
        description: 'Right pedal broken at axle.',
        reportedAt: DateTime.now(),
      );

      db.reportIssue(newIssue);
      expect(db.equipmentIssues['eq_test']?.status, 'pending');

      // Update to in_progress
      db.updateIssueStatus('eq_test', 'in_progress');
      expect(db.equipmentIssues['eq_test']?.status, 'in_progress');

      // Resolve with note
      db.updateIssueStatus('eq_test', 'resolved', resolutionNote: 'Replaced with SPD pedal.');
      expect(db.equipmentIssues['eq_test']?.status, 'resolved');
      expect(db.equipmentIssues['eq_test']?.resolutionNote, 'Replaced with SPD pedal.');

      // Delete
      db.deleteIssue('eq_test');
      expect(db.equipmentIssues['eq_test'], isNull);
    });
  });

  group('UI Screens render test', () {
    testWidgets('TrainersScreen renders trainer list cleanly', (t) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            currentUidProvider.overrideWith((ref) => 'owner_1'),
          ],
          child: const MaterialApp(home: TrainersScreen()),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Trainers & PT'), findsOneWidget);
      expect(find.text('Trainer management'), findsOneWidget);
      expect(find.text('Vikram Rathore'), findsOneWidget);
    });

    testWidgets('EquipmentIssuesScreen renders issue cards cleanly', (t) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            currentUidProvider.overrideWith((ref) => 'u_active'),
          ],
          child: const MaterialApp(home: EquipmentIssuesScreen()),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Equipment & Repairs'), findsOneWidget);
      expect(find.text('Report Issue'), findsWidgets);
      expect(find.text('Treadmill #2 Belt Slipping'), findsOneWidget);
    });
  });
}
