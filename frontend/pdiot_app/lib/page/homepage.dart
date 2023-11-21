import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:pdiot_app/model/current_user.dart';
import 'package:pdiot_app/model/custom_model.dart';
import 'package:pdiot_app/utils/bluetooth_utils.dart';
import 'package:pdiot_app/utils/classification_utils.dart';
import 'package:pdiot_app/utils/database_utils.dart';

import '../utils/ui_utils.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // HomePageController _controller = HomePageController();
  late StreamSubscription _dataSubscription;

  List<Float32List> acc = [];
  bool isRecording = false;
  List<Float32List> gyro = [];
  List<Float32List> accAndGyro = [];

  @override
  void initState() {
    super.initState();
    selectedModel = CustomModel().getCurrentModel();
    modelLoaded = isModelLoaded();
  }

  List<SensorData> chartAccData = [];
  List<SensorData> chartGyroData = []; // L
  double randomValue() => Random().nextDouble() * 100;
  Map<String, int> currentSessionActivities = {};
  DateTime startTime = DateTime.now();
  int counter = 0;
  ModelType selectedModel = ModelType.physical;
  ModelType loadedModel = ModelType.task0; // Default selected value
  List<ModelType> models = ModelType.values;
  String currentActivity = "None";
  bool modelLoaded = false;

  void checkBeforeStartRecording() {
    bool bluetooth = BluetoothConnect().isBluetoothConnected();
    if (modelLoaded && bluetooth) {
      startRecording();
    } else if (!modelLoaded && !bluetooth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please load model and connect bluetooth in Settings"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (modelLoaded && !bluetooth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please connect bluetooth in Settings"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (!modelLoaded && bluetooth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please load model first"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void startRecording() {
    startTime = DateTime.now();
    isRecording = true;

    _dataSubscription = BluetoothConnect().dataStream.listen((data) async {
      if (!mounted) return;
      setState(() {
        chartAccData
            .add(SensorData(counter, data['accX'], data['accY'], data['accZ']));
        chartGyroData.add(
            SensorData(counter, data['gyroX'], data['gyroY'], data['gyroZ']));
      });
      counter += 1;

      acc.add(Float32List.fromList([data['accX'], data['accY'], data['accZ']]));

      accAndGyro.add(Float32List.fromList([
        data['accX'],
        data['accY'],
        data['accZ'],
        data['gyroX'],
        data['gyroY'],
        data['gyroZ']
      ]));
      gyro.add(
          Float32List.fromList([data['gyroX'], data['gyroY'], data['gyroZ']]));

      if (acc.length % 25 == 0 && acc.length >= 50) {
        List<Float32List> last2SecData = acc.sublist(acc.length - 50);
        // List<Float32List> last2SecAllData =
        //     accAndGyro.sublist(accAndGyro.length - 50);
        List<Float32List> last2SecGyroData = gyro.sublist(gyro.length - 50);
        Map<ModelType, String> result = await CustomModel()
            .performInference(last2SecData, last2SecGyroData);
        // String result = await CustomModel()
        //     .performInference(last2SecData, last2SecAllData, last2SecGyroData);
        String resultString = processModelResult(result);
        setState(() {
          currentActivity = resultString;
        });
        if (currentSessionActivities[resultString] == null) {
          currentSessionActivities[resultString] = 1;
        } else {
          currentSessionActivities[resultString] =
              currentSessionActivities[resultString]! + 1;
        }
      }
    });
  }

  String processModelResult(Map<ModelType, String> result) {
    String physicalAct = result[ModelType.physical] ?? '';
    String respiratoryAct = result[ModelType.respiratory] ?? '';

    if (physicalClassesWithRespiratory.contains(physicalAct)) {
      return "$physicalAct - $respiratoryAct";
    } else {
      return physicalAct;
    }
  }

  String modelToString(ModelType model) {
    switch (model) {
      case ModelType.physical:
        return 'Physical';
      case ModelType.task2:
        return 'Respiratory';
      case ModelType.respiratory:
        return 'Task 3';
      default:
        return '';
    }
  }

  void stopRecording() async {
    counter = 0;
    isRecording = false;
    _dataSubscription.cancel();
    await saveSessionToDatabase(currentSessionActivities, startTime);
    currentSessionActivities.clear();
  }

  List<SensorData> getAccChartData() {
    if (chartAccData.length > 50) {
      // Return the last 50 elements
      return chartAccData.sublist(chartAccData.length - 50);
    } else {
      // Return the entire list if it has 50 or fewer elements
      return chartAccData;
    }
  }

  List<SensorData> getGyroChartData() {
    if (chartGyroData.length > 50) {
      // Return the last 50 elements
      return chartGyroData.sublist(chartGyroData.length - 50);
    } else {
      // Return the entire list if it has 50 or fewer elements
      return chartGyroData;
    }
  }

  Future<bool> saveSessionToDatabase(
      Map<String, int> sessionDurations, DateTime startTime) async {
    int userId = int.parse(CurrentUser.instance.id.value);
    int sessionId = await DatabaseHelper.createNewSession(userId, startTime);

    sessionDurations.forEach((activityName, duration) async {
      int activityId = await DatabaseHelper.getActivityIdByName(
          activityName); // Get activity ID by name
      Map<String, dynamic> sessionActivity = {
        'sessionId': sessionId,
        'activityId': activityId,
        'duration': duration,
      };

      await DatabaseHelper.insertSessionActivity(sessionActivity);
    });

    return true;
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
                  buildChartBox('Accelerometer Data', getAccChartData()),
                  SizedBox(height: 20),
                  buildChartBox('Gyroscope Data', getGyroChartData()),
                  SizedBox(height: 20),
                ],
              )),
          Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isRecording ? stopRecording() : startRecording();
                  });
                },
                child: _buildControlBox(),
              ))
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
        isRecording ? 'Stop' : 'Start',
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

        SizedBox(width: 10), // Space between dropdown and button

        // Load button
        ElevatedButton(
          onPressed: () async {
            if (!isModelLoaded()) {
              modelLoaded = await CustomModel().loadModel();
              if (modelLoaded) {
                setState(() {
                  loadedModel = selectedModel;
                  // Trigger a rebuild to update the UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Model ${modelToString(selectedModel)} is loaded"),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Model ${modelToString(selectedModel)} is already loaded"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          // child: Text("Load Model"),
          child: Text(modelLoaded ? "Model is Loaded" : "Load Model"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                // return Colors.blue;
                return modelLoaded ? Colors.green : Colors.blue;
              },
            ),
          ),
        ),
      ],
    );
  }

  bool isModelLoaded() {
    return CustomModel().isModelLoaded();
  }

  // Combined Control Box for Recording and Model Selection
  Widget _buildControlBox() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          // Text(
          //   loadedModel == ModelType.task0
          //       ? 'No model is loaded'
          //       : 'Model ${modelToString(loadedModel)} is loaded',
          // ),
          SizedBox(height: 10),
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
            "Current Activity: ${isRecording ? currentActivity : 'None'}",
            // "Current Activity:",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        getActivityIcon(currentActivity), // Updated for specific activities
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
