import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserModel> _users = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getAdminUsers();
      if (mounted) {
        setState(() {
          _users =
              (res.data as List).map((e) => UserModel.fromJson(e)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<UserModel> get _filtered => _users
      .where((u) =>
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  Future<void> _toggleBlock(UserModel user) async {
    await ApiService.blockUser(user.id);
    _load();
  }

  Future<void> _delete(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Delete User',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Delete ${user.name}? This cannot be undone.',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppTheme.scam))),
        ],
      ),
    );
    if (confirmed == true) {
      await ApiService.deleteUser(user.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load)
        ],
      ),
      body: Column(
        children: [
          // Search
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textSecondary),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border)),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : list.isEmpty
                    ? const Center(
                        child: Text('No users found',
                            style:
                                TextStyle(color: AppTheme.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppTheme.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _UserTile(
                            user: list[i],
                            onBlock: () => _toggleBlock(list[i]),
                            onDelete: () => _delete(list[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onBlock, onDelete;
  const _UserTile(
      {required this.user, required this.onBlock, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isBlocked = user.status == 'blocked';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isBlocked
                ? AppTheme.scam.withOpacity(0.3)
                : AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primary.withOpacity(0.15),
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textPrimary)),
                  Text(user.email,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ]),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isBlocked
                  ? AppTheme.scam.withOpacity(0.15)
                  : AppTheme.safe.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.status.toUpperCase(),
              style: TextStyle(
                  color: isBlocked ? AppTheme.scam : AppTheme.safe,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _InfoChip(label: '${user.scanCount} scans', icon: Icons.search_rounded),
          const SizedBox(width: 8),
          _InfoChip(label: '${user.loginCount} logins', icon: Icons.login_rounded),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onBlock,
              icon: Icon(
                  isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                  size: 16),
              label: Text(isBlocked ? 'Unblock' : 'Block'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isBlocked ? AppTheme.safe : AppTheme.suspicious,
                side: BorderSide(
                    color: isBlocked ? AppTheme.safe : AppTheme.suspicious),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.scam,
              side: const BorderSide(color: AppTheme.scam),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }
}
