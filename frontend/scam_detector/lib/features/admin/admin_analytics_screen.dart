import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getAdminAnalytics();
      if (mounted) setState(() {
        _data = res.data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded), onPressed: _load)
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _data == null
              ? const Center(
                  child: Text('Failed to load analytics',
                      style: TextStyle(color: AppTheme.textSecondary)))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBarChart(),
                        const SizedBox(height: 24),
                        _buildLineChart(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildBarChart() {
    final platform =
        Map<String, dynamic>.from(_data!['platform_distribution'] ?? {});
    final platforms = ['whatsapp', 'instagram', 'telegram', 'sms', 'manual'];
    final colors = [
      AppTheme.safe,
      AppTheme.secondary,
      AppTheme.primary,
      AppTheme.suspicious,
      AppTheme.textSecondary,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Scams by Platform',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        const Text('Total scam links detected per platform',
            style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (platform.values
                        .fold<int>(0, (a, b) => a > (b as int) ? a : b)
                        .toDouble() +
                    5)
                .clamp(5, double.infinity),
            barGroups: List.generate(platforms.length, (i) {
              final val = (platform[platforms[i]] ?? 0).toDouble();
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: val,
                  color: colors[i],
                  width: 28,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: (platform.values.fold<int>(
                                  0,
                                  (a, b) =>
                                      a > (b as int) ? a : b) +
                              5)
                          .toDouble(),
                      color: AppTheme.surface),
                )
              ]);
            }),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final names = ['WA', 'IG', 'TG', 'SMS', 'Man'];
                    final idx = val.toInt();
                    if (idx < names.length) {
                      return Text(names[idx],
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600));
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          )),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: List.generate(platforms.length, (i) {
            final count = platform[platforms[i]] ?? 0;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: colors[i], shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(
                '${platforms[i][0].toUpperCase()}${platforms[i].substring(1)}: $count',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
            ]);
          }),
        ),
      ]),
    );
  }

  Widget _buildLineChart() {
    final trend = _data!['daily_trend'] as List? ?? [];
    final totalSpots = <FlSpot>[];
    final scamSpots = <FlSpot>[];

    for (int i = 0; i < trend.length; i++) {
      totalSpots.add(FlSpot(i.toDouble(), (trend[i]['total'] ?? 0).toDouble()));
      scamSpots.add(FlSpot(i.toDouble(), (trend[i]['scams'] ?? 0).toDouble()));
    }

    final maxY = trend.fold<int>(
            0,
            (acc, d) =>
                (d['total'] as int? ?? 0) > acc ? (d['total'] as int) : acc) +
        5.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Daily Detection Trends',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        const Text('Scans vs scams detected over last 7 days',
            style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            maxY: maxY.toDouble(),
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: totalSpots,
                isCurved: true,
                color: AppTheme.primary,
                barWidth: 3,
                dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, _, __, ___) =>
                        FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.primary,
                            strokeWidth: 2,
                            strokeColor: AppTheme.bg)),
                belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primary.withOpacity(0.1)),
              ),
              LineChartBarData(
                spots: scamSpots,
                isCurved: true,
                color: AppTheme.scam,
                barWidth: 3,
                dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, _, __, ___) =>
                        FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.scam,
                            strokeWidth: 2,
                            strokeColor: AppTheme.bg)),
                belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.scam.withOpacity(0.1)),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final i = val.toInt();
                    if (i >= 0 && i < trend.length) {
                      final date = trend[i]['date'] as String;
                      return Text(
                          date.length >= 10 ? date.substring(5) : date,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10));
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppTheme.border, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
          )),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _Legend(color: AppTheme.primary, label: 'Total Scans'),
          const SizedBox(width: 16),
          _Legend(color: AppTheme.scam, label: 'Scams'),
        ]),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 24,
          height: 3,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label,
          style:
              const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
  }
}
