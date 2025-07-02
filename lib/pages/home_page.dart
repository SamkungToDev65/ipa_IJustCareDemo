import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bmi_cal_page.dart'; // ต้องมี import หน้า BMI Calculator
import 'map_page.dart'; // ต้องมี import หน้า Map Page userRole == 'owner' || userRole == 'admin'
import 'history_health_page.dart'; // ต้องมี import หน้า History Health Page userRole == 'user'

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userRole = ''; // เพิ่มตัวแปรเก็บ userRole
  String? userId; // เพิ่มตัวแปรเก็บ userId
  
  final List<Map<String, dynamic>> _healthTips = [
    {
      'title': 'ดื่มน้ำให้เพียงพอ',
      'subtitle': 'วันละ 8-10 แก้ว',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'gradient': [Colors.blue.shade300, Colors.blue.shade600],
    },
    {
      'title': 'ออกกำลังกาย',
      'subtitle': 'วันละ 30 นาที',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'gradient': [Colors.orange.shade300, Colors.orange.shade600],
    },
    {
      'title': 'นอนหลับพักผ่อน',
      'subtitle': 'วันละ 7-9 ชั่วโมง',
      'icon': Icons.bedtime,
      'color': Colors.purple,
      'gradient': [Colors.purple.shade300, Colors.purple.shade600],
    },
    {
      'title': 'ทานผักผลไม้',
      'subtitle': 'วันละ 5 ส่วน',
      'icon': Icons.eco,
      'color': Colors.green,
      'gradient': [Colors.green.shade300, Colors.green.shade600],
    },
    // เพิ่มเคล็ดลับใหม่
    {
      'title': 'ยิ้มและหัวเราะ',
      'subtitle': 'ลดความเครียดในแต่ละวัน',
      'icon': Icons.emoji_emotions,
      'color': Colors.yellow,
      'gradient': [Colors.yellow.shade600, Colors.orange.shade400],
    },
    {
      'title': 'ล้างมือบ่อยๆ',
      'subtitle': 'ป้องกันเชื้อโรคเข้าสู่ร่างกาย',
      'icon': Icons.clean_hands,
      'color': Colors.teal,
      'gradient': [Colors.teal.shade300, Colors.teal.shade700],
    },
  ];

  // ฟังก์ชันสำหรับโหลด userRole และ userId
  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? '';
      userId = prefs.getString('userId'); // โหลด userId ด้วย
    });
  }

  // ฟังก์ชันสำหรับจัดการการนำทางตาม role
  void _handleHealthRecordNavigation(BuildContext context) {
    if (userRole == 'owner' || userRole == 'admin') {
      // หากเป็น admin หรือ owner ไปหน้า Map Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MapPage(),
        ),
      );
    } else {
      // หากไม่ใช่ ไปหน้า History Health Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserHistoryPage(userId: userId!),
        ),
      );
    }
  }

  // แก้ไข _quickActions เพื่อใช้ฟังก์ชันใหม่
  List<Map<String, dynamic>> get _quickActions => [
    {
      'title': 'บันทึกสุขภาพ',
      'icon': '📝',
      'desc': userRole == 'owner' || userRole == 'admin' 
          ? 'ดูข้อมูลสุขภาพผู้ป่วย' 
          : 'จดบันทึกอาการหรือกิจกรรมสุขภาพ',
      'onTap': (BuildContext context) {
        _handleHealthRecordNavigation(context);
      },
    },
    {
      'title': 'ตรวจสอบ BMI',
      'icon': '⚖️',
      'desc': 'คำนวณดัชนีมวลกายของคุณ',
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BMICalculatorPage()),
        );
      },
    },
    {'title': 'ค้นหาโรงพยาบาล', 'icon': '🏥', 'desc': 'ดูโรงพยาบาลใกล้เคียง'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole(); // เรียกฟังก์ชันโหลด userRole เมื่อเริ่มต้น
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1C109E),
        statusBarIconBrightness: Brightness.light, // ไอคอนและตัวหนังสือสีขาว
        statusBarBrightness: Brightness.dark, // สำหรับ iOS
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return GestureDetector(
      onTap: () {
        // เพิ่มฟังก์ชันโทรหาเบอร์ฉุกเฉิน
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เปิดแอปโทรศัพท์เพื่อโทรหา 1669'),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text('🚨', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เหตุฉุกเฉิน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'กดเพื่อติดต่อหน่วยกู้ชีพ 24 ชม.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '📞 1669',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เมนูด่วน',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              _quickActions.map((action) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // เช็คว่ามี onTap function หรือไม่
                      if (action['onTap'] != null) {
                        action['onTap'](context);
                      } else {
                        // แสดงข้อความสำหรับเมนูที่ยังไม่ได้ทำ
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${action['title']} - กำลังพัฒนา'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            action['icon']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            action['title']!,  
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            action['desc']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.yellow, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '"สุขภาพดีไม่มีขาย อยากได้ต้องสร้างเอง"\nเริ่มต้นดูแลตัวเองวันนี้ เพื่ออนาคตที่สดใส!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'หน้าแรก',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),

      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Motivation Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMotivationCard(),
              ),

              // Health Tips Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เคล็ดลับสุขภาพประจำวัน',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _healthTips.length,
                        itemBuilder: (context, index) {
                          final tip = _healthTips[index];
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: tip['gradient'],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (tip['color'] ?? Colors.transparent)
                                      .withAlpha((0.3 * 255).toInt()),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      tip['icon'],
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    tip['title'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tip['subtitle'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(),
              ),

              const SizedBox(height: 25),

              // Emergency Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildEmergencyCard(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}