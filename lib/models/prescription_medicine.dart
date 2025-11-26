// TODO Implement this library.
// lib/models/prescription_medicine.dart

class PrescriptionMedicine {
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final String? duration;

  PrescriptionMedicine({
    required this.medicineName,
    this.dosage,
    this.frequency,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'doctype': 'Prescription Medicine', // اسم DocType الابن
      'parentfield': 'medicines', // اسم الحقل في DocType الأب
    };
  }

  // دالة copyWith المساعدة (ضرورية لعمل UI)
  PrescriptionMedicine copyWith({
    String? medicineName,
    String? dosage,
    String? frequency,
    String? duration,
  }) {
    return PrescriptionMedicine(
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
    );
  }
}
