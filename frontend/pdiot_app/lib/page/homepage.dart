import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:pdiot_app/model/custom_model.dart';
import 'package:pdiot_app/utils/bluetooth_utils.dart';

import '../utils/ui_utils.dart';

import 'package:flutter/material.dart';
import 'package:pdiot_app/page/homepage_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController _controller = HomePageController();
  late StreamSubscription _dataSubscription;

  List<Float32List> acc = [];

  @override
  void initState() {
    super.initState();
  }

  List<SensorData> chartData = [];
  List<SensorData> gyroData = []; // L
  double randomValue() => Random().nextDouble() * 100;
  Map<String, int> currentSessionActivities = {};
  DateTime startTime = DateTime.now();
  int counter = 0;
  ModelType selectedModel = ModelType.task1; // Default selected value
  List<ModelType> models = ModelType.values;

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
        List<Float32List> last2SecData = acc.sublist(acc.length - 50);
        String result = await CustomModel().performInference(last2SecData);
        print(result);
      }

      String activity = _controller.getRandomActivity();
      if (currentSessionActivities[activity] == null) {
        currentSessionActivities[activity] = 1;
      } else {
        currentSessionActivities[activity] =
            currentSessionActivities[activity]! + 1;
      }
    });
  }

  String modelToString(ModelType model) {
    switch (model) {
      case ModelType.task1:
        return 'Task 1';
      case ModelType.task2:
        return 'Task 2';
      case ModelType.task3:
        return 'Task 3';
      default:
        return '';
    }
  }

  void stopRecording() async {
    counter = 0;
    _dataSubscription.cancel();
    await _controller.saveSessionToDatabase(
        currentSessionActivities, startTime);
    currentSessionActivities.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
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
              recordingButton(),
              const SizedBox(height: 20),
              modelSelectionAndLoad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget recordingButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _controller.isRecording = !_controller.isRecording;
          _controller.isRecording ? startRecording() : stopRecording();
        });
      },
      child: Text(_controller.isRecording ? 'Stop' : 'Start'),
    );
  }

  Widget modelSelectionAndLoad() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dropdown for model selection
        DropdownButton<ModelType>(
          value: selectedModel,
          onChanged: (ModelType? newValue) {
            setState(() {
              selectedModel = newValue!;
            });
          },
          items: models.map<DropdownMenuItem<ModelType>>((ModelType model) {
            return DropdownMenuItem<ModelType>(
              value: model,
              child: Text(modelToString(model)),
            );
          }).toList(),
        ),

        SizedBox(width: 10), // Space between dropdown and button

        // Load button
        ElevatedButton(
          onPressed: () {
            CustomModel().loadModel(selectedModel);
          },
          child: const Text("Load"),
        ),
      ],
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
    super.dispose();
  }
}
