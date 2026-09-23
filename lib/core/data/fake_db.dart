import 'package:flutter/foundation.dart';
import '../models/app_models.dart';

/// In-memory stand-in for RTDB. Every method mirrors a future RTDB
/// multi-path update, so swapping to Firebase later touches only this file.
///
/// Seed: 1 owner, 3 plans, 4 members (active / expiring / expired / pending).
class FakeDb extends ChangeNotifier {
  final Map<String, AppUser> users = {};
  final Map<String, GymPlan> plans = {};
  final Map<String, Registration> registrations = {};
  final Map<String, Membership> memberships = {};
  final Map<String, ServiceItem> services = {};
  final Map<String, ServiceBooking> bookings = {};
  final Map<String, WorkoutSplit> splits = {};
  final List<GymNotice> notices = [];
  int _seq = 100;

  String _next(String prefix) => '${prefix}_${_seq++}';

  FakeDb() {
    users['owner_1'] = const AppUser(
      uid: 'owner_1',
      name: 'Gym Owner',
      email: 'owner@totalfitgym.in',
      phone: '9876543210',
      role: 'owner',
    );
    plans['plan_monthly'] = const GymPlan(
      id: 'plan_monthly', name: 'Monthly', price: 1000,
      durationDays: 30, desc: 'Full access · cardio + weights',
    );
    plans['plan_quarterly'] = const GymPlan(
      id: 'plan_quarterly', name: 'Quarterly', price: 2500,
      durationDays: 90, desc: 'Most popular · save ₹500',
    );
    plans['plan_yearly'] = const GymPlan(
      id: 'plan_yearly', name: 'Yearly', price: 8000,
      durationDays: 365, desc: 'Best value · 4 months free',
    );
    final now = DateTime.now();
    void seedMember(String uid, String name, DateTime end,
        {String plan = 'Monthly',
        String session = 'Morning',
        int from = 7,
        int to = 9,
        double weight = 70,
        double height = 175,
        String goal = 'maintain',
        double? target,
        String split = 'split_ppl'}) {
      users[uid] = AppUser(
          uid: uid,
          name: name,
          email: '$uid@mail.com',
          phone: '900000000${uid.length}',
          role: 'member',
          slotSession: session,
          slotFrom: from,
          slotTo: to,
          weightKg: weight,
          heightCm: height,
          goal: goal,
          targetKg: target,
          splitId: split);
      memberships[uid] = Membership(
        uid: uid, userName: name, phone: '9000000000',
        planId: 'plan_monthly', planName: plan,
        startAt: end.subtract(const Duration(days: 30)), endAt: end,
      );
    }

    seedMember('u_active', 'Rahul Sharma', now.add(const Duration(days: 40)));
    seedMember('u_expiring', 'Amit Verma', now.add(const Duration(days: 3)),
        from: 18, to: 20, session: 'Evening');
    seedMember('u_expired', 'Sneha Patil', now.subtract(const Duration(days: 5)),
        from: 7, to: 8);
    // Extra members so the rush chart looks alive.
    seedMember('u_m1', 'Vikram Singh', now.add(const Duration(days: 12)),
        from: 6, to: 8);
    seedMember('u_m2', 'Pooja Rani', now.add(const Duration(days: 25)),
        from: 17, to: 19, session: 'Evening');
    seedMember('u_m3', 'Arjun Mehta', now.add(const Duration(days: 8)),
        from: 7, to: 9);
    seedMember('u_m4', 'Kavita Rao', now.subtract(const Duration(days: 2)),
        from: 18, to: 21, session: 'Evening');
    users['u_pending'] = const AppUser(uid: 'u_pending', name: 'New Guy', email: 'new@mail.com', phone: '9111111111');
    registrations['reg_1'] = Registration(
      id: 'reg_1', uid: 'u_pending', userName: 'New Guy', phone: '9111111111',
      planId: 'plan_monthly', planName: 'Monthly', price: 1000,
      createdAt: now.subtract(const Duration(hours: 5)),
    );
    notices.add(GymNotice(
      id: 'n0', title: 'Welcome to Total Fit Gym',
      body: 'Demo mode — Firebase connects last, all data is local for now.',
      at: now,
    ));
    // ---- dynamic programs catalog (owner-editable, zero static lists) ----
    const seedServices = [
      ServiceItem(id: 'svc_muscle', kind: 'training', title: 'Muscle Gain Pro',
          goal: 'Muscle Gain', price: 3000, durationDays: 90,
          level: 'Intermediate', desc: 'Hypertrophy splits + progressive overload coaching'),
      ServiceItem(id: 'svc_fatloss', kind: 'training', title: 'Lose Weight Fast',
          goal: 'Weight Loss', price: 2500, durationDays: 60,
          level: 'Beginner', desc: 'HIIT + cardio circuits with weekly check-ins'),
      ServiceItem(id: 'svc_gain', kind: 'training', title: 'Healthy Weight Gain',
          goal: 'Weight Gain', price: 2000, durationDays: 60,
          level: 'Beginner', desc: 'Strength base + calorie-surplus guidance'),
      ServiceItem(id: 'svc_strength', kind: 'training', title: 'Strength & Powerlifting',
          goal: 'Strength', price: 3500, durationDays: 90,
          level: 'Advanced', desc: 'SBD technique coaching + peaking blocks'),
      ServiceItem(id: 'svc_general', kind: 'training', title: 'General Fitness',
          goal: 'General Fitness', price: 0, durationDays: 30,
          level: 'All', desc: 'Free starter routine for every member'),
      ServiceItem(id: 'svc_diet_cut', kind: 'diet', title: 'Fat-Loss Diet Plan',
          goal: 'Weight Loss', price: 1500, durationDays: 30,
          level: 'All', desc: 'Personal macros + weekly diet tweaks'),
      ServiceItem(id: 'svc_diet_bulk', kind: 'diet', title: 'Muscle-Building Diet',
          goal: 'Muscle Gain', price: 1500, durationDays: 30,
          level: 'All', desc: 'High-protein Indian meal plans, veg/non-veg'),
      ServiceItem(id: 'svc_diet_free', kind: 'diet', title: 'Starter Diet Chart',
          goal: 'General Fitness', price: 0, durationDays: 7,
          level: 'All', desc: 'Free 7-day sample chart'),
      ServiceItem(id: 'svc_yoga', kind: 'yoga', title: 'Yoga & Mobility',
          goal: 'Flexibility', price: 0, durationDays: 30,
          level: 'All', desc: 'Morning mobility batches'),
    ];
    for (final s in seedServices) {
      services[s.id] = s;
    }
    // ---- default workout splits (owner-editable catalog) ----
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    WorkoutSplit split(String id, String name, String desc, String level,
        List<String> focus, Set<int> rest) {
      return WorkoutSplit(
        id: id,
        name: name,
        desc: desc,
        level: level,
        days: [
          for (var i = 0; i < 7; i++)
            SplitDay(
                day: days[i], focus: focus[i], rest: rest.contains(i)),
        ],
      );
    }

    for (final s in [
      split('split_ppl', 'Push Pull Legs', 'Strength + hypertrophy classic',
          'Intermediate', ['Push – Chest/Shoulder/Triceps', 'Pull – Back/Biceps', 'Legs – Quads/Glutes/Calves', 'Rest & recovery', 'Push – Chest/Shoulder/Triceps', 'Pull – Back/Biceps', 'Legs – Quads/Glutes/Calves'], {3}),
      split('split_bro', 'Bro Split', 'One muscle a day, maximum pump',
          'Intermediate', ['Chest + Triceps', 'Back + Biceps', 'Shoulders + Abs', 'Rest & recovery', 'Legs', 'Arms + Calves', 'Rest & recovery'], {3, 6}),
      split('split_upper_lower', 'Upper / Lower', '4 days, balanced growth',
          'Beginner', ['Upper – Push focus', 'Lower – Quad focus', 'Rest & recovery', 'Upper – Pull focus', 'Lower – Hamstrings/Glutes', 'Rest & recovery', 'Rest & recovery'], {2, 5, 6}),
      split('split_fullbody', 'Full Body 3x', 'Best for beginners',
          'Beginner', ['Full Body A', 'Rest & recovery', 'Full Body B', 'Rest & recovery', 'Full Body A', 'Rest & recovery', 'Rest & recovery'], {1, 3, 5, 6}),
      split('split_arnold', 'Arnold Split', 'Chest/Back, Shoulders/Arms, Legs',
          'Advanced', ['Chest + Back', 'Shoulders + Arms', 'Legs', 'Chest + Back', 'Shoulders + Arms', 'Legs', 'Rest & recovery'], {6}),
      split('split_5day', '5-Day Classic', 'Mon–Fri training, weekend off',
          'Intermediate', ['Chest', 'Back', 'Shoulders', 'Legs', 'Arms + Abs', 'Rest & recovery', 'Rest & recovery'], {5, 6}),
    ]) {
      splits[s.id] = s;
    }
  }

  // ---- queries ----
  List<GymPlan> activePlans() =>
      plans.values.where((p) => p.active).toList();
  List<Registration> pendingRegs() =>
      registrations.values.where((r) => r.status == 'pending').toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<Membership> membershipsSorted() {
    final list = memberships.values.toList()
      ..sort((a, b) => a.endAt.compareTo(b.endAt));
    return list;
  }

  bool hasPending(String uid) =>
      registrations.values.any((r) => r.uid == uid && r.status == 'pending');

  // ---- dynamic services ----
  /// Distinct kinds straight from data — new categories appear with no code change.
  List<String> serviceKinds({bool activeOnly = true}) {
    final kinds = <String>{};
    for (final s in services.values) {
      if (activeOnly && !s.active) continue;
      kinds.add(s.kind);
    }
    final list = kinds.toList()..sort();
    return list;
  }

  List<ServiceItem> servicesList({String? kind, bool activeOnly = true}) {
    final list = services.values.where((s) {
      if (activeOnly && !s.active) return false;
      if (kind != null && s.kind != kind) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  List<ServiceBooking> pendingServiceReqs() =>
      bookings.values.where((b) => b.status == 'pending').toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ServiceBooking> myBookings(String uid) =>
      bookings.values.where((b) => b.uid == uid).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ServiceBooking> myActivePrograms(String uid) =>
      myBookings(uid).where((b) => b.isActive).toList();

  bool hasPendingService(String uid, String serviceId) => bookings.values.any(
      (b) => b.uid == uid && b.serviceId == serviceId && b.status == 'pending');

  ServiceItem createService({
    required String kind, required String title, required String goal,
    required int price, required int durationDays,
    String level = 'All', String desc = '',
  }) {
    final id = _next('svc');
    final item = ServiceItem(
      id: id, kind: kind.trim().toLowerCase(), title: title.trim(),
      goal: goal.trim(), price: price, durationDays: durationDays,
      level: level, desc: desc.trim(),
    );
    services[id] = item;
    _push('New program: $title', '${item.kind} · ${price <= 0 ? 'Free' : '₹$price'}');
    notifyListeners();
    return item;
  }

  void updateService(ServiceItem item) {
    services[item.id] = item;
    notifyListeners();
  }

  ServiceBooking requestService(AppUser user, ServiceItem item) {
    final id = _next('bk');
    final bk = ServiceBooking(
      id: id, uid: user.uid, userName: user.name, phone: user.phone ?? '',
      serviceId: item.id, title: item.title, kind: item.kind,
      price: item.price, createdAt: DateTime.now(),
    );
    bookings[id] = bk;
    _push('${user.name} requested ${item.title}',
        '${item.kind} · ${item.isFree ? 'Free' : '₹${item.price}'} — pending approval');
    notifyListeners();
    return bk;
  }

  void approveService(String bookingId) {
    final bk = bookings[bookingId];
    if (bk == null || bk.status != 'pending') return;
    final item = services[bk.serviceId];
    final days = item?.durationDays ?? 30;
    final now = DateTime.now();
    bookings[bookingId] = ServiceBooking(
      id: bk.id, uid: bk.uid, userName: bk.userName, phone: bk.phone,
      serviceId: bk.serviceId, title: bk.title, kind: bk.kind,
      price: bk.price, status: 'approved', createdAt: bk.createdAt,
      startAt: now, endAt: now.add(Duration(days: days)),
    );
    _push('Approved: ${bk.userName}', '${bk.title} activated for $days days');
    notifyListeners();
  }

  void denyService(String bookingId, String reason) {
    final bk = bookings[bookingId];
    if (bk == null || bk.status != 'pending') return;
    bookings[bookingId] = ServiceBooking(
      id: bk.id, uid: bk.uid, userName: bk.userName, phone: bk.phone,
      serviceId: bk.serviceId, title: bk.title, kind: bk.kind,
      price: bk.price, status: 'denied', createdAt: bk.createdAt,
      reason: reason,
    );
    _push('Denied: ${bk.userName}', reason.isEmpty ? 'Request not verified' : reason);
    notifyListeners();
  }

  // ---- mutations (each notifies once) ----
  void savePhone(String uid, String phone) {
    final u = users[uid];
    if (u == null) return;
    users[uid] = u.copyWith(phone: phone, role: u.role == 'pending' ? 'member' : u.role);
    notifyListeners();
  }

  /// Full profile from the setup screen (also used for later edits).
  void saveProfile(
    String uid, {
    required String name,
    required String phone,
    required double weightKg,
    required double heightCm,
    required String goal,
    double? targetKg,
    String? splitId,
  }) {
    final u = users[uid];
    if (u == null) return;
    users[uid] = u.copyWith(
      name: name,
      phone: phone,
      role: u.role == 'pending' ? 'member' : u.role,
      weightKg: weightKg,
      heightCm: heightCm,
      goal: goal,
      targetKg: targetKg,
      splitId: splitId ?? u.splitId ?? 'split_ppl',
    );
    notifyListeners();
  }

  // ---- workout splits ----
  List<WorkoutSplit> activeSplits() =>
      splits.values.where((s) => s.active).toList();

  WorkoutSplit? splitOf(AppUser user) => splits[user.splitId];

  void upsertSplit(WorkoutSplit split) {
    splits[split.id] = split;
    notifyListeners();
  }

  void pickSplit(String uid, String splitId) {
    final u = users[uid];
    if (u == null) return;
    users[uid] = u.copyWith(splitId: splitId);
    notifyListeners();
  }

  // ---- gym timing + rush analytics ----
  /// Gym operating window (hour buckets shown on the rush chart).
  static const int dayStart = 5; // 5 AM
  static const int dayEnd = 22; // 10 PM (exclusive)

  void saveSlot(String uid, String session, int from, int to) {
    final u = users[uid];
    if (u == null) return;
    users[uid] =
        u.copyWith(slotSession: session, slotFrom: from, slotTo: to);
    notifyListeners();
  }

  /// Members (role) who declared a timing.
  List<AppUser> membersWithSlot() => users.values
      .where((u) => u.role == 'member' && u.hasSlot)
      .toList();

  /// Headcount per hour bucket across all declared timings.
  List<int> rushByHour() {
    final counts = List<int>.filled(24, 0);
    for (final u in membersWithSlot()) {
      for (var h = u.slotFrom!; h < u.slotTo!; h++) {
        if (h >= 0 && h < 24) counts[h]++;
      }
    }
    return counts;
  }

  /// Peak hour + headcount, null when nobody declared yet.
  ({int hour, int count})? peakHour() {
    final counts = rushByHour();
    var best = -1;
    var bestH = -1;
    for (var h = dayStart; h < dayEnd; h++) {
      if (counts[h] > best) {
        best = counts[h];
        bestH = h;
      }
    }
    if (best <= 0) return null;
    return (hour: bestH, count: best);
  }

  static String hourLabel(int h) {
    final hh = h % 12 == 0 ? 12 : h % 12;
    final ap = h < 12 ? 'AM' : 'PM';
    return '$hh $ap';
  }

  Registration createRegistration(AppUser user, GymPlan plan) {
    final id = _next('reg');
    final reg = Registration(
      id: id, uid: user.uid, userName: user.name,
      phone: user.phone ?? '', planId: plan.id, planName: plan.name,
      price: plan.price, createdAt: DateTime.now(),
    );
    registrations[id] = reg;
    _push('${user.name} registered', '${plan.name} · ₹${plan.price} — pending approval');
    notifyListeners();
    return reg;
  }

  void approve(String regId) {
    final reg = registrations[regId];
    if (reg == null || reg.status != 'pending') return;
    registrations[regId] = Registration(
      id: reg.id, uid: reg.uid, userName: reg.userName, phone: reg.phone,
      planId: reg.planId, planName: reg.planName, price: reg.price,
      status: 'approved', createdAt: reg.createdAt,
    );
    final plan = plans[reg.planId];
    final days = plan?.durationDays ?? 30;
    final now = DateTime.now();
    memberships[reg.uid] = Membership(
      uid: reg.uid, userName: reg.userName, phone: reg.phone,
      planId: reg.planId, planName: reg.planName,
      startAt: now, endAt: now.add(Duration(days: days)),
    );
    _push('Approved: ${reg.userName}', '${reg.planName} activated for $days days');
    notifyListeners();
  }

  void deny(String regId, String reason) {
    final reg = registrations[regId];
    if (reg == null || reg.status != 'pending') return;
    registrations[regId] = Registration(
      id: reg.id, uid: reg.uid, userName: reg.userName, phone: reg.phone,
      planId: reg.planId, planName: reg.planName, price: reg.price,
      status: 'denied', createdAt: reg.createdAt, reason: reason,
    );
    _push('Denied: ${reg.userName}', reason.isEmpty ? 'Payment not verified' : reason);
    notifyListeners();
  }

  void upsertPlan(GymPlan plan) {
    plans[plan.id] = plan;
    notifyListeners();
  }

  /// External refresh hook (e.g. mock login inserts a user directly).
  void touch() => notifyListeners();

  GymPlan createPlan(String name, int price, int days, String desc) {
    final id = _next('plan');
    final plan = GymPlan(id: id, name: name, price: price, durationDays: days, desc: desc);
    plans[id] = plan;
    notifyListeners();
    return plan;
  }

  void _push(String title, String body) {
    notices.insert(0, GymNotice(
      id: _next('n'), title: title, body: body, at: DateTime.now(),
    ));
  }
}
