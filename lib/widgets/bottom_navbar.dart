import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/confirm_logout.dart'; // ต้องมี showConfirmLogoutDialog(context, onConfirm)

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String userRole = '';
  int? logoutIndex;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? '';
    });
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    List<SalomonBottomBarItem> items = [
      SalomonBottomBarItem(
        icon: const Icon(Icons.home_outlined),
        title: const Text("หน้าแรก",
            style: TextStyle(
              fontFamily: 'Prompt',
              fontWeight: FontWeight.w600,
              fontSize: 13,
            )),
        selectedColor: const Color.fromARGB(255, 77, 80, 255),
      ),
    ];

    if (userRole == 'owner' || userRole == 'admin') {
      items.add(
        SalomonBottomBarItem(
          icon: const Icon(Icons.map_outlined),
          title: const Text("แผนที่",
              style: TextStyle(
                fontFamily: 'Prompt',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              )),
          selectedColor: const Color.fromARGB(255, 77, 80, 255),
        ),
      );
    }

    if (userRole == 'owner') {
      logoutIndex = items.length; // เก็บ index สำหรับ logout
      items.add(
        SalomonBottomBarItem(
          icon: const Icon(Icons.logout),
          title: const Text("ออกจากระบบ",
              style: TextStyle(
                fontFamily: 'Prompt',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              )),
          selectedColor: Colors.redAccent,
        ),
      );
    }

    if (userRole == 'user' || userRole == 'admin') {
      items.add(
        SalomonBottomBarItem(
          icon: const Icon(Icons.person_outline),
          title: const Text("โปรไฟล์",
              style: TextStyle(
                fontFamily: 'Prompt',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              )),
          selectedColor: const Color.fromARGB(255, 77, 80, 255),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SalomonBottomBar(
        currentIndex: widget.currentIndex,
        onTap: (index) {
          if (logoutIndex != null && index == logoutIndex) {
            showConfirmLogoutDialog(context, () => _logout(context));
          } else {
            widget.onTap(index);
          }
        },
        selectedItemColor: const Color.fromARGB(255, 77, 80, 255),
        unselectedItemColor: Colors.grey[500],
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        items: items,
      ),
    );
  }
}
