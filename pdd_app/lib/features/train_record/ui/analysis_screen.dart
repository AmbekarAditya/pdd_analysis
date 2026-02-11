import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../models/train_record.dart';
import '../providers/record_providers.dart';

import '../../../core/app_theme.dart';
import '../../../shared/providers/layout_providers.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  DateTime _currentDate = DateTime.now();
  final Set<String> _expandedRows = {};

  void _updateAppBar(List<TrainRecord> records) {
    ref.read(appBarProvider.notifier).update(
      title: 'Daily PDD Analysis',
      actions: [
        if (records.isNotEmpty)
          TextButton.icon(
            onPressed: () => _exportCSV(records),
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Export CSV', style: TextStyle(color: Colors.white)),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: const Text('SC', style: TextStyle(color: Colors.white)),
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
        final filtered = records.where((r) => 
          r.date.year == _currentDate.year && 
          r.date.month == _currentDate.month && 
          r.date.day == _currentDate.day).toList();
            
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateAppBar(filtered);
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateSelector(),
              const SizedBox(height: 24),
              _buildAnalysisTable(filtered),
              const SizedBox(height: 24),
              _buildExportButtons(filtered),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1))),
            ),
            TextButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _currentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (d != null) setState(() => _currentDate = d);
              },
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(DateFormat('MMMM d, yyyy').format(_currentDate), 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _currentDate = _currentDate.add(const Duration(days: 1))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTable(List<TrainRecord> records) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Train PDD Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (records.isEmpty) 
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No records for this date', style: TextStyle(color: Colors.grey))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('Train No')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Sign On')),
                  DataColumn(label: Text('TOC')),
                  DataColumn(label: Text('Ready')),
                  DataColumn(label: Text('Dep')),
                  DataColumn(label: Text('PDD')),
                ],
                rows: records.expand((train) => [
                  DataRow(
                    onSelectChanged: (_) {
                      setState(() {
                        if (_expandedRows.contains(train.id)) {
                          _expandedRows.remove(train.id);
                        } else {
                          _expandedRows.add(train.id);
                        }
                      });
                    },
                    cells: [
                      DataCell(Text(train.trainNumber)),
                      DataCell(Text(train.rollingStock)),
                      DataCell(Text(train.signOnTime ?? '--')),
                      DataCell(Text(train.tocTime ?? '--')),
                      DataCell(Text(train.readyTime ?? '--')),
                      DataCell(Text(train.departureTime ?? '--')),
                      DataCell(Text(train.pdd, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  if (_expandedRows.contains(train.id))
                    DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[50],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Delay Breakdown:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Loco: ${train.locoDelay ?? '00:00'} | C&W: ${train.cwDelay ?? '00:00'} | Traffic: ${train.trafficDelay ?? '00:00'} | Other: ${train.otherDelay ?? '00:00'}'),
                                const SizedBox(height: 8),
                                const Text('Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(train.remarks ?? 'No remarks'),
                              ],
                            ),
                          ),
                          placeholder: true,
                        ),
                        const DataCell(SizedBox.shrink()),
                        const DataCell(SizedBox.shrink()),
                        const DataCell(SizedBox.shrink()),
                        const DataCell(SizedBox.shrink()),
                        const DataCell(SizedBox.shrink()),
                        const DataCell(SizedBox.shrink()),
                      ],
                    ),
                ]).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(List<TrainRecord> records) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: records.isEmpty ? null : () => _exportCSV(records),
          icon: const Icon(Icons.description_outlined),
          label: const Text('Export CSV'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: null, // PDF Export placeholder
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Export PDF'),
        ),
      ],
    );
  }

  Future<void> _exportCSV(List<TrainRecord> records) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Date',
      'Train No',
      'Rolling Stock',
      'Sign On',
      'TOC',
      'Ready',
      'Departure',
      'PDD',
      'Loco Delay',
      'C&W Delay',
      'Traffic Delay',
      'Other Delay',
      'Remarks'
    ]);

    // Data
    for (var r in records) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(r.date),
        r.trainNumber,
        r.rollingStock,
        r.signOnTime ?? '',
        r.tocTime ?? '',
        r.readyTime ?? '',
        r.departureTime ?? '',
        r.pdd,
        r.locoDelay ?? '',
        r.cwDelay ?? '',
        r.trafficDelay ?? '',
        r.otherDelay ?? '',
        r.remarks ?? ''
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
    final fileName = 'pdd_report_$dateStr.csv';

    if (kIsWeb) {
      // For web, use Share.shareXFiles with a data URI or just Share.share
      // but share_plus on web works best with Share.shareXFiles for files
      final bytes = Uint8List.fromList(csvData.codeUnits);
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: 'text/csv')],
      );
    } else {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles(
        [XFile(path)],
        subject: 'PDD Report - $dateStr',
      );
    }
  }
}
