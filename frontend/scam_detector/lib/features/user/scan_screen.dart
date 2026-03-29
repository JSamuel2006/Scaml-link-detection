import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/glass_card.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _urlCtrl = TextEditingController();
  final _platforms = ['Manual', 'WhatsApp', 'Instagram', 'Telegram', 'SMS'];
  String _selectedPlat = 'Manual';
  bool _scanning = false;
  Map<String, dynamic>? _result;

  Future<void> _scan() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _scanning = true;
      _result = null;
    });

    try {
      // Simulate heavy AI processing delay for UX
      await Future.delayed(const Duration(seconds: 2));
      final res = await ApiService.scanUrl(url, _selectedPlat.toLowerCase());
      if (mounted) setState(() => _result = res.data);
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Threat Scanner', style: TextStyle(letterSpacing: 2)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Cyber grid background (subtle)
          Positioned.fill(
             child: CustomPaint(painter: _GridPainter()),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // High Tech Radar Animation
                  SizedBox(
                    height: 180,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_scanning) ...[
                            _buildRadarCircle(120, AppTheme.primary),
                            _buildRadarCircle(90, AppTheme.secondary, delay: 400),
                            _buildRadarCircle(60, AppTheme.primary, delay: 800),
                          ],
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 30)
                              ]
                            ),
                            child: Icon(_scanning ? Icons.radar_rounded : Icons.find_in_page_rounded, 
                                size: 48, color: Colors.white)
                              .animate(target: _scanning ? 1 : 0)
                              .rotate(duration: 2.seconds, curve: Curves.linear),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms),

                  const SizedBox(height: 32),

                  // Input Panel
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TARGET URL', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _urlCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'https://suspicious-link.com',
                            prefixIcon: Icon(Icons.link_rounded, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('SOURCE PLATFORM', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedPlat,
                          dropdownColor: AppTheme.card,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.share_rounded, color: AppTheme.textSecondary),
                          ),
                          items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (v) => setState(() => _selectedPlat = v!),
                        ),
                        const SizedBox(height: 32),
                        GradientButton(
                          text: _scanning ? 'ANALYZING...' : 'INITIATE SCAN',
                          icon: Icons.search_rounded,
                          isLoading: _scanning,
                          onPressed: _scanning ? null : _scan,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  // Result Panel
                  if (_result != null)
                    _ResultCard(result: _result!)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCircle(double size, Color color, {int delay = 0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
    ).animate(onPlay: (c) => c.repeat())
     .scaleXY(begin: 0.5, end: 2.5, duration: 1200.ms, delay: delay.ms)
     .fade(begin: 1.0, end: 0.0, duration: 1200.ms, delay: delay.ms);
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final status = result['result'].toString().toUpperCase();
    final score = (result['score'] as num).toDouble();
    final color = AppTheme.resultColor(status);
    final blUrl = result['blacklisted'] == true;

    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderColor: color.withOpacity(0.5),
      child: Column(
        children: [
          Icon(status == 'SAFE' ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
              color: color, size: 60)
            .animate().scale(curve: Curves.elasticOut, duration: 800.ms).shimmer(delay: 1.seconds),
            
          const SizedBox(height: 16),
          Text(status,
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0)),
                  
          const SizedBox(height: 24),
          
          // Technical Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('AI RISK SCORE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text('${score.toStringAsFixed(1)}%', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(width: 1, height: 40, color: AppTheme.border),
                Column(
                  children: [
                    const Text('KNOWN THREAT', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text(blUrl ? 'YES' : 'NO', style: TextStyle(color: blUrl ? AppTheme.scam : AppTheme.safe, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal Cyber Grid Base
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.03)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
