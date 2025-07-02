import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';

import 'add_health_users_modal.dart';
import 'sort_usermap_modal.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<dynamic> patients = [];
  bool isLoading = false;
  String? _highlightedPatientId;
  String? _highlightedPatientName; // เพิ่มตัวแปรนี้

  @override
  void initState() {
    super.initState();
    fetchPatients();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1C109E),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> fetchPatients() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('http://10.0.2.2/bcnlp_crud/api/get_users_health.php');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            patients = data;
          });
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<List<dynamic>> fetchHealthRecords(String userId) async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2/bcnlp_crud/api/get_health_records_limit1.php?user_id=$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        }
      }
    } catch (e) {
      print('Error fetching health records: $e');
    }
    return [];
  }

  // ฟังก์ชันแปลผลค่าน้ำตาล
  Map<String, dynamic> interpretBloodSugar(double value) {
    if (value == 0) return {'text': '-', 'color': Colors.grey, 'icon': Icons.help_outline};
    
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

  // ฟังก์ชันแปลผลความดันโลหิต
  Map<String, dynamic> interpretBloodPressure(double sbp, double dbp) {
  if (sbp == 0) {
    return {
      'text': '-',
      'color': Colors.grey[200],
      'textColor': Colors.black,
      'icon': Icons.help_outline,
    };
  }
  if (sbp >= 180) {
    return {
      'text': 'ความดันสูงอันตราย',
      'color': Colors.red[200],
      'textColor': Colors.red[900],
      'icon': Icons.sentiment_very_dissatisfied,
    };
  } else if (sbp >= 160 && sbp <= 179) {
    return {
      'text': 'ความดันสูงระดับ 2',
      'color': Colors.orange[200],
      'textColor': Colors.orange[900],
      'icon': Icons.sentiment_dissatisfied,
    };
  } else if (sbp >= 140 && sbp <= 159) {
    return {
      'text': 'ความดันสูงระดับ 1',
      'color': Colors.yellow[200],
      'textColor': Colors.orange[900],
      'icon': Icons.sentiment_neutral,
    };
  } else if (sbp < 120) {
    return {
      'text': 'ความดันต่ำกว่าเกณฑ์',
      'color': Colors.white,
      'textColor': Colors.black,
      'icon': Icons.sentiment_very_satisfied,
    };
  } else if (sbp >= 120 && sbp < 140) {
    return {
      'text': 'ความดันดี',
      'color': Colors.green[200],
      'textColor': Colors.green[900],
      'icon': Icons.sentiment_satisfied,
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

  Color getPatientDangerColor(Map<String, dynamic> patient) {
  final dtx = double.tryParse(patient['dtx']?.toString() ?? '') ?? 0;
  final sbp = double.tryParse(patient['sbp']?.toString() ?? '') ?? 0;
  final dbp = double.tryParse(patient['dbp']?.toString() ?? '') ?? 0;

  final sugar = interpretBloodSugar(dtx);
  final bp = interpretBloodPressure(sbp, dbp);

  int getDangerLevel(Color? color) {
    if (color == null) return 0;
    if (color == Colors.red[200]) return 4;
    if (color == Colors.orange[200]) return 3;
    if (color == Colors.yellow[200]) return 2;
    if (color == Colors.black || color == Colors.black26) return 5;
    if (color == Colors.green[200]) return 1;
    if (color == Colors.white) return 0;
    return 0;
  }

  int sugarLevel = getDangerLevel(sugar['color']);
  int bpLevel = getDangerLevel(bp['color']);
  int maxLevel = sugarLevel > bpLevel ? sugarLevel : bpLevel;

  if (maxLevel == 5) return Colors.black;
  if (maxLevel == 4) return Colors.red[800]!;
  if (maxLevel == 3) return Colors.orange[800]!;
  if (maxLevel == 2) return Colors.yellow[800]!;
  if (maxLevel == 1) return Colors.green[800]!;
  return Colors.white;
}

  @override
  Widget build(BuildContext context) {
    final Map<String, List<dynamic>> groupedPatients = {};
    for (var p in patients) {
      final lat = p['latitude'];
      final lng = p['longitude'];
      if (lat == null ||
          lng == null ||
          lat.toString().isEmpty ||
          lng.toString().isEmpty)
        continue;
      final key = '${lat.toString()},${lng.toString()}';
      groupedPatients.putIfAbsent(key, () => []).add(p);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "แผนที่ผู้ป่วย",
          style: TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF424242),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey.shade800),
            onPressed: () {
              fetchPatients();
              setState(() {
                _highlightedPatientId = null;      // ล้างค่ามุด
                _highlightedPatientName = null;    // ล้างชื่อที่เลือก
              });
            },
            tooltip: 'รีโหลดข้อมูล',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(18.2888, 99.4908),
                    initialZoom: 14.5,
                    minZoom: 14.5,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      tileProvider: NetworkTileProvider(),
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
  markers: groupedPatients.entries.expand((entry) {
    final patientsAtPoint = entry.value;
    final latLngParts = entry.key.split(',');
    final lat = double.tryParse(latLngParts[0]) ?? 0.0;
    final lng = double.tryParse(latLngParts[1]) ?? 0.0;
    final count = patientsAtPoint.length;

    // ตรวจสอบว่าจุดนี้มีผู้ป่วยที่ถูกเลือกหรือไม่
    final hasHighlighted = _highlightedPatientId != null &&
  _highlightedPatientId!.isNotEmpty &&
  patientsAtPoint.any((p) => p['id'].toString() == _highlightedPatientId);

    // Marker หลัก (กลุ่มคน)
    final marker = Marker(
      point: LatLng(lat, lng),
      width: 48 + count * 6.0,
      height: 48 + count * 6.0,
      child: GestureDetector(
        onTap: () => _showPatientsDialog(
          context,
          patientsAtPoint,
          count,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white70.withOpacity(0.75),
                Colors.white70.withOpacity(0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            runSpacing: 2,
            children: List.generate(
              count,
              (index) => Icon(
                Icons.person,
                color: getPatientDangerColor(patientsAtPoint[index]),
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );

    // ถ้ามีผู้ป่วยที่ถูกเลือก ให้เพิ่ม marker pin ซ้อน
    if (hasHighlighted) {
      return [
        marker,
        Marker(
          point: LatLng(lat, lng),
          width: 48 + count * 6.0,
          height: 64 + count * 6.0,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.location_pin,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
          ),
        ),
      ];
    } else {
      return [marker];
    }
  }).toList(),
),
                  ],
                ),
              ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.5, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: (_highlightedPatientName != null && _highlightedPatientName!.isNotEmpty)
                    ? Container(
                        key: ValueKey(_highlightedPatientName),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF1C109E), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, color: const Color(0xFF1C109E), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _highlightedPatientName!,
                              style: const TextStyle(
                                color: Color(0xFF1C109E),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Prompt',
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _highlightedPatientId = null;
                                  _highlightedPatientName = null;
                                });
                              },
                              child: const Icon(Icons.close, size: 18, color: Color(0xFF1C109E)),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              FloatingActionButton(
                heroTag: 'sort',
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1C109E),
                child: const Icon(Icons.search),
                tooltip: 'ค้นหาผู้ป่วย',
                onPressed: () async {
                  final selectedPatient = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => SortUserMapModal(patients: patients),
                  );
                  setState(() {
                    _highlightedPatientId = selectedPatient != null
                        ? selectedPatient['id'].toString()
                        : null;
                    _highlightedPatientName = selectedPatient != null
                        ? (selectedPatient['name'] ?? '')
                        : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: const AddHealthUserModal(),
                ),
              );
              if (result == true) {
                fetchPatients();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("เพิ่มข้อมูลผู้ป่วย"),
            backgroundColor: const Color(0xFF1C109E),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        ],
      ),
    );
  }

  void _showPatientsDialog(
    BuildContext context,
    List<dynamic> patientsAtPoint,
    int count,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C109E),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                    child: Text(
                      'ผู้ป่วยในตำแหน่งนี้ ($count คน)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'Prompt',
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            patientsAtPoint.asMap().entries.map((entry) {
                              final patient = entry.value;
                              final name = patient['name'] ?? 'ไม่ระบุชื่อ';

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.blue.shade100,
                                            child: const Icon(
                                              Icons.person,
                                              color: Color(0xFF1C109E),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1C109E),
                                                fontFamily: 'Prompt',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1, thickness: 1),
                                      const SizedBox(height: 12),
                                      _buildBasicInfo(patient),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C109E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "ปิด",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Prompt',
                            fontSize: 16,
                          ),
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

  String formatThaiDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final thaiMonths = [
        '',
        'ม.ค.',
        'ก.พ.',
        'มี.ค.',
        'เม.ย.',
        'พ.ค.',
        'มิ.ย.',
        'ก.ค.',
        'ส.ค.',
        'ก.ย.',
        'ต.ค.',
        'พ.ย.',
        'ธ.ค.',
      ];
      return "${date.day} ${thaiMonths[date.month]} ${date.year + 543}";
    } catch (_) {
      return "-";
    }
  }

  Widget _buildBasicInfo(Map<String, dynamic> patient) {
    return FutureBuilder<List<dynamic>>(
      future: fetchHealthRecords(patient['id'].toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Text('เกิดข้อผิดพลาดในการโหลดข้อมูลสุขภาพ');
        }
        final records = snapshot.data ?? [];
        final latest = records.isNotEmpty ? records.first : {};

        String getField(String key) {
          return (latest[key]?.toString().isNotEmpty ?? false)
              ? latest[key].toString()
              : (patient[key]?.toString().isNotEmpty ?? false)
              ? patient[key].toString()
              : '-';
        }

        // เพิ่มส่วนนี้สำหรับวันที่นัดหมาย
        String appointText = "-";
        String daysLeftText = "";
        Color? appointColor;
        if (latest['appoint'] != null && latest['appoint'].toString().isNotEmpty) {
          try {
            final appointDate = DateTime.parse(latest['appoint']);
            appointText = formatThaiDate(latest['appoint']);
            final now = DateTime.now();
            final diff = appointDate.difference(DateTime(now.year, now.month, now.day)).inDays;
            if (diff > 0) {
              daysLeftText = " (เหลืออีก $diff วัน)";
              if (diff <= 3) {
                appointColor = Colors.red; // เหลือ 3 วันหรือน้อยกว่า
              }
            } else if (diff == 0) {
              daysLeftText = " (วันนี้)";
              appointColor = Colors.red;
            } else {
              daysLeftText = " (เลยนัด $diff วัน)";
              appointColor = Colors.red;
            }
          } catch (_) {
            appointText = "-";
          }
        }

        final weight = double.tryParse(getField('weight')) ?? 0;
        final heightCm = double.tryParse(getField('height')) ?? 0;
        final heightM = heightCm / 100;
        final bmi = (heightM > 0) ? (weight / (heightM * heightM)) : 0;

        String getBmiStatus(double bmi) {
          if (bmi == 0) return '-';
          if (bmi < 18.5) return 'ต่ำกว่ามาตรฐาน';
          if (bmi <= 22.9) return 'มาตรฐาน';
          return 'เกินมาตรฐาน';
        }

        // ค่าที่ใช้ในการแปลผล
        final dtxValue = double.tryParse(getField('dtx')) ?? 0;
        final sbpValue = double.tryParse(getField('sbp')) ?? 0;
        final dbpValue = double.tryParse(getField('dbp')) ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (latest['health_record_date'] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "อัปเดตล่าสุด: ${formatThaiDate(latest['health_record_date'])}",
                  style: const TextStyle(
                    color: Color(0xFF1C109E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            _infoRow(
              "น้ำหนัก",
              getField('weight') != '-' ? "${getField('weight')} กก." : "-",
            ),
            _infoRow(
              "ส่วนสูง",
              getField('height') != '-' ? "${getField('height')} ซม." : "-",
            ),
            _infoRow(
              "ค่า BMI",
              (weight > 0 && heightM > 0)
                  ? "${bmi.toStringAsFixed(2)} (${getBmiStatus(bmi.toDouble())})"
                  : "-",
            ),
            _infoRow("โรคประจำตัว", getField('disease')),
            _infoRow("ยาที่ใช้", getField('medicine')),
            _infoRow("ปัญหา", getField('problem')),
            _infoRow("คำแนะนำ", getField('guidance')),
            
            // ความดันโลหิตพร้อมการแปลผล
            _infoRowWithInterpretation(
              "ความดันโลหิต บน/ล่าง",
              sbpValue > 0 && dbpValue > 0 ? "${sbpValue.toInt()}/${dbpValue.toInt()} mmHg" : "-",
              sbpValue > 0 && dbpValue > 0 ? interpretBloodPressure(sbpValue, dbpValue) : null,
            ),
            
            // น้ำตาลในเลือดพร้อมการแปลผล
            _infoRowWithInterpretation(
              "น้ำตาลในเลือด",
              dtxValue > 0 ? "${dtxValue.toInt()} mg/dL" : "-",
              dtxValue > 0 ? interpretBloodSugar(dtxValue) : null,
            ),
            _infoRow("วันที่นัดหมาย", appointText + daysLeftText, valueColor: appointColor),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C109E),
              fontFamily: 'Prompt',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Prompt',
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWithInterpretation(String label, String value, Map<String, dynamic>? interpretation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$label: ",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C109E),
                  fontFamily: 'Prompt',
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (interpretation != null && interpretation['text'] != '-')
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: interpretation['color'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    interpretation['icon'],
                    size: 16,
                    color: interpretation['textColor'],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    interpretation['text'],
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: interpretation['textColor'],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}