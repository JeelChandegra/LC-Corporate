import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';

class StorageService {
  static const String _boxName = 'medicines';
  late Box<Medicine> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicineAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReminderTimeAdapter());
    }
    _box = await Hive.openBox<Medicine>(_boxName);
  }

  List<Medicine> getAllMedicines() => _box.values.toList();

  Future<void> addMedicine(Medicine medicine) async {
    await _box.put(medicine.id, medicine);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _box.put(medicine.id, medicine);
  }

  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
  }

  Medicine? getMedicine(String id) => _box.get(id);

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> dispose() async {
    await _box.close();
  }
}
