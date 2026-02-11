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
  DateTime _date = DateTime.now();
  String? _selectedRollingStock;
  final TextEditingController _trainNumberController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // Time controllers
  final Map<String, TextEditingController> _timeControllers = {
    'Sign On Time': TextEditingController(),
    'Time of Completion (TOC)': TextEditingController(),
    'Ready Time': TextEditingController(),
    'Departure Time': TextEditingController(),
  };

  // Delay controllers
  final Map<String, TextEditingController> _delayControllers = {
    'Loco Delay': TextEditingController(),
    'C&W Delay': TextEditingController(),
    'Traffic Delay': TextEditingController(),
    'Other Delay': TextEditingController(),
  };

  String _totalDelay = '00:00';
  String _calculatedPDD = '0h 0m';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppBar();
    });

    // Add listeners for dynamic calculation
    for (var controller in _delayControllers.values) {
      controller.addListener(_updateTotalDelay);
    }
    _timeControllers['Ready Time']?.addListener(_updatePDD);
    _timeControllers['Departure Time']?.addListener(_updatePDD);
  }

  void _updateTotalDelay() {
    setState(() {
      _totalDelay = TrainRecord.calculateTotalDelay(
        _delayControllers.values.map((c) => c.text).toList(),
      );
    });
  }

  void _updatePDD() {
    setState(() {
      _calculatedPDD = TrainRecord.calculatePDD(
        _timeControllers['Departure Time']?.text,
        _timeControllers['Ready Time']?.text,
      );
    });
  }

  @override
  void dispose() {
    for (var controller in _delayControllers.values) {
      controller.removeListener(_updateTotalDelay);
    }
    _timeControllers['Ready Time']?.removeListener(_updatePDD);
    _timeControllers['Departure Time']?.removeListener(_updatePDD);
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

  void _resetForm() {
    setState(() {
      _date = DateTime.now();
      _selectedRollingStock = null;
      _trainNumberController.clear();
      _remarksController.clear();
      for (var controller in _timeControllers.values) {
        controller.clear();
      }
      for (var controller in _delayControllers.values) {
        controller.clear();
      }
    });
  }

  Future<void> _saveRecord() async {
    if (_trainNumberController.text.isEmpty || _selectedRollingStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Train Number and Rolling Stock')),
      );
      return;
    }

    final record = TrainRecord(
      id: "0", // Will be ignored by Drift auto-increment
      date: _date,
      trainNumber: _trainNumberController.text,
      rollingStock: _selectedRollingStock!,
      signOnTime: _timeControllers['Sign On Time']?.text,
      tocTime: _timeControllers['Time of Completion (TOC)']?.text,
      readyTime: _timeControllers['Ready Time']?.text,
      departureTime: _timeControllers['Departure Time']?.text,
      locoDelay: _delayControllers['Loco Delay']?.text,
      cwDelay: _delayControllers['C&W Delay']?.text,
      trafficDelay: _delayControllers['Traffic Delay']?.text,
      otherDelay: _delayControllers['Other Delay']?.text,
      remarks: _remarksController.text,
      status: 'Completed', 
      pdd: _calculatedPDD,
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
      child: Column(
        children: [
          _buildTrainInfoCard(),
          const SizedBox(height: 16),
          _buildTimesCard(),
          const SizedBox(height: 16),
          _buildDelaysCard(),
          const SizedBox(height: 16),
          _buildRemarksCard(),
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTrainInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Train Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final isPhone = constraints.maxWidth < 600;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildFormField(
                    'Date',
                    width: isPhone ? double.infinity : 200,
                    child: OutlinedButton.icon(
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
                      label: Text(DateFormat('PPP').format(_date)),
                    ),
                  ),
                  _buildFormField(
                    'Train Number *',
                    width: isPhone ? double.infinity : 200,
                    child: TextField(
                      controller: _trainNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Enter train number', border: OutlineInputBorder()),
                    ),
                  ),
                  _buildFormField(
                    'Rolling Stock *',
                    width: isPhone ? double.infinity : 200,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedRollingStock,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('Select stock'),
                      items: ['DN MU', 'UP BCNE', 'DN LE', 'UP PHDL', 'DN BOXN', 'UP MGKS', 'DN ICDW']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRollingStock = v),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Times', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _timeControllers.entries.map((e) {
                return _buildFormField(
                  e.key,
                  width: 180,
                  child: TextField(
                    controller: e.value,
                    readOnly: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.access_time, size: 16),
                      border: OutlineInputBorder(),
                      hintText: 'HH:MM',
                    ),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        e.value.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDelaysCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delays', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _delayControllers.entries.map((e) {
                return _buildFormField(
                  e.key,
                  width: 150,
                  child: TextField(
                    controller: e.value,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.timer_outlined, size: 16),
                      border: OutlineInputBorder(),
                      hintText: 'HH:MM',
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Total Delay: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                  child: Text(_totalDelay, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 24),
                const Text('Est. PDD: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(_calculatedPDD, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: _remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter any additional remarks...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(onPressed: _resetForm, child: const Text('Reset Form')),
        const SizedBox(width: 12),
        OutlinedButton(onPressed: () => context.go('/train-records'), child: const Text('Cancel')),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _saveRecord,
          icon: const Icon(Icons.save, size: 18, color: Colors.white),
          label: const Text('Save Record', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, {required Widget child, double? width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
