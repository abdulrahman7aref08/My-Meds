// lib/services/erpnext_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prescription.dart'; // مسار نسبي
import '../models/prescription_medicine.dart'; // مسار نسبي

class ERPNextService {
  // ********* تأكد من تحديث هذه القيم *********
  static const String baseURL = "https://your-site-name.erpnext.com";
  static const String apiResource = "/api/resource/Prescription";
  static const String apiKey = "d139e725d5c7a34"; // استبدل هذا
  static const String apiSecret = "*********"; // استبدل هذا
  // **********************************************

  // دالة لإنشاء وثيقة (DocType) جديدة
  Future<bool> createPrescription(Prescription prescription) async {
    final url = Uri.parse('$baseURL$apiResource');

    // تحويل كائن Prescription إلى JSON
    final Map<String, dynamic> body = prescription.toJson();

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "token $apiKey:$apiSecret",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // تم الإنشاء بنجاح (عادة ما يكون 200 أو 201)
        print('Prescription created successfully: ${response.body}');
        return true;
      } else {
        // فشل الإرسال
        print('Failed to create Prescription. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('An error occurred during API call: $e');
      return false;
    }
  }
}
