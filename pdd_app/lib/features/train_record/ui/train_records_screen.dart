import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_theme.dart';
import '../models/train_record.dart';
import '../models/record_filter_state.dart'; 
import '../controllers/train_records_controller.dart'; 
import '../providers/record_providers.dart';
import '../../../shared/providers/layout_providers.dart';

class TrainRecordsScreen extends ConsumerStatefulWidget {
  const TrainRecordsScreen({super.key});

  @override
  ConsumerState<TrainRecordsScreen> createState() => _TrainRecordsScreenState();
}

class _TrainRecordsScreenState extends ConsumerState<TrainRecordsScreen> {
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
      actions: [], 
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
  
  // _getPddColor removed - moved to TrainRecord model.

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredRecordsProvider);
    final summary = ref.watch(recordsSummaryProvider);

    return Column(
      children: [
        _buildSearchBar(),
        _buildChipFilterRow(),
        _buildSummaryStrip(summary),
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(child: Text('No records found matching filters.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Bottom padding for FAB
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildExpandableRecordCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
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
    );
  }

  Widget _buildChipFilterRow() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Date Filters
          _buildDateChip('Today', DateFilterPreset.today),
          _buildDateChip('Last 7 Days', DateFilterPreset.last7Days),
          _buildDateChip('This Month', DateFilterPreset.thisMonth),
          
          const VerticalDivider(width: 24, indent: 8, endIndent: 8),
          
          // Status Filters
          _buildStatusChip('Excluded', RecordStatusFilter.excluded),
          _buildStatusChip('Non-Excluded', RecordStatusFilter.nonExcluded),
          _buildStatusChip('High Delay >30', RecordStatusFilter.highDelay),
          _buildStatusChip('Zero Delay', RecordStatusFilter.zeroDelay),

          const VerticalDivider(width: 24, indent: 8, endIndent: 8),

          // Department Filters (Simplified list for UI)
          ...['Operating (Traffic)', 'Mechanical (C&W)', 'Electrical (TRD / Loco)', 
              'S&T', 'Commercial', 'Security', 'External', 'Inter-Dept']
            .map((dept) => _buildDeptChip(dept)).toList(),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, DateFilterPreset preset) {
    final state = ref.watch(trainRecordsFilterProvider);
    final isSelected = state.dateFilter == preset;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(trainRecordsFilterProvider.notifier).toggleDateFilter(preset);
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, RecordStatusFilter filter) {
    final state = ref.watch(trainRecordsFilterProvider);
    final isSelected = state.selectedStatusFilters.contains(filter);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(trainRecordsFilterProvider.notifier).toggleStatusFilter(filter);
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDeptChip(String dept) {
    final state = ref.watch(trainRecordsFilterProvider);
    // Matching logic might need to be robust if department names vary
    // Assuming exact string match for now based on previous impl
    // Shorten label for Chip
    String label = dept.split(' (')[0]; 
    if(dept.contains('/')) label = dept.split(' /')[0];

    final isSelected = state.selectedDepartments.contains(dept); // Logic uses full name
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
           // We need to pass FULL name to logic
           // The list above needs to match logic exactly
           // Logic uses: 'Operating (Traffic)', etc.
           // In _buildChipFilterRow I passed the full name to _buildDeptChip
           ref.read(trainRecordsFilterProvider.notifier).toggleDepartment(dept);
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSummaryStrip(TrainRecordSummary summary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', '${summary.totalRecords}'),
          _buildSummaryItem('Avg PDD', summary.averagePdd),
          _buildSummaryItem('Clean Avg', summary.cleanAveragePdd, color: Colors.green[700]),
          _buildSummaryItem('Max Delay', summary.highestDelay, color: Colors.red[700]),
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

  Widget _buildExpandableRecordCard(TrainRecord record) {
    final pddColor = record.pddColor;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: pddColor.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Customizing title/subtitle to match desired row look
          title: Row(
            children: [
              Text(record.trainNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(width: 8),
              if (record.isExcluded)
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                    child: const Text('EXC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                 ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('${DateFormat('MMM d').format(record.date)} • ${record.direction} • ${record.trainType}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text(record.subReason, 
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis)),
                ],
              )
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(record.pddFormatted, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: pddColor)),
              const Text('PDD', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          children: [
            Container(
              color: Colors.grey[50], // Subtle background for expanded area
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInlineDetailRow('Timings', 
                    'Sign On: ${record.signOnTime ?? "-"}  •  TOC: ${record.tocTime ?? "-"}  •  Ready: ${record.readyTime ?? "-"}'),
                  const SizedBox(height: 8),
                  _buildInlineDetailRow('Departure', 
                    'Sched: ${record.scheduledDeparture ?? "-"}  •  Actual: ${record.actualDeparture ?? "-"}'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                   _buildInlineDetailRow('Attribution', 
                    '${record.primaryDepartment.label}\nReason: ${record.subReason}'),
                  const SizedBox(height: 8),
                  if (record.remarks != null && record.remarks!.isNotEmpty)
                     _buildInlineDetailRow('Remarks', record.remarks!),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Crew Time: ${record.crewTime ?? "-"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Total PDD: ${record.pddFormatted}', style: TextStyle(fontWeight: FontWeight.bold, color: pddColor)),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit coming soon')));
                            },
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _confirmDelete(record),
                            tooltip: 'Delete Record',
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, height: 1.4)),
      ],
    );
  }

  Future<void> _confirmDelete(TrainRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete Train ${record.trainNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recordRepositoryProvider).deleteRecord(record.id);
    }
  }
}
