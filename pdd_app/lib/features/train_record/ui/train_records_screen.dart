import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_theme.dart';
import '../models/train_record.dart';
import '../providers/record_providers.dart';
import '../../../shared/providers/layout_providers.dart';

class TrainRecordsScreen extends ConsumerStatefulWidget {
  const TrainRecordsScreen({super.key});

  @override
  ConsumerState<TrainRecordsScreen> createState() => _TrainRecordsScreenState();
}

class _TrainRecordsScreenState extends ConsumerState<TrainRecordsScreen> {
  DateTimeRange? _dateRange;
  String _selectedRollingStock = 'All';
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppBar();
    });
  }

  void _updateAppBar() {
    ref.read(appBarProvider.notifier).update(
      title: 'Train Records',
      actions: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text('SC', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/train-record/new'),
        label: const Text('Add New Record', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(trainRecordsStreamProvider);

    return recordsAsync.when(
      data: (records) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFilterBar(),
            const SizedBox(height: 24),
            _buildSummaryCards(records),
            const SizedBox(height: 24),
            _buildRecordsTable(records),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildFilterItem(
                  'Date Range',
                  OutlinedButton.icon(
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange: _dateRange,
                      );
                      if (range != null) setState(() => _dateRange = range);
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_dateRange == null
                        ? 'Pick Date Range'
                        : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'),
                  ),
                ),
                _buildFilterItem(
                  'Rolling Stock',
                  DropdownButton<String>(
                    value: _selectedRollingStock,
                    items: ['All', 'DN MU', 'UP BCNE', 'DN LE', 'UP PHDL', 'DN BOXN', 'UP MGKS', 'DN ICDW']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRollingStock = v!),
                  ),
                ),
                _buildFilterItem(
                  'Status',
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: ['All', 'Completed', 'Delayed', 'In Progress']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search remarks...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _dateRange = null;
                      _selectedRollingStock = 'All';
                      _selectedStatus = 'All';
                      _searchController.clear();
                    });
                  },
                  child: const Text('Reset Filters'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildSummaryCards(List<TrainRecord> records) {
    final completed = records.where((r) => r.status == 'Completed').length;
    final delayed = records.where((r) => r.status == 'Delayed').length;
    final inProgress = records.where((r) => r.status == 'In Progress').length;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return GridView.count(
        crossAxisCount: isMobile ? 2 : 4,
        childAspectRatio: isMobile ? 1.5 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildCompactSummaryCard('Total', '${records.length}', Icons.train_outlined),
          _buildCompactSummaryCard('Completed', '$completed', Icons.check_circle_outline, color: Colors.green),
          _buildCompactSummaryCard('Delayed', '$delayed', Icons.warning_amber_outlined, color: Colors.red),
          _buildCompactSummaryCard('In Progress', '$inProgress', Icons.pending_outlined, color: Colors.orange),
        ],
      );
    });
  }

  Widget _buildCompactSummaryCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color ?? Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsTable(List<TrainRecord> records) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Recent Records', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Train No')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('PDD')),
                DataColumn(label: Text('Actions')),
              ],
              rows: records.map((record) => _buildRecordRow(record)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRecordRow(TrainRecord record) {
    Color statusColor = Colors.grey;
    if (record.status == 'Completed') statusColor = Colors.green;
    if (record.status == 'Delayed') statusColor = Colors.red;
    if (record.status == 'In Progress') statusColor = Colors.orange;

    return DataRow(cells: [
      DataCell(Text(record.trainNumber)),
      DataCell(Text(record.rollingStock)),
      DataCell(Text(DateFormat('MMM d, y').format(record.date))),
      DataCell(Chip(
        label: Text(record.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
        backgroundColor: statusColor,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      )),
      DataCell(Text(record.pdd)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Record'),
                  content: const Text('Are you sure you want to delete this record?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(recordRepositoryProvider).deleteRecord(record.id);
              }
            },
          ),
        ],
      )),
    ]);
  }
}
