import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  // TOKEN MANAGEMENT
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("${Config.baseUrl}/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['data'] != null && data['data']['access_token'] != null) {
        await saveToken(data['data']['access_token']);
      }

      return {"statusCode": response.statusCode, "body": data};
    } catch (e) {
      return {"statusCode": 500, "body": {"message": e.toString()}};
    }
  }

  // TAGIHAN CURRENT
  static Future<Map<String, dynamic>> getCurrentTagihan() async {
    final token = await getToken();
    final url = Uri.parse(
      "${Config.baseUrl}/tagihan/current",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);

      return {"statusCode": response.statusCode, "body": data};
    } catch (e) {
      return {"statusCode": 500, "body": {"message": e.toString()}};
    }
  }

  // TAGIHAN HISTORY
  static Future<Map<String, dynamic>> getHistoryTagihan() async {
    final token = await getToken();
    final url = Uri.parse(
      "${Config.baseUrl}/tagihan/history",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);

      return {"statusCode": response.statusCode, "body": data};
    } catch (e) {
      return {"statusCode": 500, "body": {"message": e.toString()}};
    }
  }

  // NOTIFIKASI - Get All
  static Future<Map<String, dynamic>> getNotifikasi() async {
    final token = await getToken();
    final url = Uri.parse("${Config.baseUrl}/notifikasi");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);
      return {"statusCode": response.statusCode, "body": data};
    } catch (e) {
      return {"statusCode": 500, "body": {"message": e.toString()}};
    }
  }

  // NOTIFIKASI - Get Unread Count
  static Future<Map<String, dynamic>> getUnreadNotifikasiCount() async {
    final token = await getToken();
    final url = Uri.parse("${Config.baseUrl}/notifikasi/unread-count");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);
      return {"statusCode": response.statusCode, "body": data};
    } catch (e) {
      return {"statusCode": 500, "body": {"message": e.toString()}};
    }
  }

  // NOTIFIKASI - Mark as Read
  static Future<Map<String, dynamic>> markNotifikasiRead(String id) async {
    final token = await getToken();
    final url = Uri.parse("${Config.baseUrl}/notifikasi/$id/read");

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);
      return {"statusCode": response.statusCode, "body": data};
    } catch (e) {
      return {"statusCode": 500, "body": {"message": e.toString()}};
    }
  }
}
