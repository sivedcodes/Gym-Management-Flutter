/// Central app constants — no magic strings in UI/logic.
abstract final class AppConstants {
  static const String appName = 'Total Fit Gym';
  static const String org = 'com.totalfitgym';

  // RTDB top-level nodes (logical plan, see PROJECT_BLUEPRINT.md §13)
  static const String nodeUsers = 'users';
  static const String nodePlans = 'plans';
  static const String nodeRegistrations = 'registrations';
  static const String nodeMemberships = 'memberships';
  static const String nodeDevices = 'devices';
  static const String nodeMeta = 'meta';

  // Roles
  static const String roleOwner = 'owner';
  static const String roleMember = 'member';
  static const String rolePending = 'pending';

  // Registration status
  static const String regPending = 'pending';
  static const String regApproved = 'approved';
  static const String regDenied = 'denied';

  // Membership status
  static const String memActive = 'active';
  static const String memExpiring = 'expiring_soon';
  static const String memExpired = 'expired';

  // Deep-link for QR: https://<host>/join?gym=<gymId>
  static const String joinPath = '/join';
}
