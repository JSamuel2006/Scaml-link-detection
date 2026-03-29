import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/custom_button.dart';

class UserDashboard extends StatefulWidget {
  final Function(int) onTabChange;
  const UserDashboard({super.key, required this.onTabChange});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
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
    final name = auth.name ?? 'User';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background ambient light
          Positioned(
            top: -150,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primary.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.1, duration: 4.seconds),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SYSTEM READY',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0)),
                            const SizedBox(height: 4),
                            Text('Welcome, $name.',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.border),
                            color: AppTheme.surface,
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary),
                        ).animate().shake(delay: 2.seconds),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 32),

                    // Quick Scan Action
                    GestureDetector(
                      onTap: () => widget.onTabChange(1),
                      child: GlassCard(
                        padding: const EdgeInsets.all(28),
                        borderColor: AppTheme.primary.withOpacity(0.3),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.radar_rounded, color: AppTheme.primary, size: 32)
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scaleXY(end: 1.1, duration: 800.ms),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Scan URL Pattern',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Detect active phishing threats.',
                                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 16),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),

                    const SizedBox(height: 32),
                    const Text('THREAT METRICS',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5))
                        .animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),

                    // Stats Grid
                    if (_loading)
                      const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    else if (_profile != null)
                      Row(
                        children: [
                          Expanded(child: _AnimatedStatCard(title: 'Safe', value: '${_profile!['safe_count']}', color: AppTheme.safe, icon: Icons.gpp_good_rounded, delay: 500)),
                          const SizedBox(width: 16),
                          Expanded(child: _AnimatedStatCard(title: 'Scams', value: '${_profile!['scam_count']}', color: AppTheme.scam, icon: Icons.dangerous_rounded, delay: 600)),
                        ],
                      ),
                      
                    const SizedBox(height: 32),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_rounded, color: AppTheme.textPrimary, size: 20),
                              const SizedBox(width: 12),
                              const Text('Protection Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.safe.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                child: const Text('ACTIVE', style: TextStyle(color: AppTheme.safe, fontSize: 10, fontWeight: FontWeight.bold)),
                              ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(end: 0.5, duration: 1.seconds),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('Real-time SMS and WhatsApp monitoring is currently operating normally in the background.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms).shimmer(duration: 1500.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;
  final int delay;

  const _AnimatedStatCard({required this.title, required this.value, required this.color, required this.icon, required this.delay});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900))
              .animate().slideY(begin: 0.5, end: 0).fadeIn(),
          const SizedBox(height: 4),
          Text(title.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}
