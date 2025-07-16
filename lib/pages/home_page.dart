import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? turbidity;
  String? lastUpdated;
  String status = 'OFFLINE';

  final dbRef = FirebaseDatabase.instance.ref('device_status/kolam_01');

  @override
  void initState() {
    super.initState();
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          turbidity = double.tryParse(data['ntu'].toString()) ?? 0.0;
          lastUpdated = data['timestamp'] != null
              ? DateFormat('dd MMM yyyy HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(data['timestamp'].toString()),
                  ),
                )
              : "-";
          status = 'ONLINE';
        });
      } else {
        setState(() {
          status = 'OFFLINE';
          turbidity = 0.0;
          lastUpdated = "-";
        });
      }
    });
  }

  String getCategory(double ntu) {
    if (ntu <= 5) return 'Ideal';
    if (ntu <= 25) return 'Waspada';
    if (ntu <= 100) return 'Keruh';
    return 'Sangat Keruh';
  }

  Color getCategoryColor(double ntu) {
    if (ntu <= 5) return Colors.green;
    if (ntu <= 25) return Colors.amber;
    if (ntu <= 100) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final double displayNTU = turbidity ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monitoring Kekeruhan Air',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade400,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "Status: ",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            color: status == 'ONLINE' ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.water_drop_outlined, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "NTU: ${displayNTU.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "Kategori: ",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          getCategory(displayNTU),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: getCategoryColor(displayNTU),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "Terakhir Aktif: $lastUpdated",
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Data real-time dari sensor turbidity akan\nditampilkan setiap 15 detik.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
