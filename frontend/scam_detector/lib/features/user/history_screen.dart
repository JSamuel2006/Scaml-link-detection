import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/widgets/result_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanModel> _all = [];
  List<ScanModel> _filtered = [];
  String _filter = 'all';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getHistory(limit: 100);
      if (mounted) {
        final list =
            (res.data as List).map((e) => ScanModel.fromJson(e)).toList();
        setState(() {
          _all = list;
          _applyFilter();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    if (_filter == 'all') {
      _filtered = _all;
    } else {
      _filtered = _all.where((s) => s.result == _filter).toList();
    }
  }

  void _setFilter(String f) {
    setState(() {
      _filter = f;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppTheme.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['all', 'safe', 'suspicious', 'scam'].map((f) {
                final selected = _filter == f;
                final color = f == 'all'
                    ? AppTheme.primary
                    : AppTheme.resultColor(f);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f[0].toUpperCase() + f.substring(1)),
                    selected: selected,
                    onSelected: (_) => _setFilter(f),
                    selectedColor: color.withOpacity(0.2),
                    backgroundColor: AppTheme.card,
                    side: BorderSide(
                        color: selected ? color : AppTheme.border),
                    labelStyle: TextStyle(
                        color: selected ? color : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary))
                : _filtered.isEmpty
                    ? const Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Icon(Icons.history_rounded,
                                size: 64, color: AppTheme.textSecondary),
                            SizedBox(height: 12),
                            Text('No scans yet',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 16)),
                          ]))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppTheme.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) =>
                              _HistoryTile(scan: _filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ScanModel scan;
  const _HistoryTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.resultColor(scan.result);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
            scan.platform == 'whatsapp'
                ? Icons.chat_bubble_rounded
                : scan.platform == 'sms'
                    ? Icons.sms_rounded
                    : scan.platform == 'instagram'
                        ? Icons.camera_alt_rounded
                        : scan.platform == 'telegram'
                            ? Icons.send_rounded
                            : Icons.link_rounded,
            color: AppTheme.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            scan.platform[0].toUpperCase() + scan.platform.substring(1),
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
          const Spacer(),
          ResultBadge(result: scan.result),
        ]),
        const SizedBox(height: 8),
        Text(
          scan.url,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text('Risk: ${scan.score.toStringAsFixed(1)}%',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            scan.createdAt.length > 10 ? scan.createdAt.substring(0, 10) : scan.createdAt,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11),
          ),
        ]),
      ]),
    );
  }
}
