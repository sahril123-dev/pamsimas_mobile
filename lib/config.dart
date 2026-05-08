import 'package:flutter/foundation.dart';

class Config {
  // Ganti IP ini dengan IP PC Anda (cek cmd: ipconfig)
  static const String _pcIp = "10.178.200.87";

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api"; // Untuk Chrome / Web
    } else {
      // Gunakan IP PC agar bisa diakses dari HP Fisik & Emulator
      return "http://$_pcIp:8000/api";
    }
  }
}


