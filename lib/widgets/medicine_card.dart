import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggle;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
    this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(medicine.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTimeBadge(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: medicine.isEnabled
                              ? AppColors.textPrimary
                              : AppColors.disabled,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 16,
                            color: medicine.isEnabled
                                ? AppColors.textSecondary
                                : AppColors.disabled,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            medicine.dose,
                            style: TextStyle(
                              fontSize: 14,
                              color: medicine.isEnabled
                                  ? AppColors.textSecondary
                                  : AppColors.disabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: medicine.isEnabled,
                  onChanged: onToggle,
                  activeThumbColor: AppColors.accent,
                  activeTrackColor: AppColors.accentLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBadge() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: medicine.isEnabled
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.disabled.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 20,
            color: medicine.isEnabled ? AppColors.primary : AppColors.disabled,
          ),
          const SizedBox(height: 4),
          Text(
            medicine.formattedTime,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: medicine.isEnabled ? AppColors.primary : AppColors.disabled,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete "${medicine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
