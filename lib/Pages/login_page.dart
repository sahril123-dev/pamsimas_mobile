import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    try {
      print('🔄 Attempting login...');
      print('Username: ${usernameController.text.trim()}');
      
      final result = await ApiService.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      print('📥 Response received');
      print('Status Code: ${result["statusCode"]}');
      print('Body: ${result["body"]}');

      setState(() => isLoading = false);

      final body = result["body"];

      if (result["statusCode"] == 200 && body["success"] == true) {
        final pelangganId = body["data"]["user"]["id"].toString();
        final namaPelanggan = body["data"]["user"]["nama"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("id_pelanggan", pelangganId);
        await prefs.setString("nama_pelanggan", namaPelanggan);

        print('✅ Login successful! ID: $pelangganId');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        final msg = body["message"] ?? "Login gagal";
        print('❌ Login failed: $msg');
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('💥 Error during login: $e');
      setState(() => isLoading = false);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Tidak dapat terhubung ke server. $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Orbs
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0f172a),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    secondaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: primaryColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "PAMSIMAS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "Botuwanggobu",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Inputs with Glassmorphism
                    _buildGlassInput(
                      controller: usernameController,
                      hint: "Username",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildGlassInput(
                      controller: passwordController,
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),

                    // Gradient Login Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Mulai Sekarang",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Hubungi admin untuk reset password"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.2),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
