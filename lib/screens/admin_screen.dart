import 'package:flutter/material.dart';

import '../models/admin_activity_item.dart';
import '../models/app_user.dart';
import '../models/post_item.dart';
import '../models/report_item.dart';
import 'post_details_screen.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import 'login_screen.dart';
import 'message_detail_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SafeMindUser?>(
      stream: SafeMindBackend.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (user == null) {
          return const LoginScreen();
        }

                if (user.role != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin Dashboard')),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: SectionCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, size: 40, color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('Admin access required', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        Text('This dashboard is available only for accounts with the admin role. Ask your Firebase admin to set your user document role to admin.'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Admin Dashboard'),
              actions: [
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign out?'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await SafeMindBackend.instance.signOut();
                      // Ensure the user lands on the login screen and clear navigation stack
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Reports'),
                  Tab(text: 'Users'),
                  Tab(text: 'Messages'),
                  Tab(text: 'Activity'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                _OverviewTab(),
                _ReportsTab(),
                _UsersTab(),
                _MessagesTab(),
                _ActivityTab(),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                // Open an admin tools sheet with common quick actions
                showModalBottomSheet<void>(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin tools', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ListTile(
                          leading: const Icon(Icons.download_outlined),
                          title: const Text('Export reports (CSV)'),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export started (demo)')));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.book_outlined),
                          title: const Text('Open moderation docs'),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening docs (demo)')));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.close),
                          title: const Text('Close'),
                          onTap: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Tools'),
            ),
          ),
        );
      },
    );
  }
}

Future<bool?> _confirm(BuildContext context, String title, String message) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
      ],
    ),
  );
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SafeMindUser>>(
      stream: SafeMindBackend.instance.watchUsers(),
      builder: (context, usersSnapshot) {
        final users = usersSnapshot.data ?? const <SafeMindUser>[];
        return StreamBuilder<List<SafeMindPost>>(
          stream: SafeMindBackend.instance.watchPosts(),
          builder: (context, postsSnapshot) {
            final posts = postsSnapshot.data ?? const <SafeMindPost>[];
            return StreamBuilder<List<SafeMindReport>>(
              stream: SafeMindBackend.instance.watchReports(),
              builder: (context, reportsSnapshot) {
                final reports = reportsSnapshot.data ?? const <SafeMindReport>[];
                return StreamBuilder<List<SafeMindAdminActivity>>(
                  stream: SafeMindBackend.instance.watchActivity(),
                  builder: (context, activitySnapshot) {
                    final activity = activitySnapshot.data ?? const <SafeMindAdminActivity>[];
                    final openReports = reports.where((report) => report.status == 'open').length;
                    final advisorCount = users.where((user) => user.role == 'advisor').length;
                    final adminCount = users.where((user) => user.role == 'admin').length;
                    final recentUsers = users.where((user) => user.joinedAt != null && DateTime.now().difference(user.joinedAt!).inDays <= 30).length;
                    final growth = users.isEmpty ? 0 : ((recentUsers / users.length) * 100).round();

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Admin overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              const Text('Monitor platform health, open reports, and moderation activity from one place.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatCard(label: 'Total users', value: users.length.toString(), icon: Icons.people_outline, color: AppColors.secondary),
                            _StatCard(label: 'Active posts', value: posts.length.toString(), icon: Icons.message_outlined, color: AppColors.primary),
                            _StatCard(label: 'Open reports', value: openReports.toString(), icon: Icons.warning_amber_outlined, color: AppColors.danger),
                            _StatCard(label: 'Advisor staff', value: advisorCount.toString(), icon: Icons.verified_outlined, color: const Color(0xFF9B7E5C)),
                            _StatCard(label: 'Admin accounts', value: adminCount.toString(), icon: Icons.shield_outlined, color: AppColors.primary),
                            _StatCard(label: '30-day growth', value: '+$growth%', icon: Icons.trending_up, color: AppColors.secondary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recent activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 16),
                              if (activity.isEmpty)
                                const Text('No activity yet.')
                              else
                                ...activity.take(5).map((entry) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _ActivityRow(entry: entry),
                                    )),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SafeMindReport>>(
      stream: SafeMindBackend.instance.watchReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? const <SafeMindReport>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reports queue', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Review harmful content, remove violations, and resolve reports once action is taken.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (reports.isEmpty)
              const SectionCard(child: Text('No reports yet.'))
            else
              ...reports.map((report) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportCard(report: report),
                  )),
          ],
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SafeMindUser>>(
      stream: SafeMindBackend.instance.watchUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? const <SafeMindUser>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User management', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Promote trusted advisors, restrict abusive accounts, and keep the moderation team current.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (users.isEmpty)
              const SectionCard(child: Text('No users available.'))
            else
              ...users.map((user) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _UserCard(user: user),
                  )),
          ],
        );
      },
    );
  }
}

class _MessagesTab extends StatefulWidget {
  const _MessagesTab();

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SafeMindUser?>(
      stream: SafeMindBackend.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        final currentUser = userSnapshot.data;
        if (currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<SafeMindUser>>(
          stream: SafeMindBackend.instance.watchUsers(),
          builder: (context, usersSnapshot) {
            final allUsers = usersSnapshot.data ?? const <SafeMindUser>[];
            // Filter out current admin and anonymous users
            final users = allUsers.where((u) => u.id != currentUser.id && !u.isAnonymous && !u.isBanned).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin messaging', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('Send private messages to users for moderation alerts, support, or important announcements.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (users.isEmpty)
                  const SectionCard(child: Text('No users available to message.'))
                else
                  ...users.map((user) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AdminMessageCard(
                      user: user,
                      adminUser: currentUser,
                    ),
                  )),
              ],
            );
          },
        );
      },
    );
  }
}

class _AdminMessageCard extends StatelessWidget {
  const _AdminMessageCard({
    required this.user,
    required this.adminUser,
  });

  final SafeMindUser user;
  final SafeMindUser adminUser;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email ?? 'No email',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final conversationId = _makeConversationId(adminUser.id, user.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageDetailScreen(
                          conversationId: conversationId,
                          otherUserId: user.id,
                          otherUserName: user.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Send message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _makeConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'conv-${ids[0]}-${ids[1]}';
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SafeMindAdminActivity>>(
      stream: SafeMindBackend.instance.watchActivity(),
      builder: (context, snapshot) {
        final activity = snapshot.data ?? const <SafeMindAdminActivity>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Audit log', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Track moderation and platform actions for accountability.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (activity.isEmpty)
              const SectionCard(child: Text('No activity recorded.'))
            else
              ...activity.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActivityRow(entry: entry),
                  )),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 18),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final SafeMindReport report;

  @override
  Widget build(BuildContext context) {
    final severity = _severityColor(report.severity);
    final statusColor = report.status == 'resolved' ? AppColors.secondary : AppColors.danger;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: severity.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_outlined, color: severity),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${report.targetType.toUpperCase()} • ${report.reason}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Reported by ${report.reporterName} • ${_formatTime(report.createdAt)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 6),
                    Text(report.targetAuthorName == null ? 'Target: ${report.targetId}' : 'Target: ${report.targetAuthorName} (${report.targetId})', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Pill(label: report.severity, background: severity.withValues(alpha: 0.14), foreground: severity),
                  const SizedBox(height: 8),
                  _Pill(label: report.status, background: statusColor.withValues(alpha: 0.14), foreground: statusColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  // view target if possible
                  if (report.targetType == 'post') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: report.targetId)));
                    return;
                  }
                  final ok = await _confirm(context, 'Mark Reviewed', 'Mark this report as reviewed?');
                  if (!context.mounted) return;
                  if (ok == true) {
                    await _run(context, () => SafeMindBackend.instance.resolveReport(report.id, action: 'Report reviewed', detail: report.reason), 'Report marked as reviewed');
                  }
                },
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View / Review'),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final ok = await _confirm(context, 'Remove Target', 'Remove the reported content permanently?');
                  if (!context.mounted) return;
                  if (ok == true) {
                    await _run(context, () => SafeMindBackend.instance.moderateReportedTarget(report, action: 'remove'), 'Target removed');
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove'),
              ),
              OutlinedButton.icon(
                onPressed: report.targetAuthorId == null
                    ? null
                    : () async {
                        final ok = await _confirm(context, 'Ban User', 'Ban this user and remove their content?');
                        if (!context.mounted) return;
                        if (ok == true) {
                          await _run(context, () => SafeMindBackend.instance.moderateReportedTarget(report, action: 'ban'), 'User banned');
                        }
                      },
                icon: const Icon(Icons.block_outlined, size: 18),
                label: const Text('Ban User'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final SafeMindUser user;

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);
    final banned = user.isBanned || user.moderationState == 'banned';

    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: roleColor.withValues(alpha: 0.14),
            child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase(), style: TextStyle(color: roleColor, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(user.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                    _Pill(label: user.role, background: roleColor.withValues(alpha: 0.14), foreground: roleColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(user.email ?? 'No email', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 6),
                Text('${user.postCount} posts • ${_formatJoined(user.joinedAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(label: banned ? 'banned' : 'active', background: (banned ? AppColors.danger : AppColors.secondary).withValues(alpha: 0.14), foreground: banned ? AppColors.danger : AppColors.secondary),
                    if (user.isAnonymous) const _Pill(label: 'anonymous', background: AppColors.warm, foreground: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: user.role == 'advisor'
                      ? null
                      : () async {
                          final ok = await _confirm(context, 'Promote to Advisor', 'Promote ${user.name} to advisor?');
                          if (!context.mounted) return;
                          if (ok == true) await _run(context, () => SafeMindBackend.instance.updateUserRole(userId: user.id, role: 'advisor'), 'Promoted to advisor');
                        },
                  child: const Text('Advisor'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: user.role == 'admin'
                      ? null
                      : () async {
                          final ok = await _confirm(context, 'Promote to Admin', 'Promote ${user.name} to admin?');
                          if (!context.mounted) return;
                          if (ok == true) await _run(context, () => SafeMindBackend.instance.updateUserRole(userId: user.id, role: 'admin'), 'Promoted to admin');
                        },
                  child: const Text('Admin'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final ok = await _confirm(context, banned ? 'Unban user' : 'Ban user', '${banned ? 'Unban' : 'Ban'} ${user.name}?');
                    if (!context.mounted) return;
                    if (ok == true) await _run(context, () => SafeMindBackend.instance.banUser(user.id, banned: !banned), banned ? 'User unbanned' : 'User banned');
                  },
                  icon: Icon(banned ? Icons.lock_open_outlined : Icons.block_outlined, size: 18),
                  label: Text(banned ? 'Unban' : 'Ban'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry});

  final SafeMindAdminActivity entry;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.warm, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.timeline_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.action, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${entry.actorName} • ${entry.subject}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(entry.detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(_formatTime(entry.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

Color _severityColor(String severity) {
  switch (severity) {
    case 'high':
      return AppColors.danger;
    case 'medium':
      return const Color(0xFF9B7E5C);
    default:
      return AppColors.secondary;
  }
}

Color _roleColor(String role) {
  switch (role) {
    case 'admin':
      return AppColors.primary;
    case 'advisor':
      return const Color(0xFF9B7E5C);
    default:
      return AppColors.secondary;
  }
}

String _formatTime(DateTime createdAt) {
  final age = DateTime.now().difference(createdAt);
  if (age.inMinutes < 60) {
    return '${age.inMinutes} min ago';
  }
  if (age.inHours < 24) {
    return '${age.inHours} hours ago';
  }
  return '${age.inDays} days ago';
}

String _formatJoined(DateTime? joinedAt) {
  if (joinedAt == null) {
    return 'Joined recently';
  }
  final months = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return 'Joined ${months[joinedAt.month - 1]} ${joinedAt.year}';
}

Future<void> _run(BuildContext context, Future<void> Function() action, String message) async {
  try {
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
