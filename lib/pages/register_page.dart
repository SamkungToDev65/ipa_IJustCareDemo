import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDate;
  bool _acceptedTerms = false; // ✅ ตัวแปรเช็กการยอมรับเงื่อนไข

  void _submitForm() async {
    if (!_acceptedTerms) {
      Fluttertoast.showToast(
        msg: "! กรุณายอมรับเงื่อนไขการใช้งานก่อน",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange[600],
        textColor: Colors.white,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final password = _passwordController.text;
      final phone = _phoneController.text;
      final birthDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      final url = Uri.parse('http://10.0.2.2/bcnlp_crud/api/register.php');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": name,
            "password": password,
            "phone": phone,
            "birth_date": birthDate,
          }),
        );

        final result = jsonDecode(response.body);
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "✅ ${result["message"]}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.white,
            textColor: Colors.green[600],
            fontSize: 16.0,
          );
          Navigator.pop(context); // กลับไปหน้า login
        } else {
          Fluttertoast.showToast(
            msg: "❌ ${result["message"]}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
        );
      }
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('th', 'TH'), // ตั้งเป็นภาษาไทย
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('สมัครสมาชิก', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('ชื่อ - นามสกุล', Icons.person),
                validator: (value) =>
                    value == null || value.isEmpty ? 'กรุณากรอกชื่อ' : null,
              ),
              SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('เบอร์โทรศัพท์', Icons.phone),
                validator: (value) => value == null || value.length < 9
                    ? 'กรุณากรอกเบอร์ให้ถูกต้อง'
                    : null,
              ),
              SizedBox(height: 16),

              // Birth Date
              InkWell(
                onTap: _showDatePicker,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: _inputDecoration('วันเกิด', Icons.cake),
                  child: Text(
                    _selectedDate == null
                        ? 'เลือกวันเดือนปีเกิด'
                        : DateFormat('dd MMM yyyy', 'th')
                            .format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null
                          ? Colors.grey[500]
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                    _inputDecoration('รหัสผ่าน (อย่างน้อย 6 ตัว)', Icons.lock),
                validator: (value) => value == null || value.length < 6
                    ? 'รหัสผ่านควรมีอย่างน้อย 6 ตัว'
                    : null,
              ),
              SizedBox(height: 16),

              // ✅ Checkbox for accepting terms
              CheckboxListTile(
                value: _acceptedTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'ฉันยอมรับเงื่อนไขการใช้งานและนโยบายความเป็นส่วนตัว',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(Icons.check_circle_outline),
                  label: Text("สมัครสมาชิก", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 77, 80, 255),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
