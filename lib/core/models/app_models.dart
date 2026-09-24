// Domain models. Field names mirror future RTDB nodes so Firebase
// plug-in later is a data-source swap, not a UI rewrite.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role; // owner | member | pending
  // Preferred gym timing (member-declared, drives rush analytics).
  final String? slotSession; // Morning | Evening
  final int? slotFrom; // hour 0-23
  final int? slotTo; // hour 0-23 (exclusive)
  // Body profile (setup screen, editable later).
  final double? weightKg;
  final double? heightCm;
  final String? goal; // gain | loss | maintain
  final double? targetKg; // kg to gain/lose (null for maintain)
  final String? splitId; // chosen workout split
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'pending',
    this.slotSession,
    this.slotFrom,
    this.slotTo,
    this.weightKg,
    this.heightCm,
    this.goal,
    this.targetKg,
    this.splitId,
  });

  bool get hasSlot => slotSession != null && slotFrom != null && slotTo != null;

  /// Profile is complete when phone + body stats exist (owner: phone only).
  bool get hasProfile =>
      (phone ?? '').isNotEmpty && weightKg != null && heightCm != null;

  /// Body Mass Index, null until weight+height are known.
  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm! <= 0) {
      return null;
    }
    final m = heightCm! / 100;
    return weightKg! / (m * m);
  }

  static String bmiCategory(double bmi) => switch (bmi) {
    < 18.5 => 'Underweight',
    < 25 => 'Normal',
    < 30 => 'Overweight',
    _ => 'Obese',
  };

  /// Height display in feet/inches (input unit), e.g. `5 ft 9 in`.
  String get heightLabel {
    if (heightCm == null) return '—';
    final totalIn = (heightCm! / 2.54).round();
    return '${totalIn ~/ 12} ft ${totalIn % 12} in';
  }

  /// Feet/inches → cm (setup screen input conversion).
  static double ftInToCm(int ft, int inch) => (ft * 12 + inch) * 2.54;

  /// cm → [feet, inches] for prefilling the setup form.
  static List<int> cmToFtIn(double cm) {
    final totalIn = (cm / 2.54).round();
    return [totalIn ~/ 12, totalIn % 12];
  }

  String get slotLabel {
    if (!hasSlot) return 'Not set';
    String h(int v) {
      final hh = v % 12 == 0 ? 12 : v % 12;
      final ap = v < 12 ? 'AM' : 'PM';
      return '$hh $ap';
    }

    return '$slotSession · ${h(slotFrom!)}–${h(slotTo!)}';
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? slotSession,
    int? slotFrom,
    int? slotTo,
    double? weightKg,
    double? heightCm,
    String? goal,
    double? targetKg,
    String? splitId,
  }) => AppUser(
    uid: uid,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    slotSession: slotSession ?? this.slotSession,
    slotFrom: slotFrom ?? this.slotFrom,
    slotTo: slotTo ?? this.slotTo,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    goal: goal ?? this.goal,
    targetKg: targetKg ?? this.targetKg,
    splitId: splitId ?? this.splitId,
  );
}

/// One day inside a workout split.
class SplitDay {
  final String day; // Mon..Sun
  final String focus; // e.g. Push – Chest/Shoulders/Triceps
  final bool rest;
  const SplitDay({required this.day, required this.focus, this.rest = false});
}

/// Weekly workout split (Push Pull Legs, Bro Split…).
/// Owner-managed catalog; members pick one and follow the weekly chart.
class WorkoutSplit {
  final String id;
  final String name;
  final String desc;
  final String level;
  final List<SplitDay> days; // 7 entries Mon..Sun
  final bool active;
  const WorkoutSplit({
    required this.id,
    required this.name,
    required this.desc,
    this.level = 'All',
    required this.days,
    this.active = true,
  });

  /// Today's entry (Mon=1..Sun=7).
  SplitDay get today => days[DateTime.now().weekday - 1];

  WorkoutSplit copyWith({
    String? name,
    String? desc,
    String? level,
    List<SplitDay>? days,
    bool? active,
  }) => WorkoutSplit(
    id: id,
    name: name ?? this.name,
    desc: desc ?? this.desc,
    level: level ?? this.level,
    days: days ?? this.days,
    active: active ?? this.active,
  );
}

class GymPlan {
  final String id;
  final String name;
  final int price;
  final int durationDays;
  final String desc;
  final bool active;
  const GymPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.desc,
    this.active = true,
  });

  GymPlan copyWith({
    String? name,
    int? price,
    int? durationDays,
    String? desc,
    bool? active,
  }) => GymPlan(
    id: id,
    name: name ?? this.name,
    price: price ?? this.price,
    durationDays: durationDays ?? this.durationDays,
    desc: desc ?? this.desc,
    active: active ?? this.active,
  );
}

class Registration {
  final String id;
  final String uid;
  final String userName;
  final String phone;
  final String planId;
  final String planName;
  final int price;
  final String status; // pending | approved | denied
  final DateTime createdAt;
  final String? reason;
  const Registration({
    required this.id,
    required this.uid,
    required this.userName,
    required this.phone,
    required this.planId,
    required this.planName,
    required this.price,
    this.status = 'pending',
    required this.createdAt,
    this.reason,
  });
}

class Membership {
  final String uid;
  final String userName;
  final String phone;
  final String planId;
  final String planName;
  final DateTime startAt;
  final DateTime endAt;
  const Membership({
    required this.uid,
    required this.userName,
    required this.phone,
    required this.planId,
    required this.planName,
    required this.startAt,
    required this.endAt,
  });

  int get daysLeft => endAt.difference(DateTime.now()).inDays;

  /// active | expiring_soon (<=7d) | expired
  String get status {
    final d = endAt.difference(DateTime.now());
    if (d.isNegative) return 'expired';
    if (d.inDays <= 7) return 'expiring_soon';
    return 'active';
  }
}

/// In-app stand-in for FCM messages (real FCM plugs in last).
class GymNotice {
  final String id;
  final String title;
  final String body;
  final DateTime at;
  const GymNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
  });
}

/// Dynamic add-on catalog: training, diet, or ANY owner-created kind.
/// New categories need zero code change — kind is data, not an enum.
class ServiceItem {
  final String id;
  final String kind; // e.g. training | diet | yoga …
  final String title;
  final String goal; // e.g. muscle_gain | weight_loss | …
  final int price; // 0 = free
  final int durationDays;
  final String level; // All | Beginner | Intermediate | Advanced
  final String desc;
  final bool active;
  const ServiceItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.goal,
    this.price = 0,
    required this.durationDays,
    this.level = 'All',
    this.desc = '',
    this.active = true,
  });

  bool get isFree => price <= 0;

  ServiceItem copyWith({
    String? kind,
    String? title,
    String? goal,
    int? price,
    int? durationDays,
    String? level,
    String? desc,
    bool? active,
  }) => ServiceItem(
    id: id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    goal: goal ?? this.goal,
    price: price ?? this.price,
    durationDays: durationDays ?? this.durationDays,
    level: level ?? this.level,
    desc: desc ?? this.desc,
    active: active ?? this.active,
  );
}

/// Member request for a service. Approved → active program window.
class ServiceBooking {
  final String id;
  final String uid;
  final String userName;
  final String phone;
  final String serviceId;
  final String title;
  final String kind;
  final int price;
  final String status; // pending | approved | denied
  final DateTime createdAt;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? reason;
  const ServiceBooking({
    required this.id,
    required this.uid,
    required this.userName,
    required this.phone,
    required this.serviceId,
    required this.title,
    required this.kind,
    required this.price,
    this.status = 'pending',
    required this.createdAt,
    this.startAt,
    this.endAt,
    this.reason,
  });

  bool get isActive =>
      status == 'approved' &&
      endAt != null &&
      !endAt!.difference(DateTime.now()).isNegative;
}

/// Certified gym trainer & PT coach.
class GymTrainer {
  final String id;
  final String name;
  final String specialization; // Strength & Conditioning, Fat Loss & HIIT, etc.
  final String phone;
  final String shift; // Morning | Evening | Full Day
  final String bio;
  final int experienceYears;
  final bool active;
  final List<String> clientUids; // assigned member UIDs

  const GymTrainer({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    required this.shift,
    this.bio = '',
    this.experienceYears = 3,
    this.active = true,
    this.clientUids = const [],
  });

  GymTrainer copyWith({
    String? name,
    String? specialization,
    String? phone,
    String? shift,
    String? bio,
    int? experienceYears,
    bool? active,
    List<String>? clientUids,
  }) => GymTrainer(
    id: id,
    name: name ?? this.name,
    specialization: specialization ?? this.specialization,
    phone: phone ?? this.phone,
    shift: shift ?? this.shift,
    bio: bio ?? this.bio,
    experienceYears: experienceYears ?? this.experienceYears,
    active: active ?? this.active,
    clientUids: clientUids ?? this.clientUids,
  );
}

/// Gym equipment breakdown or maintenance report.
class EquipmentIssue {
  final String id;
  final String title;
  final String category; // Cardio | Strength | Free Weights | Amenities
  final String severity; // low | medium | urgent
  final String reportedByUid;
  final String reportedByName;
  final String description;
  final String status; // pending | in_progress | resolved
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  const EquipmentIssue({
    required this.id,
    required this.title,
    required this.category,
    required this.severity,
    required this.reportedByUid,
    required this.reportedByName,
    required this.description,
    this.status = 'pending',
    required this.reportedAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  EquipmentIssue copyWith({
    String? title,
    String? category,
    String? severity,
    String? description,
    String? status,
    DateTime? resolvedAt,
    String? resolutionNote,
  }) => EquipmentIssue(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    severity: severity ?? this.severity,
    reportedByUid: reportedByUid,
    reportedByName: reportedByName,
    description: description ?? this.description,
    status: status ?? this.status,
    reportedAt: reportedAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    resolutionNote: resolutionNote ?? this.resolutionNote,
  );
}

