import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/member_home_screen.dart';
import '../../music/presentation/music_screen.dart';
import '../../music/presentation/player_bar.dart';
import '../../services/presentation/services_screen.dart';
import '../../../core/widgets/glow_nav.dart';
import 'profile_screen.dart';

/// Active member tab — home shortcuts can jump straight to Music/Programs.
final memberTabProvider = StateProvider<int>((_) => 0);

/// Member bottom-nav shell: Home · Programs · Music · Profile.
/// Mini music player floats above the nav when a track is active.
class MemberShell extends ConsumerStatefulWidget {
  const MemberShell({super.key});
  @override
  ConsumerState<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends ConsumerState<MemberShell> {
  static const _pages = [
    MemberHomeScreen(),
    ServicesScreen(),
    MusicScreen(),
    ProfileScreen(),
  ];

  static const _nav = [
    GlowNavItem(
        icon: AppIcons.home,
        activeIcon: AppIcons.homeActive,
        label: 'Home'),
    GlowNavItem(
        icon: AppIcons.programs,
        activeIcon: AppIcons.training,
        label: 'Programs'),
    GlowNavItem(
        icon: AppIcons.music,
        activeIcon: AppIcons.headphones,
        label: 'Music'),
    GlowNavItem(
        icon: AppIcons.profile,
        activeIcon: AppIcons.profileActive,
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(memberTabProvider);
    return Scaffold(
      body: IndexedStack(index: tab, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          GlowNav(
            index: tab,
            items: _nav,
            onTap: (i) =>
                ref.read(memberTabProvider.notifier).state = i,
          ),
        ],
      ),
    );
  }
}
