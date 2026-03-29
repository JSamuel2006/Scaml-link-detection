import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final res = await auth.login(_email.text, _pass.text);

    if (res['success'] == true) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _error = res['message'] ?? 'Login failed';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cyber Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondary.withOpacity(0.3),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scaleXY(end: 1.2, duration: 4.seconds, curve: Curves.easeInOut),
          
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.2),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scaleXY(end: 1.15, duration: 6.seconds, curve: Curves.easeInOut),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic Logo Header
                    const Icon(Icons.security_rounded,
                            size: 72, color: AppTheme.primary)
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.easeOutBack)
                        .shimmer(delay: 800.ms, duration: 1200.ms),
                    const SizedBox(height: 24),
                    
                    Text('ScamGuard',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2))
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 8),
                    const Text('AI Threat Intelligence',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.0))
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms),
                    const SizedBox(height: 48),

                    // Error Message
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                            color: AppTheme.scam.withOpacity(0.15),
                            border: Border.all(color: AppTheme.scam),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppTheme.scam,
                                fontWeight: FontWeight.w600)),
                      ).animate().fadeIn().shake(),

                    // Glassmorphic Login Form
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pass,
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Account Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              text: 'AUTHORIZE ACCESS',
                              isLoading: _loading,
                              onPressed: _login,
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                     .fadeIn(delay: 600.ms, duration: 600.ms)
                     .slideY(begin: 0.1, end: 0),
                     
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('New Operator? Initialize Profile',
                          style: TextStyle(color: AppTheme.textSecondary, letterSpacing: 0.5)),
                    ).animate().fadeIn(delay: 800.ms),
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
