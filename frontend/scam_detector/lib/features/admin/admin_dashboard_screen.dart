import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/stat_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getAdminStats();
      if (mounted) setState(() {
        _stats = res.data;
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: Row(children: [
                    const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Admin Dashboard',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          Text('Welcome back, ${auth.name ?? "Admin"}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                  ]),
                ),
                const SizedBox(height: 24),
                const Text('System Overview',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary))
                    : _stats == null
                        ? const Center(
                            child: Text('Failed to load stats',
                                style: TextStyle(
                                    color: AppTheme.textSecondary)))
                        : GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                            children: [
                              StatCard(
                                  title: 'Total Users',
                                  value: '${_stats!['total_users']}',
                                  icon: Icons.people_rounded,
                                  color: AppTheme.primary),
                              StatCard(
                                  title: 'Total Logins',
                                  value: '${_stats!['total_logins']}',
                                  icon: Icons.login_rounded,
                                  color: AppTheme.secondary),
                              StatCard(
                                  title: 'Active Users',
                                  value: '${_stats!['active_users']}',
                                  icon: Icons.person_rounded,
                                  color: AppTheme.safe),
                              StatCard(
                                  title: 'Total Scans',
                                  value: '${_stats!['total_scans']}',
                                  icon: Icons.search_rounded,
                                  color: AppTheme.suspicious),
                              StatCard(
                                  title: 'Scams Found',
                                  value: '${_stats!['total_scams']}',
                                  icon: Icons.dangerous_rounded,
                                  color: AppTheme.scam),
                              StatCard(
                                  title: 'Suspicious',
                                  value: '${_stats!['total_suspicious']}',
                                  icon: Icons.warning_rounded,
                                  color: AppTheme.suspicious),
                            ],
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
