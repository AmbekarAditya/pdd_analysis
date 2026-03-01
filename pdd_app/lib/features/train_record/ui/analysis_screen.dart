import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_summary.dart';
import '../models/train_record.dart';
import '../controllers/daily_analysis_controller.dart';
import '../../../shared/providers/layout_providers.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool get _isDesktop => (kIsWeb && MediaQuery.of(context).size.width > 800) || 
                        (Theme.of(context).platform == TargetPlatform.macOS || 
                         Theme.of(context).platform == TargetPlatform.windows);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppBar();
    });
  }

  void _updateAppBar() {
    ref.read(appBarProvider.notifier).update(
      title: 'Daily PDD Analysis',
      actions: [], // Actions can be added here
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dailySummaryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(),
          const SizedBox(height: 24),
          summaryAsync.when(
            data: (summary) => _buildDashboard(summary),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final selectedDate = ref.watch(selectedDateProvider);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                ref.read(selectedDateProvider.notifier).previousDay();
              },
            ),
            TextButton.icon(
              onPressed: () async {
                 final d = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialEntryMode: _isDesktop ? DatePickerEntryMode.input : DatePickerEntryMode.calendar,
                );
                if (d != null) {
                   ref.read(selectedDateProvider.notifier).setDate(d);
                }
              },
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(DateFormat('EEEE, MMM d, yyyy').format(selectedDate), 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                 ref.read(selectedDateProvider.notifier).nextDay();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(DailySummary summary) {
    if (summary.totalMovements == 0) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text("No records found for this date.", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ));
    }

    return Column(
      children: [
        // 1. Snapshot Summary Cards
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Movements', '${summary.totalMovements}', Icons.train, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Total PDD', _formatMins(summary.totalPddMinutes), Icons.timer, Colors.orange)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
             Expanded(child: _buildSummaryCard('Avg PDD', '${summary.averagePddMinutes}m', Icons.analytics, Colors.purple)),
             const SizedBox(width: 12),
             Expanded(child: _buildSummaryCard('Avoidable Avg', '${summary.avoidableAvgPddMinutes}m', Icons.verified, Colors.green)),
          ],
        ),
        const SizedBox(height: 24),

        // 2 & 3. Department Contribution & Top Reasons (Side by side on large screens, stacked on small)
        LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
             return Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Expanded(child: _buildDeptContribution(summary)),
                 const SizedBox(width: 24),
                 Expanded(child: _buildTopReasons(summary)),
               ],
             );
          }
           return Column(
             children: [
               _buildDeptContribution(summary),
               const SizedBox(height: 24),
               _buildTopReasons(summary),
             ],
           );
        }),
        const SizedBox(height: 24),

        // 4. Clean vs Raw Comparison Panel
        _buildComparisonPanel(summary),
         const SizedBox(height: 24),

        // 5. Expandable Train List
        _buildTrainList(summary),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildDeptContribution(DailySummary summary) {
    // Sort departments by percentage descending
    final sortedDepts = summary.departmentContributionPercent.entries.toList()
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
            if (sortedDepts.isEmpty) Text('No delays recorded.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ...sortedDepts.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key.label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        Text('${e.value.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: e.value / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: Theme.of(context).colorScheme.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopReasons(DailySummary summary) {
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
            const Text('Top Sub-Reasons (Freq)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             const SizedBox(height: 20),
             if (summary.topSubReasons.isEmpty) Text('No reasons recorded.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
             ...summary.topSubReasons.map((e) {
               return Padding(
                 padding: const EdgeInsets.symmetric(vertical: 8),
                 child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: Theme.of(context).colorScheme.surfaceContainerHighest,
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                     ),
                     const SizedBox(width: 12),
                     Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                   ],
                 ),
               );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonPanel(DailySummary summary) {
    final diff = summary.averagePddMinutes - summary.avoidableAvgPddMinutes;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
           _buildCompItem('Unavoidable Trains', '${summary.unavoidableCount}', Theme.of(context).colorScheme.primary),
           Container(height: 40, width: 1, color: Theme.of(context).colorScheme.outlineVariant),
           _buildCompItem('Impact of Unavoidable Delays', '-${diff}m Avg', Colors.green),
        ],
      ),
    );
  }
  
  Widget _buildCompItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _buildTrainList(DailySummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detailed Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...summary.records.map((r) => _buildTrainRow(r)),
      ],
    );
  }

  Widget _buildTrainRow(TrainRecord record) {
     return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
             Text(record.trainNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
             const SizedBox(width: 8),
             if (record.isExcluded) 
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                 decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                 child: Text('EXC', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
               ),
          ],
        ),
        subtitle: Text('${record.primaryDepartment.label} • ${record.subReason}', 
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: Text(record.pddFormatted, 
          style: TextStyle(fontWeight: FontWeight.bold, color: record.pddColor)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Timings', 'Ready: ${record.readyTime ?? "-"}  |  Dep: ${record.actualDeparture ?? "-"}'),
                _buildDetailRow('Delays', 'Crew: ${record.crewTime ?? "-"}'),
                if (record.remarks != null && record.remarks!.isNotEmpty)
                   _buildDetailRow('Remarks', record.remarks!),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _formatMins(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }
}
