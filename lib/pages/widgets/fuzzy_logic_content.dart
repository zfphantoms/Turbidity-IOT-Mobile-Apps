import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FuzzyLogicContent extends StatelessWidget {
  const FuzzyLogicContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 40.h),
        Text(
          "LOGIKA FUZZY UNTUK NTU",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 12.h),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(3),
          },
          children: [
            _buildTableHeader(["Variabel", "Kategori", "Rentang"]),
            _buildTableRow("ADC Value", "Jernih", "1800 - 2000"),
            _buildTableRow("ADC Value", "Keruh", "1400 - 1799"),
            _buildTableRow("ADC Value", "Sangat Keruh", "0 - 1399"),
            _buildTableRow("Voltase", "Jernih", "3.0 - 3.3 V"),
            _buildTableRow("Voltase", "Keruh", "2.3 - 2.9 V"),
            _buildTableRow("Voltase", "Sangat Keruh", "0 - 2.2 V"),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          "📘 Aturan Fuzzy (Sugeno Rules)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text("• IF ADC Tinggi AND Voltase Tinggi THEN NTU = Rendah"),
        Text("• IF ADC Sedang AND Voltase Sedang THEN NTU = Sedang"),
        Text("• IF ADC Rendah AND Voltase Rendah THEN NTU = Tinggi"),
        SizedBox(height: 16.h),
        Text(
          "📐 Rumus Defuzzifikasi Sugeno",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
            "NTU = (w1*z1 + w2*z2 + w3*z3) / (w1 + w2 + w3)\n"
            "w = derajat keanggotaan minimum dari setiap rule\n"
            "z = nilai crisp output untuk setiap rule"),
      ],
    );
  }

  TableRow _buildTableHeader(List<String> headers) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.lightBlue.shade100),
      children: headers
          .map((h) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)),
              ))
          .toList(),
    );
  }

  TableRow _buildTableRow(String varName, String category, String range) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(varName),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(category),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(range),
      ),
    ]);
  }
}
