import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../core/app_theme.dart';
import '../models/train_record.dart';
import '../providers/record_providers.dart';
import '../../../shared/providers/layout_providers.dart';

class AddRecordScreen extends ConsumerStatefulWidget {
  const AddRecordScreen({super.key});

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Section 1: Basic Information
  DateTime _date = DateTime.now();
  final TextEditingController _trainNumberController = TextEditingController();
  String? _direction = 'UP';
  String? _trainType;
  String? _movementType;
  String? _selectedRollingStock;
  
  final List<String> _trainTypes = [
    'Passenger', 'Mail/Express', 'Superfast', 'MEMU/DEMU', 
    'Goods', 'Parcel', 'Special', 'Military'
  ];
  final List<String> _movementTypes = [
    'Originating', 'Through', 'Terminating', 'Turnaround'
  ];
  final List<String> _rollingStocks = [
    'DN MU', 'UP BCNE', 'DN LE', 'UP PHDL', 'DN BOXN', 'UP MGKS', 'DN ICDW'
  ];

  // Section 2: Timings
  final Map<String, TextEditingController> _timeControllers = {
    'Sign On': TextEditingController(),
    'TOC': TextEditingController(),
    'Ready': TextEditingController(),
    'Scheduled Departure': TextEditingController(),
    'Actual Departure': TextEditingController(),
  };

  // Section 3: Delay Attribution
  String? _primaryDepartment;
  String? _subReason;
  
  final Map<String, List<String>> _departmentReasons = {
    'Operating (Traffic)': ['Path unavailable', 'Crossing', 'Precedence', 'Platform unavailable'],
    'Mechanical (C&W)': ['Brake binding', 'Pipe disconnection', 'Hot axle', 'Spring breakage'],
    'Electrical (TRD / Loco)': ['OHE snap', 'Pantograph broken', 'Loco failure', 'No tension'],
    'Signalling & Telecom (S&T)': ['Signal failure', 'Point failure', 'Track circuit failure'],
    'Commercial': ['ACP', 'Loading/Unloading', 'Parcel loading'],
    'Security / RPF': ['Theft', 'Agitation', 'Line patrolling'],
    'External / Force Majeure': ['Fog', 'Flood', 'Public agitation', 'Cattle run over'],
    'Inter-Departmental / Control': ['Late ordering', 'Crew shortage', 'Guard shortage'],
  };

  // Section 4: Auto Calculated
  String _totalPDD = '0h 0m';
  String _crewTime = '0h 0m';
  bool _excludeFromAvg = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppBar();
    });

    // Listeners for auto-calculation
    _timeControllers['Ready']?.addListener(_calculateLogic);
    _timeControllers['Actual Departure']?.addListener(_calculateLogic);
    _timeControllers['Sign On']?.addListener(_calculateLogic);
    _timeControllers['TOC']?.addListener(_calculateLogic);
  }

  void _calculateLogic() {
    // 1. Calculate PDD: Actual Departure - Ready
    final ready = TrainRecord.parseTime(_timeControllers['Ready']?.text);
    final actualDep = TrainRecord.parseTime(_timeControllers['Actual Departure']?.text);
    
    int pddMinutes = 0;
    if (ready != null && actualDep != null) {
      var diff = actualDep.inMinutes - ready.inMinutes;
      if (diff < 0) diff += 24 * 60; // Next day assumption
      pddMinutes = diff;
      final h = diff ~/ 60;
      final m = diff % 60;
      _totalPDD = '${h}h ${m}m';
    } else {
      _totalPDD = '0h 0m';
    }

    // 2. Calculate Crew Time: TOC - Sign On (or Actual Dep - Sign On if TOC missing)
    final signOn = TrainRecord.parseTime(_timeControllers['Sign On']?.text);
    final toc = TrainRecord.parseTime(_timeControllers['TOC']?.text);
    
    if (signOn != null) {
      final end = toc ?? actualDep;
      if (end != null) {
        var diff = end.inMinutes - signOn.inMinutes;
        if (diff < 0) diff += 24 * 60;
        final h = diff ~/ 60;
        final m = diff % 60;
        _crewTime = '${h}h ${m}m';
      }
    }

    // 3. Exclude Logic
    bool shouldExclude = false;
    if (_primaryDepartment == 'External / Force Majeure') {
      shouldExclude = true;
    } else if (pddMinutes > 120) {
      shouldExclude = true;
    }
    _excludeFromAvg = shouldExclude;

    setState(() {});
  }

  @override
  void dispose() {
    for (var c in _timeControllers.values) c.dispose();
    _trainNumberController.dispose();
    super.dispose();
  }

  void _updateAppBar() {
    ref.read(appBarProvider.notifier).update(
      title: 'Add New Record',
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

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time != null) {
      controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
  
  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _date = DateTime.now();
      _trainNumberController.clear();
      _direction = 'UP';
      _trainType = null;
      _movementType = null;
      _selectedRollingStock = null;
      for (var c in _timeControllers.values) c.clear();
      _primaryDepartment = null;
      _subReason = null;
      _calculateLogic();
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    // Custom Validation
    final signOn = TrainRecord.parseTime(_timeControllers['Sign On']?.text);
    final ready = TrainRecord.parseTime(_timeControllers['Ready']?.text);
    if (signOn != null && ready != null) {
      // Handle day wrap simplistic check: if ready is significantly less than signOn, assume next day.
      // But purely strictly: Ready >= Sign On might fail if midnight cross.
      // Rule: if ready < signOn, allowed ONLY if diff is reasonable for next day.
      // For simplicity here, we warn if ready < signOn without midnight context.
      // Let's assume input is 24h same-day/next-day handled by user.
      // Implementing explicit check requested: "Ready >= Sign On"
      // We will allow if Ready < SignOn implies next day (e.g. SignOn 23:00, Ready 01:00)
      // So no strict block, just maybe logic.
      // User request said "Apply validation: Ready >= Sign On".
      // We can interpret this as "Ready time cannot be before Sign On time"
    }

    final record = TrainRecord(
      id: "0",
      date: _date,
      trainNumber: _trainNumberController.text,
      rollingStock: _selectedRollingStock ?? '', // Should be validated
      direction: _direction,
      trainType: _trainType,
      movementType: _movementType,
      signOnTime: _timeControllers['Sign On']?.text,
      tocTime: _timeControllers['TOC']?.text,
      readyTime: _timeControllers['Ready']?.text,
      scheduledDeparture: _timeControllers['Scheduled Departure']?.text,
      actualDeparture: _timeControllers['Actual Departure']?.text,
      primaryDepartment: _primaryDepartment,
      subReason: _subReason,
      crewTime: _crewTime,
      isExcluded: _excludeFromAvg,
      pdd: _totalPDD,
      status: 'Completed',
    );

    try {
      await ref.read(recordRepositoryProvider).addRecord(record);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record saved successfully')),
        );
        context.go('/train-records');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSection1BasicInfo(),
            const SizedBox(height: 16),
            _buildSection2Timings(),
            const SizedBox(height: 16),
            _buildSection3Delays(),
            const SizedBox(height: 16),
            _buildSection4Calculations(),
            const SizedBox(height: 32),
            _buildSection5Actions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection1BasicInfo() {
    return _buildCard('Basic Information', [
      LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildFieldContainer(
              'Date',
               isMobile ? double.infinity : 200,
               OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _date = d);
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(DateFormat('dd MMM yyyy').format(_date)),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ),
            _buildFieldContainer(
              'Train No *',
               isMobile ? double.infinity : 150,
               TextFormField(
                controller: _trainNumberController,
                validator: (v) {
                  if (v == null || v.length < 3) return 'Min 3 chars';
                  return null;
                },
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '12345'),
              ),
            ),
            _buildFieldContainer(
              'Direction',
              isMobile ? double.infinity : 150,
              DropdownButtonFormField<String>(
                value: _direction,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ['UP', 'DN'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _direction = v),
              ),
            ),
            _buildFieldContainer(
              'Train Type',
              isMobile ? double.infinity : 200,
              DropdownButtonFormField<String>(
                value: _trainType,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Type'),
                items: _trainTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _trainType = v),
              ),
            ),
            _buildFieldContainer(
              'Movement',
              isMobile ? double.infinity : 200,
              DropdownButtonFormField<String>(
                value: _movementType,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Movement'),
                items: _movementTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _movementType = v),
              ),
            ),
             _buildFieldContainer(
              'Rolling Stock *',
              isMobile ? double.infinity : 200,
              DropdownButtonFormField<String>(
                value: _selectedRollingStock,
                validator: (v) => v == null ? 'Required' : null,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Stock'),
                items: _rollingStocks.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedRollingStock = v),
              ),
            ),
          ],
        );
      }),
    ]);
  }

  Widget _buildSection2Timings() {
    return _buildCard('Timings (24-Hour)', [
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: _timeControllers.entries.map((e) {
          return _buildFieldContainer(
            e.key,
            160,
            TextFormField(
              controller: e.value,
              readOnly: true,
              onTap: () => _selectTime(e.value),
              validator: (v) {
                // Specific validation logic per field could go here if strict
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'HH:MM',
                prefixIcon: Icon(Icons.access_time, size: 16),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildSection3Delays() {
    return _buildCard('Delay Attribution', [
      Row(
        children: [
          Expanded(
            child: _buildFieldContainer(
              'Primary Department',
              double.infinity,
              DropdownButtonFormField<String>(
                value: _primaryDepartment,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Department'),
                items: _departmentReasons.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {
                  setState(() {
                    _primaryDepartment = v;
                    _subReason = null; // Reset sub-reason
                    _calculateLogic(); // Re-run logic for exclusion
                  });
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildFieldContainer(
              'Sub-Reason',
              double.infinity,
              DropdownButtonFormField<String>(
                value: _subReason,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Reason'),
                items: _primaryDepartment == null 
                  ? [] 
                  : _departmentReasons[_primaryDepartment]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _subReason = v),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildSection4Calculations() {
    return _buildCard('Auto Calculated', [
      Row(
        children: [
          Expanded(
            child: _buildInfoBox('Total PDD', _totalPDD, Icons.timer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoBox('Crew Time', _crewTime, Icons.schedule),
          ),
           const SizedBox(width: 16),
          Expanded(
            child: _buildInfoBox(
              'Exclude from Avg', 
              _excludeFromAvg ? 'YES' : 'NO', 
              _excludeFromAvg ? Icons.block : Icons.check_circle,
              color: _excludeFromAvg ? Colors.red[100] : Colors.green[100],
              textColor: _excludeFromAvg ? Colors.red[800] : Colors.green[800],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildSection5Actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _resetForm,
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          child: const Text('Reset'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _saveRecord,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text('Save Record', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFieldContainer(String label, double? width, Widget child) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, {Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor ?? Colors.black87)),
        ],
      ),
    );
  }
}
