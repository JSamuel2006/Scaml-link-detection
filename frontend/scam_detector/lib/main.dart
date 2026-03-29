import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/user/dashboard_screen.dart';
import 'features/user/scan_screen.dart';
import 'features/user/history_screen.dart';
import 'features/user/profile_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_users_screen.dart';
import 'features/admin/admin_analytics_screen.dart';
import 'shared/permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.init();
  runApp(
    ChangeNotifierProvider.value(value: auth, child: const ScamDetectorApp()),
  );
}

class ScamDetectorApp extends StatelessWidget {
  const ScamDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScamGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _SplashRouter(),
      routes: {
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  Future<void> _navigate() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    final auth = context.read<AuthService>();
    final permGranted = await StorageService.getPermissionsGranted();

    if (!auth.isLoggedIn) {
      if (!permGranted) {
        _goTo(PermissionScreen(onDone: () {
          _goTo(_loginScreen());
        }));
      } else {
        _goTo(_loginScreen());
      }
    } else {
      _goTo(auth.isAdmin ? const _AdminShell() : const _UserShell());
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _loginScreen() {
    return LoginScreen(onLoginSuccess: () {
      final auth = context.read<AuthService>();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              auth.isAdmin ? const _AdminShell() : const _UserShell(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow pulse
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 60,
                          spreadRadius: 20)
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .scaleXY(end: 1.2, duration: 1200.ms, curve: Curves.easeInOut),
                
                // Icon backing
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primary.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 5)
                      ],
                    ),
                    child: const Icon(Icons.security_rounded,
                        size: 64, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ShaderMask(
              shaderCallback: (b) =>
                  AppTheme.primaryGradient.createShader(b),
              child: const Text('ScamGuard',
                  style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2)),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            const Text('AI Threat Intelligence',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 3))
                .animate().fadeIn(delay: 800.ms).shimmer(duration: 2000.ms, delay: 1200.ms),
            const SizedBox(height: 64),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 2),
            ).animate().fadeIn(delay: 1200.ms),
          ],
        ),
      ),
    );
  }
}

// ── User shell with bottom nav ──────────────────────────────────────────
class _UserShell extends StatefulWidget {
  const _UserShell();

  @override
  State<_UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<_UserShell> {
  int _tab = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      UserDashboard(onTabChange: (i) => setState(() => _tab = i)),
      const ScanScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.radar_rounded), label: 'Scan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Admin shell with bottom nav ─────────────────────────────────────────
class _AdminShell extends StatefulWidget {
  const _AdminShell();

  @override
  State<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<_AdminShell> {
  int _tab = 0;

  final List<Widget> _pages = const [
    AdminDashboard(),
    AdminUsersScreen(),
    AdminAnalyticsScreen(),
  ];

  Future<void> _logout() async {
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const _SplashRouter()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded), label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppTheme.scam,
        onPressed: _logout,
        tooltip: 'Logout',
        child: const Icon(Icons.logout_rounded, color: Colors.white),
      ),
    );
  }
}
