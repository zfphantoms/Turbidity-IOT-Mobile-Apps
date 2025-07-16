import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const HistoryChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      return Text(
                        data[index]['label'].toString(),
                        style: TextStyle(fontSize: 8.sp),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  interval: (data.length / 5).ceilToDouble(),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40.w),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((entry) {
                  int index = entry.key;
                  double value = entry.value['value'].toDouble();
                  return FlSpot(index.toDouble(), value);
                }).toList(),
                isCurved: true,
                barWidth: 2,
                color: Colors.blue,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withAlpha(77), // ← updated here
                ),
                dotData: FlDotData(show: false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
