import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/fake_db.dart';
import '../models/app_models.dart';
import '../routing/app_router.dart';

/// Demo session. Google Sign-In + Firebase Auth plug in here last —
/// UI only reads [currentUserProvider] + [authStatusProvider], so the
/// swap is one file.
final fakeDbProvider = ChangeNotifierProvider<FakeDb>((_) => FakeDb());

final currentUidProvider = StateProvider<String?>((_) => null);

final currentUserProvider = Provider<AppUser?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  return ref.watch(fakeDbProvider).users[uid];
});

void syncAuthStatus(WidgetRef ref) {
  final uid = ref.read(currentUidProvider);
  final ctl = ref.read(authStatusProvider.notifier);
  if (uid == null) {
    ctl.state = AuthStatus.signedOut;
    return;
  }
  final user = ref.read(fakeDbProvider).users[uid];
  if (user == null) {
    ctl.state = AuthStatus.signedOut;
    return;
  }
  // Owner needs phone only; members complete the full profile setup.
  final needsSetup = user.role == 'owner'
      ? (user.phone == null || user.phone!.isEmpty)
      : !user.hasProfile;
  if (needsSetup) {
    ctl.state = AuthStatus.needsPhone;
    return;
  }
  ctl.state = user.role == 'owner' ? AuthStatus.owner : AuthStatus.member;
}

void demoLogin(WidgetRef ref, String uid) {
  ref.read(currentUidProvider.notifier).state = uid;
  syncAuthStatus(ref);
}

/// Mock Google sign-in: creates a fresh pending user (Firebase does this last).
void mockGoogleLogin(WidgetRef ref) {
  final db = ref.read(fakeDbProvider);
  final uid = 'u_${DateTime.now().millisecondsSinceEpoch}';
  db.users[uid] = AppUser(
    uid: uid,
    name: 'Demo User ${uid.substring(uid.length - 4)}',
    email: '$uid@gmail.com',
  );
  db.touch();
  ref.read(currentUidProvider.notifier).state = uid;
  syncAuthStatus(ref);
}

void logout(WidgetRef ref) {
  ref.read(currentUidProvider.notifier).state = null;
  syncAuthStatus(ref);
}
