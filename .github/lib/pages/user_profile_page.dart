import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  List<Map<String, dynamic>> _communities = [];
  String? selectedCommunityId;

  LatLng _markerPosition = LatLng(
    18.2888,
    99.4908,
  ); // พิกัดเริ่มต้น: ตัวเมืองลำปาง

  DateTime? birthDateRaw;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchCommunities();
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse(
      'http://10.0.2.2/bcnlp_crud/api/get_user.php?userId=${widget.userId}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        birthDateController.text = data['birth_date'] != null
            ? DateFormat('d MMMM yyyy', 'th_TH').format(DateTime.parse(data['birth_date']))
            : '';
        birthDateRaw = data['birth_date'] != null
            ? DateTime.parse(data['birth_date'])
            : null;
        selectedCommunityId = data['commu_id']?.toString();
        latitudeController.text = data['latitude'] ?? '';
        longitudeController.text = data['longitude'] ?? '';

        // กำหนดตำแหน่งหมุดจาก lat/lng ที่ดึงมาได้
        final lat = double.tryParse(latitudeController.text);
        final lng = double.tryParse(longitudeController.text);
        if (lat != null && lng != null) {
          _markerPosition = LatLng(lat, lng);
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ไม่สามารถโหลดข้อมูลผู้ใช้ได้")));
    }
  }

  Future<void> _fetchCommunities() async {
    final url = Uri.parse('http://10.0.2.2/bcnlp_crud/api/get_communities.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _communities =
            data.map((item) {
              return {
                'id': item['commu_id'].toString(),
                'name': item['commu_name'],
              };
            }).toList();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ไม่สามารถโหลดรายชื่อชุมชนได้")));
    }
  }

  Future<void> _saveUserData() async {
    final url = Uri.parse(
      'http://10.0.2.2/bcnlp_crud/api/update_user.php?userId=${widget.userId}',
    );
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'phone': phoneController.text,
        'birth_date': birthDateRaw != null
            ? DateFormat('yyyy-MM-dd').format(birthDateRaw!)
            : '',
        'community': selectedCommunityId,
        'latitude': latitudeController.text,
        'longitude': longitudeController.text,
      }),
    );

    if (response.statusCode == 200) {
      // แสดง Toast แยก
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
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "ข้อมูลส่วนตัว",
          style: TextStyle(color: Color(0xFF1C109E)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage("assets/images/avatar.png"),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "ข้อมูลส่วนตัว",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildInputField(Icons.person, "ชื่อ", nameController),
            _buildInputField(Icons.phone, "เบอร์โทร", phoneController),
            _buildInputField(Icons.cake, "วันเกิด", birthDateController),

            const SizedBox(height: 30),
            const Text(
              "ข้อมูลที่อยู่",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildDropdownCommunity(),

            const SizedBox(height: 12),

            // Map Section
            Container(
              height: 250,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    center: _markerPosition,
                    zoom: 13,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _markerPosition = point;
                        latitudeController.text = point.latitude
                            .toStringAsFixed(6);
                        longitudeController.text = point.longitude
                            .toStringAsFixed(6);
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _markerPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            _buildInputField(Icons.streetview, "ละติจูด", latitudeController),
            _buildInputField(Icons.streetview, "ลองจิจูด", longitudeController),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "บันทึกข้อมูล",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    final isBirthDate = label == "วันเกิด";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap:
                  isBirthDate
                      ? () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          locale: const Locale('th', 'TH'),
                        );
                        if (picked != null) {
                          final formatted = DateFormat('d MMMM yyyy', 'th_TH').format(picked);
                          setState(() {
                            controller.text = formatted;
                            birthDateRaw = picked;
                          });
                        }
                      }
                      : null,
              child: AbsorbPointer(
                absorbing: isBirthDate,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCommunity() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCommunityId,
        decoration: const InputDecoration(
          labelText: 'ชุมชน',
          border: InputBorder.none,
        ),
        items:
            _communities.map((commu) {
              return DropdownMenuItem<String>(
                value: commu['id'],
                child: Text(commu['name']),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCommunityId = value;
          });
        },
      ),
    );
  }
}
