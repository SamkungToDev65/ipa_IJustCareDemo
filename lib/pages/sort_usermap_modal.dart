import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SortUserMapModal extends StatelessWidget {
  final List<dynamic> patients;
  const SortUserMapModal({Key? key, required this.patients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ค้นหาผู้ป่วย",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Prompt',
                color: Color(0xFF1C109E),
              ),
            ),
            const SizedBox(height: 24),
            DropdownSearch<dynamic>(
              items: patients,
              itemAsString: (p) => p['name'] ?? 'ไม่ระบุชื่อ',
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "ค้นหาชื่อผู้ป่วย...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                fit: FlexFit.loose,
                constraints: BoxConstraints(maxHeight: 300),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "เลือกผู้ป่วย",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              onChanged: (selected) {
                Navigator.pop(context, selected);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C109E),
                  foregroundColor: const Color (0xFFFFFFFF),
                  side: const BorderSide(color: Color(0xFF1C109E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context, null),
                child: const Text("ปิด"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}