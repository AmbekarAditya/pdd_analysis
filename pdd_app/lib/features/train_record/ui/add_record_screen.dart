import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../core/app_theme.dart';
import '../models/train_record.dart';
import '../providers/record_providers.dart';
import '../../../shared/providers/layout_providers.dart';
import '../../../core/utils/pdd_calculator.dart';

class AddRecordScreen extends ConsumerStatefulWidget {
  const AddRecordScreen({super.key});

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- 1. Basic Information ---
  DateTime _date = DateTime.now();
  final TextEditingController _trainNumberController = TextEditingController();
  String? _direction = 'UP';
  String? _trainType;
  String? _movementType;
  
  final List<String> _trainTypes = [
    'Passenger', 'Mail/Express', 'Superfast', 'MEMU/DEMU', 
    'Goods', 'Parcel', 'Special', 'Military'
  ];
  final List<String> _movementTypes = [
    'Originating', 'Through', 'Terminating', 'Turnaround'
  ];

  // --- 2. Timings ---
  final Map<String, TextEditingController> _timeControllers = {
    'Sign On': TextEditingController(),
    'TOC': TextEditingController(),
    'Ready': TextEditingController(),
    'Scheduled Departure': TextEditingController(),
    'Actual Departure': TextEditingController(),
  };

  // --- 3. Delay Attribution ---
  String? _subReason;
  Department _primaryDepartment = Department.unknown; // Enum based

  // Mapping from Department -> List of Sub-Reasons
  final Map<Department, List<String>> _departmentReasonMap = {
    Department.operating: ['Path unavailable', 'Crossing', 'Precedence', 'Platform unavailable'],
    Department.mechanical: ['Brake binding', 'Pipe disconnection', 'Hot axle', 'Spring breakage'],
    Department.electrical: ['OHE snap', 'Pantograph broken', 'Loco failure', 'No tension'],
    Department.snt: ['Signal failure', 'Point failure', 'Track circuit failure'],
    Department.commercial: ['ACP', 'Loading/Unloading', 'Parcel loading'],
    Department.security: ['Theft', 'Agitation', 'Line patrolling'],
    Department.external: ['Fog', 'Flood', 'Public agitation', 'Cattle run over'],
    Department.interDept: ['Late ordering', 'Crew shortage', 'Guard shortage'],
  };

  // Reverse mapping for quick lookup: SubReason -> Department
  final Map<String, Department> _subReasonToDepartment = {};

  // List for Dropdown (with headers)
  List<DropdownMenuItem<String>> _subReasonDropdownItems = [];

  // --- 4. Remarks ---
  final TextEditingController _remarksController = TextEditingController();

  // --- 5. Auto Calculated ---
  String _totalPDD = '0h 0m';
  String _crewTime = '0h 0m';
  int _pddMinutes = 0; // Source of truth
  int _crewTimeMinutes = 0; // Source of truth
  bool _excludeFromAvg = false;

  @override
  void initState() {
    super.initState();
    _initializeReasonMapping();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppBar();
    });

    // Listeners for auto-calculation
    _timeControllers['Ready']?.addListener(_calculateLogic);
    _timeControllers['Actual Departure']?.addListener(_calculateLogic);
    _timeControllers['Sign On']?.addListener(_calculateLogic);
    _timeControllers['TOC']?.addListener(_calculateLogic);
  }

  void _initializeReasonMapping() {
    _subReasonDropdownItems = [];
    _departmentReasonMap.forEach((dept, reasons) {
      // Add Department Header
      _subReasonDropdownItems.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: 'HEADER_${dept.name}', 
          child: Text(
            dept.label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
      // Add Reasons
      for (var reason in reasons) {
        _subReasonToDepartment[reason] = dept;
        _subReasonDropdownItems.add(
          DropdownMenuItem<String>(
            value: reason,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(reason),
            ),
          ),
        );
      }
    });
  }

  void _calculateLogic() {
    final signOn = _timeControllers['Sign On']?.text;
    final ready = _timeControllers['Ready']?.text;
    final actualDep = _timeControllers['Actual Departure']?.text;

    // 1. Calculate PDD: Actual Departure - Sign On
    _pddMinutes = PDDCalculator.calculateMinutesBetweenTimes(actualDep, signOn);
    _totalPDD = TrainRecord.formatMinutes(_pddMinutes);

    // 2. Calculate Crew Time: Ready - Sign On
    _crewTimeMinutes = PDDCalculator.calculateMinutesBetweenTimes(ready, signOn);
    _crewTime = TrainRecord.formatMinutes(_crewTimeMinutes);

    // 3. Update Primary Department based on selected Sub-Reason
    if (_subReason != null) {
      _primaryDepartment = _subReasonToDepartment[_subReason] ?? Department.unknown;
    } else {
      _primaryDepartment = Department.unknown;
    }

    // 4. Exclude Logic
    bool shouldExclude = false;
    if (_primaryDepartment == Department.external) {
      shouldExclude = true;
    } else if (_pddMinutes > 120) {
      shouldExclude = true;
    }
    _excludeFromAvg = shouldExclude;

    setState(() {});
  }

  @override
  void dispose() {
    for (var c in _timeControllers.values) c.dispose();
    _trainNumberController.dispose();
    _remarksController.dispose();
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
      for (var c in _timeControllers.values) c.clear();
      _subReason = null;
      _remarksController.clear();
      _primaryDepartment = Department.unknown;
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

    final record = TrainRecord(
      id: "0",
      date: _date,
      trainNumber: _trainNumberController.text,
      rollingStock: 'Unknown', 
      direction: _direction,
      trainType: _trainType,
      movementType: _movementType,
      signOnTime: _timeControllers['Sign On']?.text,
      tocTime: _timeControllers['TOC']?.text,
      readyTime: _timeControllers['Ready']?.text,
      scheduledDeparture: _timeControllers['Scheduled Departure']?.text,
      actualDeparture: _timeControllers['Actual Departure']?.text,
      primaryDepartment: _primaryDepartment, // Enum
      subReason: _subReason ?? 'Unknown', // Safe fallback if somehow null
      crewTime: _crewTime,
      isExcluded: _excludeFromAvg,
      pdd: _totalPDD,
      pddMinutes: _pddMinutes, // Source of truth
      crewTimeMinutes: _crewTimeMinutes, // Source of truth
      remarks: _remarksController.text,
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
// ... error handling

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
            _buildSection4Remarks(),
            const SizedBox(height: 16),
            _buildSection5Calculations(),
            const SizedBox(height: 32),
            _buildSection6Actions(),
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
                // strict validation can be added here
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
              'Sub-Reason *',
              double.infinity,
              DropdownButtonFormField<String>(
                value: _subReason,
                isExpanded: true,
                validator: (v) => v == null ? 'Required' : null,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Sub-Reason'),
                items: _subReasonDropdownItems,
                onChanged: (v) {
                  setState(() {
                    _subReason = v;
                    _calculateLogic();
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
              'Primary Department (Auto-Detected)',
              double.infinity,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _primaryDepartment == Department.unknown ? 'Auto-detected' : _primaryDepartment.label,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildSection4Remarks() {
    return _buildCard('Remarks', [
      _buildFieldContainer(
        'Operational Remarks (Optional)',
        double.infinity,
        TextFormField(
          controller: _remarksController,
          maxLines: 3,
          maxLength: 250,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter any additional details...',
          ),
        ),
      ),
    ]);
  }

  Widget _buildSection5Calculations() {
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

  Widget _buildSection6Actions() {
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
