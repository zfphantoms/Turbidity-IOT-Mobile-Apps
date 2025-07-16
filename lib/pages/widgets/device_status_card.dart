import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeviceStatusCard extends StatelessWidget {
  final String status;
  final double ntuValue;
  final String lastSeen;

  const DeviceStatusCard({
    super.key,
    required this.status,
    required this.ntuValue,
    required this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = status == 'ONLINE';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: $status',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isOnline ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'NTU: ${ntuValue.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 5.h),
            Text(
              'Terakhir Aktif: $lastSeen',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
