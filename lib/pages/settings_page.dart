import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/device_status_card.dart';
import 'widgets/fuzzy_logic_content.dart'; // ✅ Import widget fuzzy logic
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  double _threshold = 100.0;
  String _status = "OFFLINE";
  double _ntuValue = 0.0;
  String _lastSeen = "-";
  bool wasAboveThreshold = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late Box settingsBox;
  late StreamSubscription<DatabaseEvent> _subscription;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
    _loadPreferences();
    _initializeNotifications();
    _loadDeviceData();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _loadPreferences() {
    setState(() {
      _notificationsEnabled = settingsBox.get('notificationsEnabled', defaultValue: false);
      _threshold = settingsBox.get('threshold', defaultValue: 100.0);
    });
  }

  void _updateNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      settingsBox.put('notificationsEnabled', value);
    });
  }

  void _updateThreshold(double value) {
    setState(() {
      _threshold = value;
      settingsBox.put('threshold', value);
    });
  }

  void _loadDeviceData() {
    final ref = FirebaseDatabase.instance.ref("device_status/kolam_01");

    _subscription = ref.onValue.listen((event) {
      final data = event.snapshot.value;

      if (!mounted) return;

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);

        double ntu = 0.0;
        if (map['ntu'] is double) {
          ntu = map['ntu'];
        } else if (map['ntu'] is int) {
          ntu = (map['ntu'] as int).toDouble();
        }

        String formattedTime = "-";
        if (map['timestamp'] != null) {
          try {
            final timestamp = int.tryParse(map['timestamp'].toString());
            if (timestamp != null) {
              formattedTime = DateFormat('dd MMM yyyy HH:mm:ss').format(
                DateTime.fromMillisecondsSinceEpoch(timestamp),
              );
            }
          } catch (_) {}
        }

        setState(() {
          _status = "ONLINE";
          _ntuValue = ntu;
          _lastSeen = formattedTime;
        });

        if (_notificationsEnabled) {
          if (ntu > _threshold && !wasAboveThreshold) {
            _showNotification(
              "Peringatan",
              "Kekeruhan air melebihi batas ($_threshold NTU): $ntu NTU",
            );
            wasAboveThreshold = true;
          } else if (ntu <= _threshold && wasAboveThreshold) {
            wasAboveThreshold = false;
          }
        }
      } else {
        setState(() {
          _status = "OFFLINE";
          _ntuValue = 0.0;
          _lastSeen = "-";
        });
      }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'turbidity_channel_id',
      'Peringatan Kekeruhan',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙️ Pengaturan", style: TextStyle(fontWeight: FontWeight.bold)),
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
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ambang Batas Kekeruhan (NTU): ${_threshold.toInt()}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Slider(
                value: _threshold,
                min: 0,
                max: 500,
                divisions: 100,
                label: _threshold.round().toString(),
                onChanged: _updateThreshold,
              ),
            ],
          ),
          const FuzzyLogicContent(), // ✅ Memanggil widget fuzzy logic dari file terpisah
        ],
      ),
    );
  }
}
