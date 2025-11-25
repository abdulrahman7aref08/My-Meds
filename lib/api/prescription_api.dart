import 'dart:convert';
import 'erp_client.dart';

class PrescriptionAPI {

  static Future<List> getAll() async {
    final res = await ERPClient.get("Prescription");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"];
    }

    return [];
  }

  static Future<bool> createPrescription(Map data) async {
    final res = await ERPClient.create("Prescription", data);
    return res.statusCode == 200;
  }

  static Future<bool> updatePrescription(String name, Map data) async {
    final res = await ERPClient.update("Prescription", name, data);
    return res.statusCode == 200;
  }

  static Future<bool> deletePrescription(String name) async {
    final res = await ERPClient.delete("Prescription", name);
    return res.statusCode == 200;
  }
}