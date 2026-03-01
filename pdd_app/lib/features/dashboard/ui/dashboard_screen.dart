import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_theme.dart';
import '../../../shared/providers/layout_providers.dart';
import '../../train_record/models/train_record.dart';
import '../models/analysis_period.dart';
import '../models/dashboard_summary.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).update(title: 'Operational Dashboard', actions: []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(analysisPeriodProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPeriodSelector(period),
          const SizedBox(height: 16),
          summaryAsync.when(
            data: (summary) => _buildDashboardContent(summary),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (err, st) => Center(child: Text('Error: $err', style: TextStyle(color: Theme.of(context).colorScheme.error))),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AnalysisPeriod period) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip('Today', PeriodPreset.today, period),
          const SizedBox(width: 8),
          _buildPeriodChip('Last 7 Days', PeriodPreset.last7Days, period),
          const SizedBox(width: 8),
          _buildPeriodChip('This Month', PeriodPreset.thisMonth, period),
          const SizedBox(width: 8),
          _buildCustomAction(period),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardSummary summary) {
    if (summary.totalMovements == 0) return _buildEmptyState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Snapshot Cards
        _buildSnapshotSection(summary),
        const SizedBox(height: 24),
        
        // Alerts Panel (only if alerts exist)
        if (summary.alerts.isNotEmpty) ...[
          _buildAlertsPanel(summary.alerts),
          const SizedBox(height: 24),
        ],

        // 2. Trend & Department (Split on Large, Stack on Small)
        LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildTrendChart(summary)),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildDeptContribution(summary)),
              ],
            );
          }
          return Column(
            children: [
              _buildTrendChart(summary),
              const SizedBox(height: 24),
              _buildDeptContribution(summary),
            ],
          );
        }),
        const SizedBox(height: 24),

        // 3. Top Reasons
        _buildTopReasons(summary),
        const SizedBox(height: 40),

        // Quick Nav
        Center(
          child: ElevatedButton.icon(
            onPressed: () => context.go('/train-record'),
            icon: Icon(Icons.list, color: Theme.of(context).colorScheme.onPrimary),
            label: Text('View All Records', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnapshotSection(DashboardSummary summary) {
    return LayoutBuilder(builder: (context, constraints) {
      // Responsive Grid
      int crossAxisCount = constraints.maxWidth < 600 ? 2 : 5;
      double ratio = constraints.maxWidth < 600 ? 1.3 : 1.0;

      return GridView.count(
        crossAxisCount: crossAxisCount,
        childAspectRatio: ratio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMetricCard('Movements', '${summary.totalMovements}', Theme.of(context).colorScheme.primary),
          _buildMetricCard('Total PDD', '${summary.totalPddMinutes}m', Theme.of(context).colorScheme.secondary),
          _buildMetricCard(
            'Avg PDD', 
            '${summary.avgPddMinutes}m', 
            _getColorForPdd(summary.avgPddMinutes),
            isHighlighted: true
          ),
          _buildMetricCard(
            'Avoidable Avg', 
            '${summary.avoidableAvgPddMinutes}m', 
            _getColorForPdd(summary.avoidableAvgPddMinutes)
          ),
          _buildMetricCard('Unavoidable', '${summary.unavoidableCount}', Theme.of(context).colorScheme.tertiary),
        ],
      );
    });
  }

  Widget _buildMetricCard(String label, String value, Color color, {bool isHighlighted = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? color : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isHighlighted ? color : colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              color: isHighlighted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant
            )
          ),
          const SizedBox(height: 8),
          Text(value, 
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: isHighlighted ? colorScheme.onPrimary : colorScheme.onSurface
            )
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPanel(List<DashboardAlert> alerts) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Text('Critical Alerts', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onErrorContainer, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _getAlertColor(a.type)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(a.message, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onErrorContainer))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptContribution(DashboardSummary summary) {
    final sorted = summary.departmentContribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Department Contribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (sorted.isEmpty) Text('No delays.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ...sorted.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(e.key.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                       Text('${e.value.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: e.value / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: Theme.of(context).colorScheme.primary,
                     minHeight: 8,
                     borderRadius: BorderRadius.circular(4),
                   ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(DashboardSummary summary) {
    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('7-Day Trend (Avg PDD)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             const SizedBox(height: 24),
             SizedBox(
               height: 250,
               child: LineChart(
                 LineChartData(
                   gridData: const FlGridData(show: true, drawVerticalLine: false),
                   titlesData: FlTitlesData(
                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (val, _) {
                            int idx = val.toInt();
                            if (idx >= 0 && idx < summary.trend.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(DateFormat('d/M').format(summary.trend[idx].date), 
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              );
                            }
                            return const Text('');
                         },
                       )
                     ),
                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   ),
                   borderData: FlBorderData(show: false),
                   lineBarsData: [
                     LineChartBarData(
                       spots: summary.trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.avgPdd.toDouble())).toList(),
                       isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                     ),
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopReasons(DashboardSummary summary) {
    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Delay Reasons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (summary.topReasons.isEmpty) Text('No reasons recorded.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ...summary.topReasons.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, 
                child: Text('${e.value}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))
              ),
              title: Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, PeriodPreset preset, AnalysisPeriod current) {
    bool isSelected = current.preset == preset;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) ref.read(analysisPeriodProvider.notifier).setPreset(preset);
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimaryContainer 
            : Theme.of(context).colorScheme.onSurface
      ),
    );
  }
  
  Widget _buildCustomAction(AnalysisPeriod current) {
     return ActionChip(
       avatar: const Icon(Icons.calendar_month, size: 16),
       label: const Text('Custom'),
        backgroundColor: current.preset == PeriodPreset.custom ? Theme.of(context).colorScheme.primaryContainer : null,
        labelStyle: TextStyle(
          color: current.preset == PeriodPreset.custom 
              ? Theme.of(context).colorScheme.onPrimaryContainer 
              : Theme.of(context).colorScheme.onSurface
        ),
       onPressed: () async {
          final res = await showDateRangePicker(
            context: context, 
            firstDate: DateTime(2020), 
            lastDate: DateTime(2030),
            initialDateRange: DateTimeRange(start: current.startDate, end: current.endDate)
          );
          if (res != null) {
            ref.read(analysisPeriodProvider.notifier).setCustomRange(res.start, res.end);
          }
       },
     );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const SizedBox(height: 60),
           Icon(Icons.analytics_outlined, size: 80, color: Theme.of(context).colorScheme.outlineVariant),
           const SizedBox(height: 16),
           Text('No data for selected period', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
         ],
       ),
     );
  }

  Color _getColorForPdd(int mins) {
    if (mins < 15) return Colors.green;
    if (mins <= 30) return Colors.orange;
    return Colors.red;
  }
  
  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.critical: return Colors.red;
      case AlertType.warning: return Colors.orange;
      case AlertType.info: return Colors.blue;
    }
  }
}

