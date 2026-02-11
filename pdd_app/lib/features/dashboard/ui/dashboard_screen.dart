import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../core/app_theme.dart';
import '../../../core/utils/pdd_calculator.dart';
import '../../train_record/models/train_record.dart';
import '../../train_record/models/daily_stats.dart';
import '../../train_record/providers/record_providers.dart';
import '../../../shared/providers/layout_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppBar();
    });
  }

  void _updateAppBar() {
    ref.read(appBarProvider.notifier).update(
      title: 'PDD Analysis - ${DateFormat('MMMM yyyy').format(_selectedDate)}',
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
              _updateAppBar();
            }
          },
        ),
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
    final recordsAsync = ref.watch(trainRecordsStreamProvider);

    return recordsAsync.when(
      data: (records) {
        // Filter records for the selected month/year
        final filtered = records.where((r) => 
          r.date.year == _selectedDate.year && 
          r.date.month == _selectedDate.month).toList();
          
        final dailyStats = _processRecords(filtered);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(filtered),
              const SizedBox(height: 24),
              _buildCharts(dailyStats),
              const SizedBox(height: 24),
              _buildDailySummariesTable(dailyStats),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  List<DailyStats> _processRecords(List<TrainRecord> records) {
    final grouped = <String, List<TrainRecord>>{};
    for (var r in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(r.date);
      grouped.putIfAbsent(dateKey, () => []).add(r);
    }

    final sortedKeys = grouped.keys.toList()..sort();
    
    return sortedKeys.map((key) {
      final dailyRecords = grouped[key]!;
      final avgPDD = PDDCalculator.calculateAverage(dailyRecords.map((r) => r.pdd).toList());
      final below45 = dailyRecords.where((r) {
        final duration = PDDCalculator.parsePDD(r.pdd);
        return duration.inMinutes < 45;
      }).length;

      return DailyStats(
        date: DateTime.parse(key),
        totalTrains: dailyRecords.length,
        averagePDD: avgPDD,
        trainsBelow45: below45,
      );
    }).toList();
  }

  Widget _buildSummaryCards(List<TrainRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('No data for this month'));
    }

    final total = records.length;
    final avgPDD = PDDCalculator.calculateAverage(records.map((r) => r.pdd).toList());
    final below45 = records.where((r) => PDDCalculator.parsePDD(r.pdd).inMinutes < 45).length;
    final perc = (below45 / total * 100).toStringAsFixed(1);

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
            PDDCalculator.formatDuration(avgPDD),
            Icons.access_time,
          ),
          _buildSummaryCard(
            'Trains Below 45 Mins',
            '$perc%',
            Icons.check_circle_outline,
            isPositive: true,
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon, {
    bool? isPositive,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Icon(icon, color: Colors.grey, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(List<DailyStats> stats) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return GridView.count(
        crossAxisCount: isMobile ? 1 : 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildBarChart(stats),
          _buildLineChart(stats),
        ],
      );
    });
  }

  Widget _buildBarChart(List<DailyStats> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Total Trains', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: _getTitlesData(stats),
                  borderData: FlBorderData(show: false),
                  barGroups: stats.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.totalTrains.toDouble(),
                          color: AppTheme.primaryColor,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<DailyStats> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Average PDD (Minutes)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: _getTitlesData(stats),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: stats.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.averagePDD.inMinutes.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.secondaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: AppTheme.secondaryColor.withValues(alpha: 0.1)),
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

  FlTitlesData _getTitlesData(List<DailyStats> stats) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= stats.length) return const Text('');
            // Show only first and last or every 5th to avoid overlap
            if (index == 0 || index == stats.length - 1 || index % 5 == 0) {
              return Text(stats[index].dateString, style: const TextStyle(fontSize: 10));
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

  Widget _buildDailySummariesTable(List<DailyStats> stats) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Daily Summaries', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Total Trains'), numeric: true),
                DataColumn(label: Text('Avg PDD'), numeric: true),
                DataColumn(label: Text('Trains <45M'), numeric: true),
                DataColumn(label: Text('% <45M'), numeric: true),
              ],
              rows: stats.map((s) {
                return DataRow(cells: [
                  DataCell(Text(s.dateString)),
                  DataCell(Text(s.totalTrains.toString())),
                  DataCell(Text(s.pddString)),
                  DataCell(Text(s.trainsBelow45.toString())),
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
