import 'package:flutter/material.dart';
import 'package:my_medsen/models/prescription.dart';
import 'package:my_medsen/models/prescription_medicine.dart';
import '../services/erpnext_service.dart';

class AddPrescriptionPage extends StatefulWidget {
  const AddPrescriptionPage({super.key});

  @override
  State<AddPrescriptionPage> createState() => _AddPrescriptionPageState();
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  // مفتاح التحقق من صحة الحقول
  final _formKey = GlobalKey<FormState>();

  // متحكمات الحقول الرئيسية
  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // قائمة ديناميكية للأدوية (Prescription Medicine)
  final List<PrescriptionMedicine> _medicines = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ابدأ دائماً بصف واحد للدواء لتسهيل الإدخال
    _medicines.add(
      PrescriptionMedicine(
        medicineName: '',
        dosage: '',
        frequency: 'Once Daily', // قيمة افتراضية
        duration: '',
      ),
    );
  }

  // **********************************************
  // دالة الإرسال إلى ERPNext
  // **********************************************
  Future<void> _submitPrescription() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 1. إنشاء كائن Prescription من البيانات المدخلة
      final newPrescription = Prescription(
        patient: _patientController.text,
        doctor: _doctorController.text,
        notes: _notesController.text,
        // إزالة الصفوف الفارغة قبل الإرسال
        medicines: _medicines
            .where((m) => m.medicineName.isNotEmpty)
            .toList(),
      );

      // 2. استدعاء خدمة الـ API
      final success = await ERPNextService().createPrescription(newPrescription);

      // 3. معالجة النتيجة
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال الوصفة بنجاح إلى ERPNext!')),
          );
          // يمكن هنا مسح الحقول أو العودة للصفحة السابقة
          _clearForm();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل الإرسال. تحقق من بيانات API.')),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _patientController.clear();
    _doctorController.clear();
    _notesController.clear();
    setState(() {
      _medicines.clear();
      _medicines.add(
        PrescriptionMedicine(
          medicineName: '',
          dosage: '',
          frequency: 'Once Daily',
          duration: '',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة وصفة طبية جديدة'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // حقول الوثيقة الرئيسية (الأب)
            _buildTextField(_patientController, 'اسم المريض', true),
            _buildTextField(_doctorController, 'اسم الطبيب', true),
            _buildTextField(_notesController, 'ملاحظات', false),
            const Divider(height: 30),

            // جدول الأدوية (الابن)
            const Text(
              'قائمة الأدوية (Medicines)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._buildMedicineList(), // عرض قائمة الحقول الديناميكية

            // زر إضافة صف دواء جديد
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _medicines.add(PrescriptionMedicine(
                      medicineName: '',
                      dosage: '',
                      frequency: 'Once Daily',
                      duration: ''));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة دواء جديد'),
            ),
            const SizedBox(height: 20),

            // زر الإرسال
            ElevatedButton(
              onPressed: _submitPrescription,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'إرسال الوصفة إلى ERPNext',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء حقول الإدخال النصية
  Widget _buildTextField(TextEditingController controller, String label, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'حقل $label مطلوب';
          }
          return null;
        },
      ),
    );
  }

  // دالة بناء حقول قائمة الأدوية الديناميكية
  List<Widget> _buildMedicineList() {
    List<Widget> medicineFields = [];

    for (int i = 0; i < _medicines.length; i++) {
      medicineFields.add(
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // زر الحذف
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _medicines.removeAt(i);
                      });
                    },
                  ),
                ),

                // 1. اسم الدواء
                TextFormField(
                  initialValue: _medicines[i].medicineName,
                  decoration: const InputDecoration(labelText: 'اسم الدواء *', border: OutlineInputBorder()),
                  onChanged: (value) => _medicines[i] = _medicines[i].copyWith(medicineName: value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'اسم الدواء مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // 2. الجرعة
                TextFormField(
                  initialValue: _medicines[i].dosage,
                  decoration: const InputDecoration(labelText: 'الجرعة (Dosage)'),
                  onChanged: (value) => _medicines[i] = _medicines[i].copyWith(dosage: value),
                ),
                const SizedBox(height: 10),

                // 3. التكرار (Select Field)
                DropdownButtonFormField<String>(
                  value: _medicines[i].frequency,
                  decoration: const InputDecoration(labelText: 'التكرار (Frequency)', border: OutlineInputBorder()),
                  items: <String>['Once Daily', 'Twice Daily', '3 Times Daily', 'As Needed']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _medicines[i] = _medicines[i].copyWith(frequency: newValue);
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 4. المدة
                TextFormField(
                  initialValue: _medicines[i].duration,
                  decoration: const InputDecoration(labelText: 'المدة (Duration)'),
                  onChanged: (value) => _medicines[i] = _medicines[i].copyWith(duration: value),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return medicineFields;
  }
}

// دالة مساعده لتحديث الكائن (نحتاج لإضافتها في ملف prescription_medicine.dart)
// بسبب عدم قدرتي على تعديل ملف سابق، يرجى إضافة هذه الدالة إلى PrescriptionMedicine
extension on PrescriptionMedicine {
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
