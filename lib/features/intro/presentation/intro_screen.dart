import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/session.dart';
import '../../../core/data/fake_db.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';

/// Attractive Intro & About Us screen accessible before login and by members.
/// Owner can manage/edit all content (phone, address, timings, facilities, etc.).
class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.isOwner ?? false;
    final isLoggedIn = user != null;
    final gym = db.gymInfo;

    return Scaffold(
      appBar: AppBar(
        title: Text(gym.name),
        actions: [
          if (isOwner)
            TextButton.icon(
              onPressed: () => _editGymDialog(context, ref, gym),
              icon: const Icon(AppIcons.edit, size: AppIcon.sm),
              label: const Text('Edit info'),
            )
          else if (!isLoggedIn)
            TextButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(AppIcons.forward, size: AppIcon.sm),
              label: const Text('Login'),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.25,
            colors: [
              Color(0xFF221E0A),
              Color(0xFF0F0F12),
              Color(0xFF08080A),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: MaxWidth(
          maxWidth: 600,
          child: ListView(
            padding: AppSpace.screen,
            children: [
              // ── Hero Badge & Tagline ──
              FadeSlideIn(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.yellow.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.yellow.withValues(alpha: 0.16),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const GymLogo(size: 68),
                      ),
                      const SizedBox(height: AppSpace.m),
                      Text(
                        gym.name,
                        textAlign: TextAlign.center,
                        style: AppText.display.copyWith(
                          fontSize: 26,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        gym.tagline,
                        textAlign: TextAlign.center,
                        style: AppText.body.copyWith(
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardHi,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.yellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.9 Rated · 500+ Active Athletes',
                              style: AppText.tiny.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpace.l),

              // ── Primary Action (Login button if not authenticated) ──
              if (!isLoggedIn)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpace.m),
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(
                        color: AppColors.yellow.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ready to crush your fitness goals?',
                          style: AppText.title.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in with Google to explore custom splits & passes',
                          textAlign: TextAlign.center,
                          style: AppText.small.copyWith(color: AppColors.grey),
                        ),
                        const SizedBox(height: AppSpace.m),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F1F1F),
                              elevation: 4,
                              shadowColor:
                                  AppColors.yellow.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.m),
                              ),
                            ),
                            onPressed: () => context.go('/login'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const GoogleMark(size: 22),
                                const SizedBox(width: AppSpace.m),
                                Text(
                                  'Continue to Login',
                                  style: AppText.title.copyWith(
                                    color: const Color(0xFF1F1F1F),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpace.l),

              // ── About Us Overview ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: AppSpace.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconTile(AppIcons.info, size: 36),
                            const SizedBox(width: AppSpace.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('About Our Gym', style: AppText.title),
                                  Text(
                                    'Built for dedication & results',
                                    style: AppText.small,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.m),
                        Text(
                          gym.about,
                          style: AppText.body.copyWith(
                            height: 1.5,
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpace.m),

              // ── Gym Operating Shifts & Timings ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: AppSpace.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Gym Timings & Shifts'),
                        const SizedBox(height: AppSpace.m),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpace.m),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.m),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.wb_sunny_rounded,
                                          size: 18,
                                          color: AppColors.yellow,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Morning',
                                          style: AppText.label.copyWith(
                                            color: AppColors.yellow,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      gym.morningShift,
                                      style: AppText.body.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text('Peak & cardio', style: AppText.tiny),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpace.m),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpace.m),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.m),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.nightlight_round,
                                          size: 18,
                                          color: AppColors.blue,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Evening',
                                          style: AppText.label.copyWith(
                                            color: AppColors.blue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      gym.eveningShift,
                                      style: AppText.body.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text('Strength & PT', style: AppText.tiny),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.s),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 14,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Open 7 days a week including public holidays',
                              style: AppText.tiny.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpace.m),

              // ── Contact & Address Info ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: AppSpace.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Contact & Location'),
                        const SizedBox(height: AppSpace.m),
                        _ContactTile(
                          icon: AppIcons.phone,
                          title: 'Gym Phone & WhatsApp',
                          value: gym.phone,
                          actionLabel: 'Copy',
                          onAction: () {
                            Clipboard.setData(ClipboardData(text: gym.phone));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Phone copied')),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 44),
                        _ContactTile(
                          icon: Icons.location_on_outlined,
                          title: 'Gym Address',
                          value: gym.address,
                          actionLabel: 'Maps',
                          onAction: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Location: ${gym.mapsQuery}'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 44),
                        _ContactTile(
                          icon: Icons.email_outlined,
                          title: 'Official Email',
                          value: gym.email,
                          actionLabel: 'Copy',
                          onAction: () {
                            Clipboard.setData(ClipboardData(text: gym.email));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email copied')),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 44),
                        _ContactTile(
                          icon: Icons.camera_alt_outlined,
                          title: 'Instagram Handle',
                          value: gym.instagram,
                          actionLabel: 'Profile',
                          onAction: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Visit ${gym.instagram}')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpace.m),

              // ── Facilities & Amenities ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 320),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: AppSpace.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Facilities & Amenities'),
                        const SizedBox(height: AppSpace.m),
                        Wrap(
                          spacing: AppSpace.s,
                          runSpacing: AppSpace.s,
                          children: [
                            for (final f in gym.facilities)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.m),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      AppIcons.bolt,
                                      size: 14,
                                      color: AppColors.yellow,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        f,
                                        style: AppText.small.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpace.m),

              // ── Certified Coaches Preview ──
              FadeSlideIn(
                delay: const Duration(milliseconds: 380),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: AppSpace.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Certified Trainers',
                          action: 'View all',
                          onAction: () => context.push('/trainers'),
                        ),
                        const SizedBox(height: AppSpace.m),
                        for (final t in db.trainers.values.take(3)) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.yellow.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                AppIcons.trainer,
                                size: 20,
                                color: AppColors.yellow,
                              ),
                            ),
                            title: Text(t.name, style: AppText.title),
                            subtitle: Text(
                              '${t.specialization} · ${t.experienceYears}y exp',
                              style: AppText.small,
                            ),
                            trailing: Text(
                              t.shift.split('(').first.trim(),
                              style: AppText.tiny.copyWith(
                                color: AppColors.yellow,
                              ),
                            ),
                          ),
                          if (t.id != db.trainers.values.take(3).last.id)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpace.l),

              // ── Owner Quick Manage Callout ──
              if (isOwner)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 420),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _editGymDialog(context, ref, gym),
                      icon: const Icon(AppIcons.edit, size: AppIcon.btn),
                      label: const Text('Update Gym Details & Content'),
                    ),
                  ),
                )
              else if (!isLoggedIn)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 420),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.black,
                      ),
                      onPressed: () => context.go('/login'),
                      child: const Text('Ready to Join? Go to Login'),
                    ),
                  ),
                ),

              const SizedBox(height: AppSpace.l),
              const DeveloperCredit(),
              const SizedBox(height: AppSpace.m),
            ],
          ),
        ),
      ),
    );
  }

  void _editGymDialog(BuildContext context, WidgetRef ref, GymInfo current) {
    final nameCtrl = TextEditingController(text: current.name);
    final taglineCtrl = TextEditingController(text: current.tagline);
    final aboutCtrl = TextEditingController(text: current.about);
    final phoneCtrl = TextEditingController(text: current.phone);
    final emailCtrl = TextEditingController(text: current.email);
    final addressCtrl = TextEditingController(text: current.address);
    final morningCtrl = TextEditingController(text: current.morningShift);
    final eveningCtrl = TextEditingController(text: current.eveningShift);
    final facilitiesCtrl =
        TextEditingController(text: current.facilities.join(', '));
    final instaCtrl = TextEditingController(text: current.instagram);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: AppSpace.l,
          left: AppSpace.l,
          right: AppSpace.l,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Manage Gym Info', style: AppText.head),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.m),
              _sheetField('Gym Name', nameCtrl),
              const SizedBox(height: AppSpace.s),
              _sheetField('Tagline', taglineCtrl),
              const SizedBox(height: AppSpace.s),
              _sheetField('Phone Number', phoneCtrl,
                  keyboard: TextInputType.phone),
              const SizedBox(height: AppSpace.s),
              _sheetField('Email Address', emailCtrl,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: AppSpace.s),
              _sheetField('Physical Address', addressCtrl, maxLines: 2),
              const SizedBox(height: AppSpace.s),
              Row(
                children: [
                  Expanded(
                    child: _sheetField('Morning Shift', morningCtrl),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: _sheetField('Evening Shift', eveningCtrl),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s),
              _sheetField('About Gym Bio', aboutCtrl, maxLines: 3),
              const SizedBox(height: AppSpace.s),
              _sheetField(
                'Facilities (comma-separated)',
                facilitiesCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpace.s),
              _sheetField('Instagram Handle', instaCtrl),
              const SizedBox(height: AppSpace.l),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = current.copyWith(
                      name: nameCtrl.text.trim(),
                      tagline: taglineCtrl.text.trim(),
                      about: aboutCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      morningShift: morningCtrl.text.trim(),
                      eveningShift: eveningCtrl.text.trim(),
                      facilities: facilitiesCtrl.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      instagram: instaCtrl.text.trim(),
                    );
                    ref.read(fakeDbProvider).updateGymInfo(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gym details updated successfully!'),
                      ),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: AppSpace.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grey),
        fillColor: AppColors.surface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String actionLabel;
  final VoidCallback onAction;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Icon(icon, size: 18, color: AppColors.yellow),
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.small),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(40, 32),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
