import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'confirm_logout.dart';
import 'user_profile_page.dart';
import 'change_password_page.dart';
import 'history_health_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userPhone;
  String? userName;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhone = prefs.getString('userPhone') ?? 'ไม่พบข้อมูล';
      userName = prefs.getString('userName') ?? 'ไม่พบข้อมูล';
       userId = prefs.getString('userId'); // โหลด userId ด้วย
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("โปรไฟล์", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔷 ส่วนบน: โปรไฟล์
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage(
                      "assets/images/avatar.png",
                    ), // แก้เป็น path จริง
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName ?? "กำลังโหลด...",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "📞 $userPhone",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🧩 จัดการบัญชี
            _buildSectionTitle("จัดการบัญชี"),
            _buildCard([
              _buildMenuItem(Icons.person, "ข้อมูลส่วนตัว", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage(userId: userId!)),
                );
              }),
              _buildMenuItem(Icons.history, "ประวัติการทำรายการ", () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserHistoryPage(userId: userId!)),
                );
              }),
              _buildMenuItem(Icons.lock_outline, "เปลี่ยนรหัสผ่าน", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage(userId: userId!)),
                );
              }),
            ]),

            const SizedBox(height: 30),

            // ⚙️ ระบบ
            _buildSectionTitle("ระบบ"),
            _buildCard([
              _buildMenuItem(Icons.logout, "ออกจากระบบ", () {
                showConfirmLogoutDialog(context, () {
                  _logout(context);
                });
              }, textColor: Colors.red),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: textColor ?? Colors.black),
          title: Text(
            title,
            style: TextStyle(color: textColor ?? Colors.black),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ลบข้อมูลผู้ใช้
    Navigator.pushReplacementNamed(context, '/login');
  }
}
