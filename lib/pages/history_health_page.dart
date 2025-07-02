import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'history_healthdetails_page.dart';

class UserHistoryPage extends StatefulWidget {
  final String userId;
  
  const UserHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> 
    with SingleTickerProviderStateMixin {
  List<dynamic> healthRecords = [];
  bool isLoading = false;
  String? selectedPeriod = 'ทั้งหมด';
  late TabController _tabController;
  
  final List<String> periods = ['ทั้งหมด', '7 วันล่าสุด', '30 วันล่าสุด', '90 วันล่าสุด'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchHealthRecords();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 255, 255, 255),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchHealthRecords() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        'http://10.0.2.2/bcnlp_crud/api/get_health_records.php?user_id=${widget.userId}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            healthRecords = data;
          });
        }
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

  void _navigateToDetails(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryHealthDetailsPage(
          healthRecord: record,
        ),
      ),
    );
  }

  List<dynamic> getFilteredRecords() {
    if (selectedPeriod == 'ทั้งหมด') return healthRecords;
    
    final now = DateTime.now();
    int daysBack = 0;
    
    switch (selectedPeriod) {
      case '7 วันล่าสุด':
        daysBack = 7;
        break;
      case '30 วันล่าสุด':
        daysBack = 30;
        break;
      case '90 วันล่าสุด':
        daysBack = 90;
        break;
    }
    
    final cutoffDate = now.subtract(Duration(days: daysBack));
    
    return healthRecords.where((record) {
      try {
        final recordDate = DateTime.parse(record['health_record_date']);
        return recordDate.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  String formatThaiDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final thaiMonths = [
        '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
      ];
      return "${date.day} ${thaiMonths[date.month]} ${date.year + 543}";
    } catch (_) {
      return dateStr;
    }
  }

 String formatThaiDateTime(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    final thaiMonths = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    // ถ้าไม่มีเวลา (เช่น 00:00:00 และไม่มี T ใน string) ให้แสดงแค่วันที่
    if (dateStr.length <= 10 || (date.hour == 0 && date.minute == 0 && date.second == 0)) {
      return "${date.day} ${thaiMonths[date.month]} ${date.year + 543}";
    }
    final timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    return "${date.day} ${thaiMonths[date.month]} ${date.year + 543} เวลา $timeStr น.";
  } catch (_) {
    return dateStr;
  }
}

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Prompt',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Prompt',
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontFamily: 'Prompt',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final filteredRecords = getFilteredRecords();
    
    if (filteredRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ไม่มีประวัติการบันทึกข้อมูล',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'Prompt',
              ),
            ),
          ],
        ),
      );
    }

    final totalRecords = filteredRecords.length;
    final latestRecord = filteredRecords.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'จำนวนบันทึก',
                  '$totalRecords',
                  'ครั้ง',
                  Icons.assignment,
                  const Color(0xFF1C109E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'ล่าสุด',
                    formatThaiDate(latestRecord['health_record_date']),
                  'วันที่บันทึก',
                  Icons.schedule,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          const Text(
            'บันทึกล่าสุด',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C109E),
              fontFamily: 'Prompt',
            ),
          ),
          const SizedBox(height: 12),
          ...filteredRecords.take(3).map((record) => _buildRecordCard(record)),
        ],
      ),
    );
  }

  Widget _buildRecordsTab() {
    final filteredRecords = getFilteredRecords();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.filter_list, color: Color(0xFF1C109E)),
              const SizedBox(width: 8),
              const Text(
                'ช่วงเวลา: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Prompt',
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  isExpanded: true,
                  underline: Container(),
                  onChanged: (value) {
                    setState(() {
                      selectedPeriod = value;
                    });
                  },
                  items: periods.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(
                        period,
                        style: const TextStyle(fontFamily: 'Prompt'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'ไม่พบข้อมูลในช่วงเวลาที่เลือก',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Prompt',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    return _buildRecordCard(filteredRecords[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final dtxValue = double.tryParse(record['dtx']?.toString() ?? '0') ?? 0;
    final sbpValue = double.tryParse(record['sbp']?.toString() ?? '0') ?? 0;
    final dbpValue = double.tryParse(record['dbp']?.toString() ?? '0') ?? 0;
    final weight = record['weight']?.toString() ?? '-';
    final height = record['height']?.toString() ?? '-';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C109E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event, color: Color(0xFF1C109E), size: 18), // ย้ายไอคอนเข้าในกล่อง
                      const SizedBox(width: 6),
                      const Text(
                        'บันทึกเมื่อ ',
                        style: TextStyle(
                          color: Color(0xFF1C109E),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Prompt',
                        ),
                      ),
                      Text(
                        formatThaiDateTime(record['health_record_date']),
                        style: const TextStyle(
                          color: Color(0xFF1C109E),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Prompt',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ย้ายบล็อกวันที่นัดหมายมาตรงนี้
            if ((record['appoint']?.toString().isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, color: Colors.deepOrange, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'วันที่นัดหมาย: ',
                    style: const TextStyle(
                      fontFamily: 'Prompt',
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 13,
                          color: Color.fromARGB(255, 61, 61, 61),
                        ),
                        children: [
                          TextSpan(
                            text: formatThaiDateTime(record['appoint']),
                          ),
                          TextSpan(
                            text: ' (${interpretAppointmentStatus(record)})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: interpretAppointmentStatus(record) == 'เลยกำหนด'
                                  ? Colors.red
                                  : (interpretAppointmentStatus(record) == 'ครบกำหนด'
                                      ? Colors.green
                                      : Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'น้ำหนัก',
                    weight != '-' ? '$weight กก.' : '-',
                    Icons.monitor_weight,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'ส่วนสูง',
                    height != '-' ? '$height ซม.' : '-',
                    Icons.straighten,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sbpValue > 0 && dbpValue > 0) ...[
              _buildMetricItem(
                'ความดันโลหิต',
                '${sbpValue.toInt()}/${dbpValue.toInt()} mmHg',
                Icons.favorite,
                Colors.red,
              ),
              const SizedBox(height: 12),
            ],
            if (dtxValue > 0) ...[
              _buildMetricItem(
                'น้ำตาลในเลือด',
                '${dtxValue.toInt()} mg/dL',
                Icons.water_drop,
                Colors.orange,
              ),
              const SizedBox(height: 12),
            ],
            // เพิ่มปุ่มดูเพิ่มเติม
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToDetails(record),
                icon: const Icon(
                  Icons.visibility,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'ดูรายละเอียด',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C109E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  String interpretAppointmentStatus(Map<String, dynamic> record) {
  if (record['appoint'] == null || record['appoint'].toString().isEmpty) return '';
  try {
    final appointDate = DateTime.parse(record['appoint']);
    final now = DateTime.now();
    final diff = appointDate.difference(now).inDays;

    // หาประวัติใหม่หลังวันนัดหมาย
    final hasNewerRecord = healthRecords.any((r) {
      try {
        final recDate = DateTime.parse(r['health_record_date']);
        return recDate.isAfter(appointDate);
      } catch (_) {
        return false;
      }
    });

    if (diff > 0) {
      return 'เหลืออีก $diff วัน';
    } else if (diff == 0) {
      return 'วันนี้';
    } else {
      // เลยกำหนดแล้ว
      if (hasNewerRecord) {
        return 'ครบกำหนด';
      } else {
        return 'เลยกำหนด';
      }
    }
  } catch (_) {
    return '';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'ประวัติสุขภาพ',
          style: TextStyle(color: Color(0xFF1C109E), fontFamily: 'Prompt', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'ภาพรวม'),
            Tab(text: 'รายการ'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildRecordsTab(),
              ],
            ),
    );
  }
}