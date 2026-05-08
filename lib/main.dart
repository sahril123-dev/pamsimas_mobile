import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PAMSIMAS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f172a),
        primaryColor: const Color(0xFF0ea5e9),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFF0ea5e9),
          secondary: const Color(0xFF22d3ee),
          surface: const Color(0xFF1e293b),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
