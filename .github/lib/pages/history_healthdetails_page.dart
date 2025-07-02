import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryHealthDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? healthRecord;

  const HistoryHealthDetailsPage({Key? key, this.healthRecord}) : super(key: key);

  @override
  State<HistoryHealthDetailsPage> createState() => _HistoryHealthDetailsPageState();
}

class _HistoryHealthDetailsPageState extends State<HistoryHealthDetailsPage> {
  Map<String, dynamic>? detailedHealthRecord;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.healthRecord != null) {
      fetchHealthRecordDetails();
    }
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  Future<void> fetchHealthRecordDetails() async {
    if (widget.healthRecord == null) return;

    setState(() => isLoading = true);
    try {
      final healthRecordId = widget.healthRecord!['health_record_id'];
      final url = Uri.parse(
        'http://10.0.2.2/bcnlp_crud/api/get_health_details.php?health_record_id=$healthRecordId',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          detailedHealthRecord = data;
        });
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการโหลดข้อมูล');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('ข้อผิดพลาด'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  String formatThaiDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final thaiMonths = [
        '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
        'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
      ];

      if (dateStr.length <= 10 || (date.hour == 0 && date.minute == 0 && date.second == 0)) {
        return "${date.day} ${thaiMonths[date.month]} ${date.year + 543}";
      }
      final timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      return "${date.day} ${thaiMonths[date.month]} ${date.year + 543} เวลา $timeStr น.";
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: (color ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color ?? Colors.blue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Prompt')),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Prompt')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C109E),
                fontFamily: 'Prompt',
              )),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }


  // ฟังก์ชันแปลผลค่าน้ำตาล
  Map<String, dynamic> interpretBloodSugar(double value) {
    if (value == 0) return {'text': '-', 'color': Colors.grey, 'icon': Icons.help_outline, 'textColor': Colors.black};
    if (value < 100) {
      return {
        'text': 'น้ำตาลต่ำกว่าเกณฑ์',
        'color': Colors.grey[200],
        'textColor': Colors.grey[500],
        'icon': Icons.sentiment_very_satisfied,
      };
    } else if (value >= 100 && value <= 125) {
      return {
        'text': 'น้ำตาลปกติ',
        'color': Colors.lightGreen[100],
        'textColor': Colors.green[800],
        'icon': Icons.sentiment_satisfied,
      };
    } else if (value >= 126 && value <= 154) {
      return {
        'text': 'น้ำตาลสูงเล็กน้อย',
        'color': Colors.yellow[200],
        'textColor': Colors.orange[800],
        'icon': Icons.sentiment_neutral,
      };
    } else if (value >= 155 && value <= 182) {
      return {
        'text': 'น้ำตาลสูงมาก',
        'color': Colors.orange[200],
        'textColor': Colors.orange[800],
        'icon': Icons.sentiment_dissatisfied,
      };
    } else if (value >= 182) {
      return {
        'text': 'น้ำตาลสูงอันตราย',
        'color': Colors.red[200],
        'textColor': Colors.red[800],
        'icon': Icons.sentiment_very_dissatisfied,
      };
    } else {
      return {
        'text': 'ผิดปกติ',
        'color': Colors.black26,
        'textColor': Colors.black,
        'icon': Icons.warning,
      };
    }
  }

  // ฟังก์ชันแปลผลความดันโลหิต (ใช้เฉพาะตัวบน SBP)
  Map<String, dynamic> interpretBloodPressure(double sbp, double dbp) {
    if (sbp == 0) {
      return {
        'text': '-',
        'color': Colors.grey[200],
        'textColor': Colors.black,
        'icon': Icons.help_outline,
      };
    }
    if (sbp < 120) {
      return {
        'text': 'ความดันต่ำกว่าเกณฑ์',
        'color': Colors.white,
        'textColor': Colors.black,
        'icon': Icons.sentiment_very_satisfied,
      };
    } else if (sbp >= 120 && sbp <= 139) {
      return {
        'text': 'ความดันดี',
        'color': Colors.green[200],
        'textColor': Colors.green[900],
        'icon': Icons.sentiment_satisfied,
      };
    } else if (sbp >= 140 && sbp <= 159) {
      return {
        'text': 'ความดันสูงระดับ 1',
        'color': Colors.yellow[200],
        'textColor': Colors.orange[900],
        'icon': Icons.sentiment_neutral,
      };
    } else if (sbp >= 160 && sbp <= 179) {
      return {
        'text': 'ความดันสูงระดับ 2',
        'color': Colors.orange[200],
        'textColor': Colors.orange[900],
        'icon': Icons.sentiment_dissatisfied,
      };
    } else if (sbp >= 180) {
      return {
        'text': 'ความดันสูงอันตราย',
        'color': Colors.red[200],
        'textColor': Colors.red[900],
        'icon': Icons.sentiment_very_dissatisfied,
      };
    } else {
      return {
        'text': 'ค่าผิดปกติ',
        'color': Colors.black,
        'textColor': Colors.white,
        'icon': Icons.warning,
      };
    }
  }

  double _calculateBMI(double weight, double height) {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'น้ำหนักต่ำกว่าเกณฑ์';
    if (bmi >= 18.5 && bmi < 25) return 'น้ำหนักปกติ';
    if (bmi >= 25 && bmi < 30) return 'น้ำหนักเกิน';
    if (bmi >= 30) return 'อ้วน';
    return 'ไม่สามารถประเมินได้';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi >= 18.5 && bmi < 25) return Colors.green;
    if (bmi >= 25 && bmi < 30) return Colors.orange;
    if (bmi >= 30) return Colors.red;
    return Colors.grey;
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontFamily: 'Prompt',
        ),
      ),
    );
  }

  String _getBloodSugarStatus(double value) {
    final result = interpretBloodSugar(value);
    return result['text']?.toString() ?? '-';
  }

  Color _getBloodSugarColor(double value) {
    final result = interpretBloodSugar(value);
    return result['textColor'] is Color ? result['textColor'] : Colors.black;
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Prompt')),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Prompt'))),
        ],
      ),
    );
  }

  Widget _buildBpInterpretChip(double sbp, double dbp) {
    final result = interpretBloodPressure(sbp, dbp);
    if (result['text'] == '-') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: (result['color'] as Color?)?.withOpacity(0.13) ?? Colors.grey.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(result['icon'], color: result['textColor'], size: 18),
          const SizedBox(width: 6),
          Text(
            result['text'],
            style: TextStyle(
              color: result['textColor'],
              fontWeight: FontWeight.bold,
              fontFamily: 'Prompt',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.healthRecord == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียดข้อมูลสุขภาพ'),
        ),
        body: const Center(
          child: Text('ไม่พบข้อมูลที่ต้องการแสดง'),
        ),
      );
    }

    final record = widget.healthRecord!;
    final dtxValue = double.tryParse(record['dtx']?.toString() ?? '0') ?? 0;
    final sbpValue = double.tryParse(record['sbp']?.toString() ?? '0') ?? 0;
    final dbpValue = double.tryParse(record['dbp']?.toString() ?? '0') ?? 0;
    final weightValue = double.tryParse(record['weight']?.toString() ?? '0') ?? 0;
    final heightValue = double.tryParse(record['height']?.toString() ?? '0') ?? 0;

    // Merge detailedHealthRecord if available
    final detail = detailedHealthRecord ?? {};
    final diseases = detail['disease']?.toString() ?? record['disease']?.toString() ?? '';
    final medicine = detail['medicine']?.toString() ?? record['medicine']?.toString() ?? '';
    final problem = detail['problem']?.toString() ?? record['problem']?.toString() ?? '';
    final guidance = detail['guidance']?.toString() ?? record['guidance']?.toString() ?? '';
    final notes = detail['notes']?.toString() ?? record['notes']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C109E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'รายละเอียดข้อมูลสุขภาพ',
          style: TextStyle(
            color: Color(0xFF1C109E),
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C109E), Color(0xFF3D2FCE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'บันทึกข้อมูลสุขภาพ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Prompt',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatThaiDateTime(record['health_record_date']),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontFamily: 'Prompt',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Section: Basic Info
                  _buildSectionCard(
                    title: "ข้อมูลพื้นฐาน",
                    children: [
                      if (weightValue > 0)
                        _buildInfoTile(
                          icon: Icons.monitor_weight,
                          label: "น้ำหนัก",
                          value: "$weightValue กิโลกรัม",
                          color: Colors.blue,
                        ),
                      if (heightValue > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _buildInfoTile(
                            icon: Icons.straighten,
                            label: "ส่วนสูง",
                            value: "$heightValue เซนติเมตร",
                            color: Colors.green,
                          ),
                        ),
                      if (weightValue > 0 && heightValue > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _buildInfoTile(
                            icon: Icons.calculate,
                            label: "BMI",
                            value: "${_calculateBMI(weightValue, heightValue).toStringAsFixed(1)} kg/m²",
                            color: _getBMIColor(_calculateBMI(weightValue, heightValue)),
                          ),
                        ),
                      if (weightValue > 0 && heightValue > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              _buildStatusChip(
                                _getBMIStatus(_calculateBMI(weightValue, heightValue)),
                                _getBMIColor(_calculateBMI(weightValue, heightValue)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Section: Blood Pressure
                  if (sbpValue > 0)
                    _buildSectionCard(
                      title: "ความดันโลหิต",
                      children: [
                        _buildInfoTile(
                          icon: Icons.favorite,
                          label: "ตัวบน (SBP)",
                          value: "${sbpValue.toInt()} mmHg",
                          color: Colors.red,
                        ),
                        if (dbpValue > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _buildInfoTile(
                              icon: Icons.favorite_border,
                              label: "ตัวล่าง (DBP)",
                              value: "${dbpValue.toInt()} mmHg",
                              color: Colors.red,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              _buildBpInterpretChip(sbpValue, dbpValue), // แสดงแค่ interpret แบบมีไอคอน
                            ],
                          ),
                        ),
                      ],
                    ),

                  // Section: Blood Sugar
                  if (dtxValue > 0)
                    _buildSectionCard(
                      title: "น้ำตาลในเลือด",
                      children: [
                        _buildInfoTile(
                          icon: Icons.water_drop,
                          label: "DTX",
                          value: "${dtxValue.toInt()} mg/dL",
                          color: Colors.orange,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              _buildStatusChip(
                                _getBloodSugarStatus(dtxValue),
                                _getBloodSugarColor(dtxValue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  // Section: Diseases & Medicine
                  if (diseases.isNotEmpty || medicine.isNotEmpty)
                    _buildSectionCard(
                      title: "โรคประจำตัว / ยาที่ใช้",
                      children: [
                        if (diseases.isNotEmpty)
                          _buildDetailRow(label: "โรคประจำตัว", value: diseases),
                        if (medicine.isNotEmpty)
                          _buildDetailRow(label: "ยา", value: medicine),
                      ],
                    ),

                  // Section: Problems & Guidance
                  if (problem.isNotEmpty || guidance.isNotEmpty)
                    _buildSectionCard(
                      title: "ปัญหาและคำแนะนำ",
                      children: [
                        if (problem.isNotEmpty)
                          _buildDetailRow(label: "ปัญหา", value: problem),
                        if (guidance.isNotEmpty)
                          _buildDetailRow(label: "คำแนะนำ", value: guidance),
                      ],
                    ),

                  // Section: Notes
                  if (notes.isNotEmpty)
                    _buildSectionCard(
                      title: "หมายเหตุ",
                      children: [
                        Text(
                          notes,
                          style: const TextStyle(fontSize: 14, color: Colors.black87, fontFamily: 'Prompt'),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
