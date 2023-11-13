import 'dart:async';
import 'dart:math';
import 'package:pdiot_app/utils/bluetooth_utils.dart';
import 'package:pdiot_app/utils/database_utils.dart';

import '../utils/ui_utils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdiot_app/page/homepage_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController _controller = HomePageController();
  late StreamSubscription _dataSubscription;
  Map<String, dynamic> sensorData = {};

  @override
  void initState() {
    super.initState();
  }

  List<SensorData> chartData = [];
  List<SensorData> gyroData = []; // L
  Timer? timer;
  double randomValue() => Random().nextDouble() * 100;
  Map<String, int> currentSessionActivities = {};
  DateTime startTime = DateTime.now();
  int counter = 0;

  void startRecording() {
    print("Start recording");
    startTime = DateTime.now();
    // timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
    //   setState(() {
    //     chartData.add(SensorData(
    //         chartData.length, randomValue(), randomValue(), randomValue()));
    //     gyroData.add(SensorData(
    //         gyroData.length, randomValue(), randomValue(), randomValue()));
    //     // print(gyroData);
    //     if (chartData.length > 20) {
    //       chartData.removeAt(0);
    //       gyroData.removeAt(0);
    //     }
    //     String activity = _controller.getRandomActivity();
    //     if (currentSessionActivities[activity] == null) {
    //       currentSessionActivities[activity] = 1;
    //     } else {
    //       currentSessionActivities[activity] =
    //           currentSessionActivities[activity]! + 1;
    //     }
    //   });
    // });

    _dataSubscription = BluetoothConnect().dataStream.listen((data) {
      setState(() {
        chartData
            .add(SensorData(counter, data['accX'], data['accY'], data['accZ']));
        sensorData = data;
        counter += 1;

        // if (chartData.length > 20) {
        //   chartData.removeAt(0);
        //   // gyroData.removeAt(0);
        // }
      });
    });
  }

  void stopRecording() async {
    timer?.cancel();
    counter = 0;
    _dataSubscription.cancel();
    await _controller.saveSessionToDatabase(
        currentSessionActivities, startTime);
    currentSessionActivities.clear();
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
              buildChartBox(
                'Accelerometer Data',
                chartData.length <= 20
                    ? chartData
                    : chartData.sublist(chartData.length - 20),
              ),
              SizedBox(height: 20),
              buildChartBox('Gyroscope Data', gyroData),
              SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () {
                  setState(() {
                    _controller.isRecording = !_controller.isRecording;
                    _controller.isRecording
                        ? startRecording()
                        : stopRecording();
                  });
                },
                child: Text(_controller.isRecording ? 'Stop' : 'Start'),
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
        "Current Motion: ${_controller.isRecording ? 'Recording...' : 'Stopped'}",
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
