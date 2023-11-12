import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdiot_app/page/homepage.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorData {
  final int time;
  final double xAxis;
  final double yAxis;
  final double zAxis;

  SensorData(this.time, this.xAxis, this.yAxis, this.zAxis);
}

Widget buildChartBox(String title, List<SensorData> data) {
  return Container(
    height: 200, // Fixed height for the chart container
    decoration: BoxDecoration(
      color: CupertinoColors.systemGrey6,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: title),
      series: <ChartSeries>[
        LineSeries<SensorData, int>(
          dataSource: data,
          xValueMapper: (SensorData data, _) => data.time,
          yValueMapper: (SensorData data, _) => data.xAxis,
          name: 'X-Axis',
        ),
        LineSeries<SensorData, int>(
          dataSource: data,
          xValueMapper: (SensorData data, _) => data.time,
          yValueMapper: (SensorData data, _) => data.yAxis,
          name: 'Y-Axis',
        ),
        LineSeries<SensorData, int>(
          dataSource: data,
          xValueMapper: (SensorData data, _) => data.time,
          yValueMapper: (SensorData data, _) => data.zAxis,
          name: 'Z-Axis',
        ),
      ],
    ),
  );
}
