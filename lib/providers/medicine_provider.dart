import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  MedicineProvider({
    required StorageService storageService,
    required NotificationService notificationService,
  })  : _storageService = storageService,
        _notificationService = notificationService;

  List<Medicine> get medicines {
    final sorted = List<Medicine>.from(_medicines);
    sorted.sort((a, b) => a.timeInMinutes.compareTo(b.timeInMinutes));
    return sorted;
  }

  bool get isEmpty => _medicines.isEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMedicines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _medicines = _storageService.getAllMedicines();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load medicines: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMedicine({
    required String name,
    required String dose,
    required int hour,
    required int minute,
  }) async {
    try {
      final medicine = Medicine(
        id: _uuid.v4(),
        name: name,
        dose: dose,
        hour: hour,
        minute: minute,
      );

      await _storageService.addMedicine(medicine);
      _medicines.add(medicine);
      await _notificationService.scheduleMedicineReminder(medicine);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add medicine: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedicine({
    required String id,
    required String name,
    required String dose,
    required int hour,
    required int minute,
    bool? isEnabled,
  }) async {
    try {
      final index = _medicines.indexWhere((m) => m.id == id);
      if (index == -1) {
        _error = 'Medicine not found';
        return false;
      }

      final oldMedicine = _medicines[index];
      final updated = oldMedicine.copyWith(
        name: name,
        dose: dose,
        hour: hour,
        minute: minute,
        isEnabled: isEnabled,
      );

      await _storageService.updateMedicine(updated);
      _medicines[index] = updated;
      await _notificationService.rescheduleMedicineReminder(updated);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update medicine: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleMedicineStatus(String id) async {
    try {
      final index = _medicines.indexWhere((m) => m.id == id);
      if (index == -1) {
        _error = 'Medicine not found';
        return false;
      }

      final medicine = _medicines[index];
      final updated = medicine.copyWith(isEnabled: !medicine.isEnabled);

      await _storageService.updateMedicine(updated);
      _medicines[index] = updated;

      if (updated.isEnabled) {
        await _notificationService.scheduleMedicineReminder(updated);
      } else {
        await _notificationService.cancelMedicineReminder(updated);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle medicine status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMedicine(String id) async {
    try {
      final medicine = _medicines.firstWhere((m) => m.id == id);
      await _notificationService.cancelMedicineReminder(medicine);
      await _storageService.deleteMedicine(id);
      _medicines.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete medicine: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
