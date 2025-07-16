import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/device_status_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  String _status = "OFFLINE";
  double _ntuValue = 0.0;
  String _lastSeen = "-";

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  void _loadDeviceData() {
    final ref = FirebaseDatabase.instance.ref("device_status/kolam_01");

    ref.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        setState(() {
          _status = "ONLINE";
          _ntuValue = (map['ntu'] ?? 0).toDouble();
          _lastSeen = map['timestamp']?.toString() ?? '-';
        });
      } else {
        setState(() {
          _status = "OFFLINE";
          _ntuValue = 0.0;
          _lastSeen = "-";
        });
      }
    });
  }

  void _updateNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    // Simpan ke Firestore / SharedPreferences jika diperlukan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "⚙️ Pengaturan",
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade400,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          DeviceStatusCard(
            status: _status,
            ntuValue: _ntuValue,
            lastSeen: _lastSeen,
          ),
          SizedBox(height: 24.h),
          Text("PENGATURAN UMUM", style: Theme.of(context).textTheme.titleSmall),
          const Divider(),
          SwitchListTile(
            title: const Text("Notifikasi"),
            subtitle: const Text("Terima notifikasi jika kondisi air berubah"),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: _updateNotifications,
          ),
        ],
      ),
    );
  }
}
