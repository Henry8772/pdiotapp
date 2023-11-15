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
  String currentActivity = "None";

  void startRecording() {
    startTime = DateTime.now();

    _dataSubscription = BluetoothConnect().dataStream.listen((data) async {
      if (!mounted) return;
      setState(() {
        chartData
            .add(SensorData(counter, data['accX'], data['accY'], data['accZ']));
      });
      counter += 1;

      acc.add(Float32List.fromList([data['accX'], data['accY'], data['accZ']]));

      if (acc.length % 25 == 0 && acc.length >= 50) {
        List<Float32List> last2SecData = acc.sublist(acc.length - 50);
        String result = await CustomModel().performInference(last2SecData);
        setState(() {
          currentActivity = result; // Update current activity
        });
        if (currentSessionActivities[result] == null) {
          currentSessionActivities[result] = 1;
        } else {
          currentSessionActivities[result] =
              currentSessionActivities[result]! + 1;
        }
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

  List<SensorData> getChartData() {
    if (chartData.length > 50) {
      // Return the last 50 elements
      return chartData.sublist(chartData.length - 50);
    } else {
      // Return the entire list if it has 50 or fewer elements
      return chartData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: Image.asset('assets/images/组 117@2x.png')),
          Positioned(
              top: 58,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _buildMotionDisplayBox(),
                  SizedBox(height: 20),
                  buildChartBox('Accelerometer Data', getChartData()),
                  SizedBox(height: 20),
                  buildChartBox('Gyroscope Data', getChartData()),
                  SizedBox(height: 20),
                ],
              )),
          Positioned(
              bottom: 50,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.isRecording = !_controller.isRecording;
                    _controller.isRecording
                        ? startRecording()
                        : stopRecording();
                  });
                },
                child: _buildControlBox(),
              )),
        ],
      ),
    );
  }

  Widget recordingButton() {
    return Container(
      width: double.infinity,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [
            Color(0xff4A8DFF),
            Color(0xff1D52FF),
          ])),
      child: Text(
        _controller.isRecording ? 'Stop' : 'Start',
        style: const TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400),
      ),
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
          onPressed: () async {
            bool loaded = await CustomModel().loadModel(selectedModel);
            if (loaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text("Model ${modelToString(selectedModel)} is loaded"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text("Load Model"),
        ),
      ],
    );
  }

  // Combined Control Box for Recording and Model Selection
  Widget _buildControlBox() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          modelSelectionAndLoad(),
          SizedBox(height: 10), // Spacing between buttons

          recordingButton(),
        ],
      ),
    );
  }

  // Common box decoration
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    );
  }

  // Redesigned Motion Display Box
  Widget _buildMotionDisplayBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            "Current Activity: ${_controller.isRecording ? currentActivity : 'None'}",
            // "Current Activity:",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        _getActivityIcon(currentActivity), // Updated for specific activities
      ],
    );
  }

  // Function to get dynamic border color based on activity
  // Function to get dynamic border color based on activity
  Color getActivityColor(String activity) {
    switch (activity) {
      case "Ascending stairs":
        return Colors.deepOrange;
      case "Descending stairs":
        return Colors.brown;
      case "Lying down back":
        return Colors.lightBlue;
      case "Lying down on left":
        return Colors.purple;
      case "Lying down right":
        return Colors.pink;
      case "Lying down on stomach":
        return Colors.teal;
      case "Miscellaneous movements":
        return Colors.grey;
      case "Normal walking":
        return Colors.green;
      case "Running":
        return Colors.red;
      case "Shuffle walking":
        return Colors.amber;
      case "Sitting/standing":
        return Colors.indigo;
      default:
        return Colors
            .blue; // Default color when no specific activity is detected
    }
  }

  Widget _getActivityIcon(String activity) {
    IconData icon;
    switch (activity) {
      case "Ascending stairs":
        icon = Icons.arrow_upward;
        break;
      case "Descending stairs":
        icon = Icons.arrow_downward;
        break;
      case "Lying down back":
      case "Lying down on left":
      case "Lying down right":
      case "Lying down on stomach":
        icon = Icons.bed;
        break;
      case "Miscellaneous movements":
        icon = Icons.shuffle;
        break;
      case "Normal walking":
        icon = Icons.directions_walk;
        break;
      case "Running":
        icon = Icons.directions_run;
        break;
      case "Shuffle walking":
        icon = Icons.transfer_within_a_station;
        break;
      case "Sitting/standing":
        icon = Icons.event_seat;
        break;
      default:
        icon = Icons.help_outline;
    }
    return Icon(icon, size: 30, color: getActivityColor(activity));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
