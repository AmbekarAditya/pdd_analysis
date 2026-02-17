import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../models/train_record.dart';
import '../repositories/record_repository.dart';
import '../providers/record_providers.dart';

class RecordDetailScreen extends ConsumerWidget {
  final TrainRecord record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Train No: ${record.trainNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to Edit Screen (Future Scope)
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Record'),
                  content: const Text('Are you sure you want to delete this record?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(recordRepositoryProvider).deleteRecord(record.id);
                if (context.mounted) {
                  context.pop(); // Return to list
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(record),
            const SizedBox(height: 16),
            _buildTimingsCard(record),
            const SizedBox(height: 16),
            _buildDelayCard(record),
            const SizedBox(height: 16),
            if (record.remarks != null && record.remarks!.isNotEmpty)
              _buildRemarksCard(record),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(TrainRecord record) {
    Color color = Colors.grey;
    if (record.status == 'Completed') color = Colors.green;
    if (record.status == 'Delayed') color = Colors.red;
    if (record.status == 'In Progress') color = Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${DateFormat('dd MMM yyyy').format(record.date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Direction: ${record.direction ?? "N/A"}'),
                Text('Type: ${record.trainType ?? "N/A"}'),
              ],
            ),
            const Spacer(),
            Chip(
              label: Text(record.status.toUpperCase(),
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingsCard(TrainRecord record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timings',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor)),
            const Divider(),
            _buildRow('Sign On', record.signOnTime),
            _buildRow('TOC', record.tocTime),
            _buildRow('Ready', record.readyTime),
            _buildRow('Sched. Dep', record.scheduledDeparture),
            _buildRow('Actual Dep', record.actualDeparture),
            const Divider(),
            _buildRow('Crew Time', record.crewTime, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDelayCard(TrainRecord record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delay Analytics',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor)),
            const Divider(),
            _buildRow('Primary Dept', record.primaryDepartment),
            _buildRow('Sub-Reason', record.subReason),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50], // Light red background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total PDD',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                  Text(record.pdd,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red)),
                ],
              ),
            ),
             if (record.isExcluded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Chip(
                  label: const Text('Excluded from Avg'),
                  backgroundColor: Colors.grey[200],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard(TrainRecord record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Remarks',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor)),
            const Divider(),
            Text(record.remarks!),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String? value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value ?? '-',
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
