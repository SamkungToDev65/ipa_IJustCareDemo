import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:flutter/services.dart'; // เพิ่มบรรทัดนี้
import 'package:dropdown_search/dropdown_search.dart';

class AddHealthUserModal extends StatefulWidget {
  const AddHealthUserModal({Key? key}) : super(key: key);

  @override
  State<AddHealthUserModal> createState() => _AddHealthUserModalState();
}

class _AddHealthUserModalState extends State<AddHealthUserModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController diseaseController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController sbpController = TextEditingController();
  final TextEditingController dbpController = TextEditingController();
  final TextEditingController dtxController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController guidanceController = TextEditingController();
  final TextEditingController appointmentDateController = TextEditingController();

  // Dropdown state
  List<dynamic> users = [];
  String? selectedUserId;

  // Checkbox state
  bool isConfirmed = false;

  // Date variable
  DateTime? appointmentDateRaw;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse('http://10.0.2.2/bcnlp_crud/api/show_users.php');
    final response = await http.get(url);
    if (response.statusCode == 200) { 
      final data = jsonDecode(response.body);
      setState(() {
        users = data;
      });
    }
  }

  Future<void> _saveUserData() async {
    final url = Uri.parse('http://10.0.2.2/bcnlp_crud/api/add_health_user.php');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': selectedUserId,
        'disease': diseaseController.text,
        'medicine': medicineController.text,
        'weight': weightController.text,
        'height': heightController.text,
        'sbp': sbpController.text,
        'dbp': dbpController.text,
        'dtx': dtxController.text,
        'problem': problemController.text,
        'guidance': guidanceController.text,
        'appointment_date': appointmentDateRaw != null
            ? DateFormat('yyyy-MM-dd').format(appointmentDateRaw!)
            : '',
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "บันทึกข้อมูลสำเร็จ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[600],
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: "เกิดข้อผิดพลาดในการบันทึกข้อมูล",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.2), // Semi-transparent backdrop
      child: Center(
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'Prompt',
                ),
          ),
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "เพิ่มข้อมูลผู้ป่วย",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// 🔽 Dropdown เลือกชื่อผู้ป่วย
                    DropdownSearch<Map<String, dynamic>>(
                      items: users.cast<Map<String, dynamic>>(),
                      itemAsString: (user) => user['name'],
                      selectedItem: users.firstWhere(
                        (user) => user['id'].toString() == selectedUserId,
                        orElse: () => null,
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: _inputDecoration("ชื่อ-สกุล", isRequired: true),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'ค้นหาชื่อผู้ป่วย',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Prompt'),
                        ),
                        itemBuilder: (context, user, isSelected) => ListTile(
                          title: Text(user['name'], style: const TextStyle(fontFamily: 'Prompt')),
                        ),
                      ),
                      onChanged: (user) {
                        setState(() {
                          selectedUserId = user?['id']?.toString();
                        });
                      },
                      validator: (user) =>
                          user == null ? 'กรุณาเลือกชื่อผู้ป่วย' : null,
                      dropdownBuilder: (context, user) => Text(
                        user?['name'] ?? '',
                        style: const TextStyle(fontFamily: 'Prompt'),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildTextField(diseaseController, "โรคประจำตัว", isRequired: false),
                    _buildTextField(medicineController, "ยา", isRequired: false),
                    _buildTextField(
                      weightController,
                      "น้ำหนัก (กก.)",
                      inputType: TextInputType.number,
                    ),
                    _buildTextField(
                      heightController,
                      "ส่วนสูง (ซม.)",
                      inputType: TextInputType.number,
                    ),
                    _buildTextField(
                      sbpController,
                      "ความดันตัวบน (SBP)",
                      inputType: TextInputType.number,
                    ),
                    _buildTextField(
                      dbpController,
                      "ความดันตัวล่าง (DBP)",
                      inputType: TextInputType.number,
                    ),
                    _buildTextField(
                      dtxController,
                      "ค่าน้ำตาลในเลือด (DTX)",
                      inputType: TextInputType.number,
                    ),
                    _buildTextField(problemController, "ปัญหาที่ผู้ป่วยพบ"),
                    _buildTextField(guidanceController, "คำแนะนำในการดูแล"),

                    // เพิ่มช่องวันที่นัดหมาย
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: appointmentDateController,
                        readOnly: true,
                        decoration: _inputDecoration("วันที่นัดหมาย (ถ้ามี)", isRequired: false),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            locale: const Locale('th', 'TH'),
                          );
                          if (picked != null) {
                            // แปลงเป็นวันที่ไทยสำหรับแสดง
                            final thaiDate = DateFormat('d MMMM yyyy', 'th').format(picked);
                            appointmentDateController.text = thaiDate;
                            // เก็บวันที่จริงสำหรับบันทึก
                            appointmentDateRaw = picked;
                          }
                        },
                        style: const TextStyle(fontFamily: 'Prompt'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmation Checkbox
                      Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                          onTap: () {
                            setState(() {
                            isConfirmed = !isConfirmed;
                            });
                          },
                          child: Text(
                            "โปรดยืนยันว่าคุณได้ตรวจสอบข้อมูลถูกต้องแล้ว และข้อมูลนี้จะไม่สามารถแก้ไขได้หลังบันทึก",
                            style: TextStyle(
                            fontSize: 15,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.w500,
                            ),
                          ),
                          ),
                        ),
                        Checkbox(
                          value: isConfirmed,
                          onChanged: (value) {
                          setState(() {
                            isConfirmed = value ?? false;
                          });
                          },
                          activeColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        ],
                      ),
                      ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isConfirmed && _formKey.currentState?.validate() == true
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  _saveUserData(); // 👈 เรียกบันทึกข้อมูล
                                }
                              }
                            : null, // ปิดการใช้งานปุ่มถ้ายังไม่ได้ติ๊ก checkbox
                        icon: const Icon(Icons.save),
                        label: Text(
                          "บันทึกข้อมูล",
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isConfirmed 
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.grey[400],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConfirmed ? Colors.indigo : Colors.grey[300],
                          foregroundColor: isConfirmed ? Colors.white : Colors.grey[400],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    bool isRequired = true,
  }) {
    // เพิ่ม inputFormatters สำหรับช่องตัวเลข
    List<TextInputFormatter>? inputFormatters;
    if (inputType == TextInputType.number) {
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters, // เพิ่มตรงนี้
        decoration: _inputDecoration(label, isRequired: isRequired),
        validator: isRequired
            ? (value) =>
                value == null || value.isEmpty ? 'กรุณากรอก $label' : null
            : null,
      ),
    );
  }

  // ปรับให้รับ isRequired
  InputDecoration _inputDecoration(String label, {bool isRequired = false}) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontFamily: 'Prompt', // เพิ่มตรงนี้
          ),
          children: isRequired
              ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'Prompt', // เพิ่มตรงนี้
                  ),
                )
              ]
              : [],
        ),
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}