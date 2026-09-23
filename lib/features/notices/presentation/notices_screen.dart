import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_views.dart';

/// Notification inbox (FCM plugs in last; FakeDb logs here).
class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(fakeDbProvider).notices;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: MaxWidth(
        child: notices.isEmpty
            ? const EmptyView(
                icon: AppIcons.bell,
                title: 'No notifications yet',
                subtitle:
                    'Membership approvals and expiry reminders appear here.',
              )
            : ListView.builder(
                padding: AppSpace.list,
                itemCount: notices.length,
                itemBuilder: (_, i) {
                  final n = notices[i];
                  final approved = n.title.startsWith('Approved');
                  return FadeSlideIn(
                    delay: Duration(milliseconds: i * 50),
                    child: Card(
                      margin:
                          const EdgeInsets.only(bottom: AppSpace.s),
                      child: ListTile(
                        leading: IconTile(
                          approved
                              ? AppIcons.approved
                              : n.title.startsWith('Denied')
                                  ? AppIcons.denied
                                  : AppIcons.bell,
                          color: approved
                              ? AppColors.green
                              : n.title.startsWith('Denied')
                                  ? AppColors.red
                                  : AppColors.yellow,
                          size: AppIcon.tile,
                        ),
                        title: Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title),
                        subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.small),
                        trailing: Text(
                          DateFormat('dd MMM\nhh:mm a').format(n.at),
                          textAlign: TextAlign.right,
                          style: AppText.tiny,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
