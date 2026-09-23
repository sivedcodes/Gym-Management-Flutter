import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/setup_screen.dart';
import '../../features/splits/presentation/splits_screen.dart';
import '../../features/dashboard/presentation/owner_dashboard_screen.dart';
import '../../features/member/presentation/member_shell.dart';
import '../../features/notices/presentation/notices_screen.dart';
import '../../features/music/presentation/collection_screen.dart';
import '../../features/plans/presentation/plans_screen.dart';
import '../../features/registration/presentation/join_screen.dart';
import '../../features/registration/presentation/register_screen.dart';
import '../../features/services/presentation/book_service_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

enum AuthStatus { unknown, signedOut, needsPhone, member, owner }

final authStatusProvider = StateProvider<AuthStatus>((_) => AuthStatus.unknown);

final routerProvider = Provider<GoRouter>((ref) {
  final status = ref.watch(authStatusProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc.startsWith(AppConstants.joinPath)) return null;
      switch (status) {
        case AuthStatus.unknown:
          return '/';
        case AuthStatus.signedOut:
          return loc == '/login' ? null : '/login';
        case AuthStatus.needsPhone:
          return (loc == '/setup' || loc == '/login') ? null : '/setup';
        case AuthStatus.member:
          return (loc == '/' || loc == '/login' || loc == '/setup')
              ? '/home'
              : null;
        case AuthStatus.owner:
          return (loc == '/' || loc == '/login' || loc == '/setup')
              ? '/owner'
              : null;
      }
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/setup', builder: (c, s) => const SetupScreen()),
      GoRoute(path: '/splits', builder: (c, s) => const SplitsScreen()),
      GoRoute(path: '/home', builder: (c, s) => const MemberShell()),
      GoRoute(path: '/owner', builder: (c, s) => const OwnerDashboardScreen()),
      GoRoute(path: '/plans', builder: (c, s) => const PlansScreen()),
      GoRoute(
        path: '/services',
        builder: (c, s) =>
            ServicesScreen(initialKind: s.uri.queryParameters['kind']),
      ),
      GoRoute(
        path: '/services/book',
        builder: (c, s) =>
            BookServiceScreen(serviceId: s.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/register',
        builder: (c, s) => RegisterScreen(planId: s.uri.queryParameters['plan']),
      ),
      GoRoute(path: '/notices', builder: (c, s) => const NoticesScreen()),
      GoRoute(
        path: '/music/collection',
        builder: (c, s) => CollectionScreen(
          kind: s.uri.queryParameters['kind'] ?? 'playlist',
          id: s.uri.queryParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: AppConstants.joinPath,
        builder: (c, s) => JoinScreen(gymId: s.uri.queryParameters['gym']),
      ),
    ],
  );
});
