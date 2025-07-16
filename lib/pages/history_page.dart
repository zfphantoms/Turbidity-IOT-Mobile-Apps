import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/history_chart.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, dynamic>> _dataList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    final ref = FirebaseDatabase.instance.ref("turbidity_history");

    final snapshot = await ref.get();

    final List<Map<String, dynamic>> temp = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      // Urutkan berdasarkan timestamp push
      final sortedEntries = data.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

      for (var entry in sortedEntries) {
        final val = entry.value as Map;

        final ntu = (val['ntu'] ?? 0).toDouble();
        final ts = val['timestamp'] ?? '';

        temp.add({
          'label': ts.toString().split("at").last.trim(), // ambil waktu saja
          'value': ntu,
        });
      }
    }

    setState(() {
      _dataList.clear();
      _dataList.addAll(temp);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📊 Riwayat Kekeruhan",
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade400,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _dataList.isEmpty
                ? const Center(child: Text("Belum ada data riwayat"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Grafik NTU",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16.h),
                      Expanded(child: HistoryChart(data: _dataList)),
                    ],
                  ),
      ),
    );
  }
}
