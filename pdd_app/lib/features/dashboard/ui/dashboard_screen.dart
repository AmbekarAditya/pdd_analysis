import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../core/app_theme.dart';
import '../../../shared/providers/layout_providers.dart';
import '../../../core/utils/pdd_calculator.dart';
import '../../train_record/models/train_record.dart';
import '../../train_record/models/daily_stats.dart';
import '../../train_record/providers/record_providers.dart';
import '../models/analysis_period.dart';
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
      _updateAppBar();
    });
  }

  void _updateAppBar() {
    ref.read(appBarProvider.notifier).update(
      title: 'PDD Dashboard',
      actions: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text('SC', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(analysisPeriodProvider);
    final recordsAsync = ref.watch(trainRecordsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPeriodSelector(period),
          const SizedBox(height: 24),
          recordsAsync.when(
            data: (allRecords) {
              // Filter logic
              final filtered = allRecords.where((r) {
                // Determine if record in range.
                // r.date is DateTime.
                return r.date.isAfter(period.startDate.subtract(const Duration(seconds: 1))) && 
                       r.date.isBefore(period.endDate.add(const Duration(seconds: 1)));
              }).toList();

              if (filtered.isEmpty) {
                 return _buildEmptyState(period);
              }

              final dailyStats = _processRecords(filtered, period);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCards(filtered),
                  const SizedBox(height: 24),
                  _buildCharts(dailyStats, period),
                  const SizedBox(height: 24),
                  _buildDailySummariesTable(dailyStats),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error: $err')),
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
          _buildCustomRangeChip(period),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, PeriodPreset preset, AnalysisPeriod currentPeriod) {
    final isSelected = currentPeriod.preset == preset;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(analysisPeriodProvider.notifier).setPreset(preset);
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
    );
  }

  Widget _buildCustomRangeChip(AnalysisPeriod currentPeriod) {
    final isSelected = currentPeriod.preset == PeriodPreset.custom;
    String label = 'Custom Range';
    if (isSelected) {
      label = '${DateFormat('MMM d').format(currentPeriod.startDate)} - ${DateFormat('MMM d').format(currentPeriod.endDate)}';
    }

    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? AppTheme.primaryColor : null,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      avatar: Icon(Icons.calendar_month, size: 16, color: isSelected ? Colors.white : Colors.grey),
      onPressed: () async {
        final result = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDateRange: DateTimeRange(start: currentPeriod.startDate, end: currentPeriod.endDate),
        );
        if (result != null) {
          ref.read(analysisPeriodProvider.notifier).setCustomRange(result.start, result.end);
        }
      },
    );
  }

  Widget _buildSummaryCards(List<TrainRecord> records) {
    final total = records.length;
    // PDD logic moved to Int
    int totalPddMinutes = 0;
    int below45Count = 0;
    
    for (var r in records) {
      totalPddMinutes += r.pddMinutes;
      if (r.pddMinutes < 45) below45Count++;
    }

    final avgPdd = total > 0 ? (totalPddMinutes / total).round() : 0;
    final perc = total > 0 ? (below45Count / total * 100) : 0.0;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return GridView.count(
        crossAxisCount: isMobile ? 1 : 3,
        childAspectRatio: isMobile ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSummaryCard(
            'Total Trains',
            '$total',
            Icons.train_outlined,
          ),
          _buildSummaryCard(
            'Average PDD',
            '${(avgPdd / 60).floor()}h ${(avgPdd % 60)}m',
            Icons.access_time,
          ),
          _buildSummaryCard(
            'Trains Below 45 Mins',
            '${perc.toStringAsFixed(1)}%',
            Icons.check_circle_outline,
            backgroundColor: _getPerformanceColor(perc),
            textColor: perc > 0 ? Colors.white : null,
            iconColor: perc > 0 ? Colors.white70 : null,
          ),
        ],
      );
    });
  }
  
  // Reusing buildSummaryCard from before...
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon, {
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: textColor?.withOpacity(0.8) ?? Colors.grey)),
                Icon(icon, color: iconColor ?? Colors.grey, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Color? _getPerformanceColor(double percentage) {
    if (percentage >= 90) return Colors.green[600];
    if (percentage >= 70) return Colors.orange[600];
    if (percentage > 0) return Colors.red[600];
    return null;
  }

  List<DailyStats> _processRecords(List<TrainRecord> records, AnalysisPeriod period) {
    final grouped = <String, List<TrainRecord>>{};
    for (var r in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(r.date);
      grouped.putIfAbsent(dateKey, () => []).add(r);
    }
    
    // Fill in missing dates if range < 31 days for continuity? 
    // Or just show dates with data. Let's just show sorted keys for now.
    final sortedKeys = grouped.keys.toList()..sort();
    
    return sortedKeys.map((key) {
      final dailyRecords = grouped[key]!;
      int totalMinutes = dailyRecords.fold(0, (sum, r) => sum + r.pddMinutes);
      final avgMinutes = dailyRecords.isNotEmpty ? (totalMinutes / dailyRecords.length).round() : 0;
      final below45 = dailyRecords.where((r) => r.pddMinutes < 45).length;
      
      final d = DateTime.parse(key);

      return DailyStats(
        date: d,
        totalTrains: dailyRecords.length,
        averagePDD: Duration(minutes: avgMinutes),
        trainsBelow45: below45,
      );
    }).toList();
  }

  Widget _buildCharts(List<DailyStats> stats, AnalysisPeriod period) {
    // Decision: Line vs Bar
    // If range > 7 days -> Line Chart (Trend)
    // If range <= 7 days -> Bar Chart (Breakdown)
    final daysDiff = period.endDate.difference(period.startDate).inDays;
    bool showLine = daysDiff > 8; // 7 days usually means 8 days inclusive if full week?

    // But user selected "Last 7 Days". 
    if (period.preset == PeriodPreset.thisMonth || daysDiff > 8) {
       showLine = true;
    } else {
       showLine = false;
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      // If showing line, maybe just line chart using full width?
      // Requirement said to update Trend Section.
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(showLine ? 'PDD Trend (Daily Average)' : 'Daily Breakdown', 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               const SizedBox(height: 24),
               SizedBox(
                 height: 300,
                 child: showLine ? _buildLineChartWidget(stats) : _buildBarChartWidget(stats),
               ),
             ],
          ),
        ),
      );
    });
  }

  Widget _buildBarChartWidget(List<DailyStats> stats) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: _getTitlesData(stats),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.primaryColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        barGroups: stats.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.totalTrains.toDouble(),
                color: AppTheme.primaryColor,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChartWidget(List<DailyStats> stats) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: _getTitlesData(stats),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.secondaryColor,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.round()} min',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 45,
              color: Colors.red.withOpacity(0.5),
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                style: TextStyle(color: Colors.red.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
                labelResolver: (line) => 'Target: 45m',
              ),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: stats.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.averagePDD.inMinutes.toDouble());
            }).toList(),
            isCurved: true,
            color: AppTheme.secondaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppTheme.secondaryColor.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  FlTitlesData _getTitlesData(List<DailyStats> stats) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= stats.length) return const Text('');
            // Intelligent label spacing
            if (stats.length <= 7) {
               return Text(DateFormat('d MMM').format(stats[index].date), style: const TextStyle(fontSize: 10));
            }
            if (index == 0 || index == stats.length - 1 || index % (stats.length ~/ 5) == 0) {
              return Text(DateFormat('d MMM').format(stats[index].date), style: const TextStyle(fontSize: 10));
            }
            return const Text('');
          },
          reservedSize: 22,
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildEmptyState(AnalysisPeriod period) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No records found for selected period',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
           const SizedBox(height: 8),
          Text(
            '${DateFormat('MMM d').format(period.startDate)} - ${DateFormat('MMM d').format(period.endDate)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailySummariesTable(List<DailyStats> stats) {
    // Reuse existing table logic or simplified one
     return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Period Details', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Avg PDD')),
                DataColumn(label: Text('<45m')),
              ],
              rows: stats.map((s) {
                return DataRow(cells: [
                  DataCell(Text(s.dateString)),
                  DataCell(Text(s.totalTrains.toString())),
                  DataCell(Text(s.pddString)),
                  DataCell(Text('${s.percentBelow45.toStringAsFixed(0)}%')),
                ]);
              }).toList().reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}

