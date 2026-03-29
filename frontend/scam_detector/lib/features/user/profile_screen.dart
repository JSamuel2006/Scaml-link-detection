import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getProfile();
      if (mounted) setState(() {
        _profile = res.data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.scam),
            onPressed: () async {
              await auth.logout();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Text(
                    (auth.name ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 16),
                Text(auth.name ?? '',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    auth.role?.toUpperCase() ?? '',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(height: 28),
                // Info cards
                if (_profile != null) ...[
                  _InfoRow(label: 'Email', value: _profile!['email'], icon: Icons.email_rounded),
                  _InfoRow(label: 'Status', value: _profile!['status'], icon: Icons.circle),
                  _InfoRow(label: 'Member Since', value: (_profile!['created_at'] as String).substring(0, 10), icon: Icons.calendar_today_rounded),
                  const SizedBox(height: 24),
                  // Scan stats
                  Row(children: [
                    _StatsBox(label: 'Total', value: '${_profile!['scan_count']}', color: AppTheme.primary),
                    const SizedBox(width: 12),
                    _StatsBox(label: 'Safe', value: '${_profile!['safe_count']}', color: AppTheme.safe),
                    const SizedBox(width: 12),
                    _StatsBox(label: 'Scams', value: '${_profile!['scam_count']}', color: AppTheme.scam),
                  ]),
                ],
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Logout',
                  icon: Icons.logout_rounded,
                  onPressed: () => auth.logout(),
                ),
              ]),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Icon(icon, color: AppTheme.textSecondary, size: 18),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ]),
    );
  }
}

class _StatsBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatsBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
      ),
    );
  }
}
