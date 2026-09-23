import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/audio/audio_stub.dart'
    if (dart.library.js_interop) 'core/audio/audio_web.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Total Fit Gym — Android + Web (iOS served via Web).
/// Stack: Firebase Auth (Google) + RTDB + FCM. No other backend.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    registerAudioWeb();
  }
  // Milestone 2: await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: TotalFitGymApp()));
}

class TotalFitGymApp extends ConsumerWidget {
  const TotalFitGymApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
