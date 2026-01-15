import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/medicine_provider.dart';
import '../services/notification_service.dart';
import '../widgets/empty_placeholder.dart';
import '../widgets/medicine_card.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notification',
            onPressed: _testNotification,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAppInfo,
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.isEmpty) {
            return EmptyPlaceholder(
              onAddPressed: () => _navigateToAddMedicine(context),
            );
          }

          return _buildMedicineList(provider);
        },
      ),
      floatingActionButton: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          if (provider.isEmpty) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () => _navigateToAddMedicine(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Medicine'),
          );
        },
      ),
    );
  }

  Widget _buildMedicineList(MedicineProvider provider) {
    final medicines = provider.medicines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(
                Icons.medication,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Medicines',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${medicines.length} ${medicines.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return MedicineCard(
                medicine: medicine,
                onTap: () => _navigateToEditMedicine(context, medicine.id),
                onDelete: () => _deleteMedicine(context, medicine.id),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToAddMedicine(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMedicineScreen(),
      ),
    );
  }

  void _navigateToEditMedicine(BuildContext context, String medicineId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(medicineId: medicineId),
      ),
    );
  }

  void _deleteMedicine(BuildContext context, String id) {
    context.read<MedicineProvider>().deleteMedicine(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine deleted'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _testNotification() async {
    final notificationService = context.read<NotificationService>();
    await notificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! Check your notification tray.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.medication, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Medicine Reminder'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Never miss your medicine again!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Add your daily medicines with dose information'),
            Text('• Set reminders for each medicine'),
            Text('• Receive notifications at scheduled times'),
            Text('• Swipe left to delete a medicine'),
            Text('• Tap a medicine to edit it'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
