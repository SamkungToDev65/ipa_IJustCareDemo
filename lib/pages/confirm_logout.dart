import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> showConfirmLogoutDialog(
  BuildContext context,
  VoidCallback onConfirmLogout,
) async {
  // ฟังก์ชันสำหรับล้างข้อมูล local และไปหน้าล็อกอิน
  Future<void> onConfirmLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ลบข้อมูลผู้ใช้ที่เก็บไว้ในเครื่อง
    
    Fluttertoast.showToast(
      msg: "ออกจากระบบเรียบร้อยแล้ว",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
    
    // ไปหน้าล็อกอิน พร้อมลบหน้าเก่าทิ้ง
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Logout",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeScaleTransition(
        animation: animation,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "ออกจากระบบ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text("คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?"),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirmLogout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("ออกจากระบบ"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
