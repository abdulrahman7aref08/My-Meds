import 'dart:convert';
import 'package:http/http.dart' as http;

class ERPClient {
  static const String baseURL = "https://your-erp-site.com"; // غيّره
  static const String apiResource = "/api/resource";

  static String apiKey = "d139e725d5c7a34";      // API Key
  static String apiSecret = "42ab0bd0873a1ab";   // API Secret

  static Map<String, String> get headers => {
    "Authorization": "token $apiKey:$apiSecret",
    "Content-Type": "application/json"
  };

  // GET
  static Future<http.Response> get(String doctype) async {
    final url = Uri.parse("$baseURL$apiResource/$doctype");
    return await http.get(url, headers: headers);
  }

  // POST
  static Future<http.Response> create(String doctype, Map data) async {
    final url = Uri.parse("$baseURL$apiResource/$doctype");
    return await http.post(url, headers: headers, body: jsonEncode(data));
  }

  // UPDATE
  static Future<http.Response> update(String doctype, String name, Map data) async {
    final url = Uri.parse("$baseURL$apiResource/$doctype/$name");
    return await http.put(url, headers: headers, body: jsonEncode(data));
  }

  // DELETE
  static Future<http.Response> delete(String doctype, String name) async {
    final url = Uri.parse("$baseURL$apiResource/$doctype/$name");
    return await http.delete(url, headers: headers);
  }
}