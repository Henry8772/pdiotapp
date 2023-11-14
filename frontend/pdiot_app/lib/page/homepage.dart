import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:pdiot_app/model/custom_model.dart';
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
  // Map<String, dynamic> sensorData = {};

  List<Float32List> acc = [];

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
    startTime = DateTime.now();

    _dataSubscription = BluetoothConnect().dataStream.listen((data) async {
      if (!mounted) return;
      setState(() {
        chartData
            .add(SensorData(counter, data['accX'], data['accY'], data['accZ']));
        // sensorData = data;
        counter += 1;

        acc.add(
            Float32List.fromList([data['accX'], data['accY'], data['accZ']]));
      });

      if (acc.length % 25 == 0 && acc.length >= 50) {
        print("Starting inferencing");
        List<Float32List> last2SecData = acc.sublist(acc.length - 50);
        String result = await CustomModel().performInference(last2SecData);
        print(result);
      }

      // output = result;

      String activity = _controller.getRandomActivity();
      if (currentSessionActivities[activity] == null) {
        currentSessionActivities[activity] = 1;
      } else {
        currentSessionActivities[activity] =
            currentSessionActivities[activity]! + 1;
      }
    });
  }

// This method uses an isolate to perform inference
  // void performInferenceInBackground() async {
  //   List<Float32List> last2SecData = acc.sublist(acc.length - 50);

  //   ReceivePort receivePort = ReceivePort();
  //   Isolate.spawn(_inferenceIsolate, receivePort.sendPort);

  //   SendPort sendPort = await receivePort.first;
  //   sendPort.send([last2SecData, receivePort.sendPort]);

  //   // Receive the result from the isolate
  //   receivePort.listen((result) {
  //     String activity = result;
  //     print("activity");
  //     print(activity);
  //     // Update your UI or state based on the result here
  //     // ...
  //   });
  // }

// Isolate function for inference
  // void _inferenceIsolate(SendPort initialSendPort) async {
  //   ReceivePort port = ReceivePort();
  //   initialSendPort.send(port.sendPort);

  //   await for (var message in port) {
  //     List<Float32List> data = message[0];
  //     SendPort replyPort = message[1];

  //     // Perform your inference here
  //     String result = await CustomModel().performInference(data);

  //     // Send the result back to the main thread
  //     replyPort.send(result);
  //   }
  // }

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
              const SizedBox(height: 20),
              buildChartBox(
                'Accelerometer Data',
                chartData.length <= 50
                    ? chartData
                    : chartData.sublist(chartData.length - 50),
              ),
              const SizedBox(height: 20),
              buildChartBox('Gyroscope Data', gyroData),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () {
                  CustomModel().loadModel(ModelType.modelA);
                },
                child: Text("load"),
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
