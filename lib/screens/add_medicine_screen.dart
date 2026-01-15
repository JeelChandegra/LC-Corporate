import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../services/storage_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final String? medicineId;

  const AddMedicineScreen({super.key, this.medicineId});

  bool get isEditing => medicineId != null;

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  
  List<TimeOfDay> _selectedTimes = [TimeOfDay.now()];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingMedicine();
      });
    }
  }

  void _loadExistingMedicine() {
    final storageService = context.read<StorageService>();
    final medicine = storageService.getMedicine(widget.medicineId!);
    
    if (medicine != null) {
      setState(() {
        _nameController.text = medicine.name;
        _doseController.text = medicine.dose;
        // Load all reminder times
        _selectedTimes = medicine.allReminderTimes
            .map((r) => TimeOfDay(hour: r.hour, minute: r.minute))
            .toList();
        if (_selectedTimes.isEmpty) {
          _selectedTimes = [TimeOfDay(hour: medicine.hour, minute: medicine.minute)];
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderIcon(),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildDoseField(),
              const SizedBox(height: 24),
              _buildTimePicker(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.medication_liquid,
          size: 50,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicine Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., Paracetamol',
            prefixIcon: Icon(Icons.medication_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the medicine name';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDoseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dose',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _doseController,
          decoration: const InputDecoration(
            hintText: 'e.g., 500mg, 2 tablets',
            prefixIcon: Icon(Icons.medical_services_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the dose';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Reminder Times',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addNewTime,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Time'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._selectedTimes.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTimeItem(time, index),
          );
        }),
      ],
    );
  }

  Widget _buildTimeItem(TimeOfDay time, int index) {
    return InkWell(
      onTap: () => _selectTime(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.access_time,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder ${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(time),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accent),
              onPressed: () => _selectTime(index),
            ),
            if (_selectedTimes.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removeTime(index),
              ),
          ],
        ),
      ),
    );
  }

  void _addNewTime() {
    setState(() {
      // Add a new time 1 hour after the last one
      final lastTime = _selectedTimes.last;
      final newHour = (lastTime.hour + 1) % 24;
      _selectedTimes.add(TimeOfDay(hour: newHour, minute: lastTime.minute));
    });
  }

  void _removeTime(int index) {
    if (_selectedTimes.length > 1) {
      setState(() {
        _selectedTimes.removeAt(index);
      });
    }
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveMedicine,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: _isSaving
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: AppColors.textOnAccent,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.isEditing ? Icons.save : Icons.add_alarm),
                const SizedBox(width: 8),
                Text(widget.isEditing ? 'Save Changes' : 'Add Medicine'),
              ],
            ),
    );
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              secondary: AppColors.accent,
              onSecondary: AppColors.textOnAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTimes[index]) {
      setState(() {
        _selectedTimes[index] = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<MedicineProvider>();
    
    // Convert TimeOfDay list to ReminderTime list
    final reminderTimes = _selectedTimes
        .map((t) => ReminderTime(hour: t.hour, minute: t.minute))
        .toList();
    
    bool success;

    if (widget.isEditing) {
      success = await provider.updateMedicine(
        id: widget.medicineId!,
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        hour: _selectedTimes.first.hour,
        minute: _selectedTimes.first.minute,
        reminderTimes: reminderTimes,
      );
    } else {
      success = await provider.addMedicine(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        hour: _selectedTimes.first.hour,
        minute: _selectedTimes.first.minute,
        reminderTimes: reminderTimes,
      );
    }

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Medicine updated successfully!'
                : 'Medicine added successfully!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'An error occurred'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
