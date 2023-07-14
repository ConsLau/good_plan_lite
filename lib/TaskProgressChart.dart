import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskProgressChart extends StatelessWidget {
  final double taskProgress;

  const TaskProgressChart({Key? key, required this.taskProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: taskProgress,
            title: '',
          ),
          PieChartSectionData(
            color: Colors.grey.shade200,
            value: 1 - taskProgress,
            title: '',
          ),
        ],
      ),
    );
  }
}
