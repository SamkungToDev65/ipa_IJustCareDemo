import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // หรือ import ให้ถูก path ตามโครงสร้างโปรเจกต์
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void showToast(
    String msg, {
    Color backgroundColor = const Color.fromARGB(255, 255, 193, 21),
  }) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: backgroundColor,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> loginUser() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      showToast("กรุณากรอกเบอร์โทรและรหัสผ่าน");
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://10.0.2.2/bcnlp_crud/api/login.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        showToast(
          data["message"] ?? "เข้าสู่ระบบสำเร็จ",
          backgroundColor: Colors.green,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPhone', phone);

        if (data["user"] != null) {
          await prefs.setString('userId', data["user"]["id"].toString());
          await prefs.setString('userName', data["user"]["name"]);
          await prefs.setString('userRole', data["user"]["role"]);

          // เรียกใช้ sendTokenToServer หลัง login สำเร็จ
          String? token = await FirebaseMessaging.instance.getToken();
          await sendTokenToServer(data["user"]["id"].toString(), token);
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        showToast(
          data["message"] ?? "เข้าสู่ระบบไม่สำเร็จ",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      showToast("เกิดข้อผิดพลาด: $e", backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 300, height: 100),
                const SizedBox(height: 16),
                const Text(
                  'BCNLP CRUD',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'กรุณาเข้าสู่ระบบบัญชีของคุณ',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: phoneController,
                  hintText: 'เบอร์โทร',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: passwordController,
                  hintText: 'รหัสผ่าน',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 77, 80, 255),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'เข้าสู่ระบบ',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ยังไม่มีบัญชีใช่ไหม?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('ลงทะเบียน'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
