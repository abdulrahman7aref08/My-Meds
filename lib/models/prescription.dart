// lib/models/prescription.dart

import 'prescription_medicine.dart';

class Prescription {
  final String patient;
  final String doctor;
  final String? notes;
  final List<PrescriptionMedicine> medicines;

  Prescription({
    required this.patient,
    required this.doctor,
    this.notes,
    required this.medicines,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient': patient,
      'doctor': doctor,
      'notes': notes,
      'medicines': medicines.map((m) => m.toJson()).toList(), // قائمة الأبناء
      'doctype': 'Prescription', // اسم DocType الأب
    };
  }
}
