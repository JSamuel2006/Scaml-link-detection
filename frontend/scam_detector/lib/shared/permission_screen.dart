import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../core/services/storage_service.dart';
import '../shared/widgets/custom_button.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback onDone;
  const PermissionScreen({super.key, required this.onDone});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final Map<String, bool> _granted = {
    'whatsapp_instagram': false,
    'sms': false,
    'contacts': false,
  };

  final _permissions = [
    {
      'key': 'whatsapp_instagram',
      'title': 'WhatsApp & Instagram Monitoring',
      'description':
          'Allow the app to monitor messages and links from WhatsApp and Instagram for scam detection.',
      'icon': Icons.chat_bubble_rounded,
      'color': AppTheme.safe,
    },
    {
      'key': 'sms',
      'title': 'SMS Access',
      'description':
          'Read incoming SMS messages to detect phishing and scam links before you click them.',
      'icon': Icons.sms_rounded,
      'color': AppTheme.suspicious,
    },
    {
      'key': 'contacts',
      'title': 'Contacts Access',
      'description':
          'Access your contacts to identify messages from unknown numbers sending suspicious links.',
      'icon': Icons.contacts_rounded,
      'color': AppTheme.primary,
    },
  ];

  Future<void> _openNotificationSettings() async {
    final uri = Uri.parse('android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _done() async {
    await StorageService.savePermissionsGranted(true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (b) =>
                    AppTheme.primaryGradient.createShader(b),
                child: const Icon(Icons.shield_rounded,
                    size: 56, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('App Permissions',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'Grant access to enable real-time scam detection across your apps.',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _permissions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final p = _permissions[i];
                    final key = p['key'] as String;
                    final granted = _granted[key]!;
                    final color = p['color'] as Color;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: granted
                                ? color.withOpacity(0.5)
                                : AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(p['icon'] as IconData,
                                  color: color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(p['title'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppTheme.textPrimary)),
                            ),
                            if (granted)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: AppTheme.safe.withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.check,
                                    color: AppTheme.safe, size: 16),
                              ),
                          ]),
                          const SizedBox(height: 12),
                          Text(p['description'] as String,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.5)),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _granted[key] = false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.textSecondary,
                                  side: const BorderSide(
                                      color: AppTheme.border),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                child: const Text("DON'T ALLOW"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() => _granted[key] = true);
                                  if (key == 'whatsapp_instagram') {
                                    await _openNotificationSettings();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: AppTheme.bg,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                child: const Text('ALLOW',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: _done,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
