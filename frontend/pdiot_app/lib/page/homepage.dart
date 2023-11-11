import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SensorData> chartData = [];
  List<SensorData> gyroData = []; // List for gyroscope data
  bool isRecording = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    chartData = List.generate(
        20,
        (index) =>
            SensorData(index, randomValue(), randomValue(), randomValue()));
    gyroData = List.generate(
        20,
        (index) =>
            SensorData(index, randomValue(), randomValue(), randomValue()));
  }

  double randomValue() => Random().nextDouble() * 100;

  void startRecording() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        chartData.add(SensorData(
            chartData.length, randomValue(), randomValue(), randomValue()));
        gyroData.add(SensorData(
            gyroData.length, randomValue(), randomValue(), randomValue()));
        print(gyroData);
        if (chartData.length > 20) {
          chartData.removeAt(0);
          gyroData.removeAt(0);
        }
      });
    });
  }

  void stopRecording() {
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          // Makes the page scrollable
          padding: const EdgeInsets.fromLTRB(20.0, 30, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildMotionDisplayBox(),
              SizedBox(height: 20),
              buildChartBox('Accelerometer Data', chartData),
              SizedBox(height: 20),
              buildChartBox('Gyroscope Data', gyroData),
              SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () {
                  setState(() {
                    isRecording = !isRecording;
                    isRecording ? startRecording() : stopRecording();
                  });
                },
                child: Text(isRecording ? 'Stop' : 'Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotionDisplayBox() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Current Motion: ${isRecording ? 'Recording...' : 'Stopped'}",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

class SensorData {
  final int time;
  final double xAxis;
  final double yAxis;
  final double zAxis;

  SensorData(this.time, this.xAxis, this.yAxis, this.zAxis);
}
