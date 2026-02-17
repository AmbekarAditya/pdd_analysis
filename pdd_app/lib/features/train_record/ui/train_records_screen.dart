import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_theme.dart';
import '../models/train_record.dart';
import '../models/record_filter_state.dart'; // Import Filter State
import '../controllers/train_records_controller.dart'; // Import Controller
import '../../../shared/providers/layout_providers.dart';
import 'record_detail_screen.dart'; // Import Detail Screen

class TrainRecordsScreen extends ConsumerStatefulWidget {
  const TrainRecordsScreen({super.key});

  @override
  ConsumerState<TrainRecordsScreen> createState() => _TrainRecordsScreenState();
}

class _TrainRecordsScreenState extends ConsumerState<TrainRecordsScreen> {
  bool _isFilterExpanded = false;
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
      actions: [], // Search is now in-body
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/train-record/new'),
        label: const Text('Add New', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Helper to get color based on PDD minutes
  Color _getPddColor(String pdd) {
    int minutes = 0;
    try {
      final parts = pdd.split(' ');
      for (var part in parts) {
        if (part.endsWith('m')) minutes += int.parse(part.replaceAll('m', ''));
        if (part.endsWith('h')) minutes += int.parse(part.replaceAll('h', '')) * 60;
      }
    } catch (e) { return Colors.grey; }

    if (minutes == 0) return Colors.green;
    if (minutes <= 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredRecordsProvider);
    final summary = ref.read(recordsSummaryProvider); // Using read inside build for summary might not be reactive if provider is not watched? Check riverpod. 
    // Actually, if we want summary to update, we should Watch it.
    // Let's watch it.
    final summaryReactive = ref.watch(recordsSummaryProvider);

    return Column(
      children: [
        _buildSearchBar(),
        if (_isFilterExpanded) _buildFilterPanel(),
        _buildSummaryStrip(summaryReactive),
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(child: Text('No records found matching filters.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildRecordCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                 // Debouncing could be added here, but for now direct update
                 // Or use a Timer
                 ref.read(trainRecordsFilterProvider.notifier).setQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search Train No, Dept, Remarks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(_isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
            tooltip: 'Toggle Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    final filterState = ref.watch(trainRecordsFilterProvider);
    final controller = ref.read(trainRecordsFilterProvider.notifier);

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                     final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange: filterState.dateRange,
                      );
                      if (range != null) controller.setDateRange(range);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(filterState.dateRange == null
                      ? 'Date Range'
                      : '${DateFormat('MMM d').format(filterState.dateRange!.start)} - ${DateFormat('MMM d').format(filterState.dateRange!.end)}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filterState.direction ?? 'All',
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Direction',
                  ),
                  items: ['All', 'UP', 'DN'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => controller.setTrainFilters(direction: v == 'All' ? null : v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Add more filters here as per requirements (Departments, etc.)
          // For brevity in this turn, implementing basic ones first.
          // Requirement: "Department Filter (Multi-select)" - Complex UI, maybe Chips?
          const Text('Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
             spacing: 8,
             children: ['Operating (Traffic)', 'Mechanical (C&W)', 'External / Force Majeure'].map((dept) {
               final isSelected = filterState.selectedDepartments.contains(dept);
               return FilterChip(
                 label: Text(dept.split(' ')[0]), // Shorten name
                 selected: isSelected,
                 onSelected: (_) => controller.toggleDepartment(dept),
               );
             }).toList(),
          ),
           const SizedBox(height: 12),
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               TextButton(
                 onPressed: () => controller.resetFilters(),
                 child: const Text('Reset All'),
               ),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildSummaryStrip(TrainRecordSummary summary) { // Assuming we made this model
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', '${summary.totalRecords}'),
          _buildSummaryItem('Avg PDD', summary.averagePdd),
          _buildSummaryItem('Clean Avg', summary.cleanAveragePdd, color: Colors.green),
          _buildSummaryItem('Max Delay', summary.highestDelay, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color ?? Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecordCard(TrainRecord record) {
    final pddColor = _getPddColor(record.pdd);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: pddColor.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordDetailScreen(record: record),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.trainNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('${record.direction ?? ""} • ${record.trainType ?? ""}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(record.pdd, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: pddColor)),
                      const Text('PDD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.primaryDepartment ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(record.subReason ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (record.isExcluded)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('EXC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
