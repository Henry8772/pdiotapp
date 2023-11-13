import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdiot_app/model/current_user.dart';
import '../model/custom_model.dart';
import '../utils/bluetooth_utils.dart';
// import 'dart:io';

import '../utils/file_utils.dart';

class SettingsController with ChangeNotifier {
  List<FlSpot> accXData = [FlSpot(0, 0)];
  List<FlSpot> accYData = [FlSpot(0, 0)];
  List<FlSpot> accZData = [FlSpot(0, 0)];

  CustomModel? model;

  List<Float32List> acc = [];

  DateTime? lastDataTimestamp;
  int dataCount = 0;
  Timer? timer;

  void Function(double accX, double accY, double accZ)? onNewSensorData;

  void setOnNewSensorDataCallback(
      void Function(double accX, double accY, double accZ) callback) {
    onNewSensorData = callback;
  }

  void addDummyDataTest() {
    const frequency = Duration(milliseconds: 40); // 25 Hz
    timer = Timer.periodic(frequency, (Timer t) {
      addDummyData();
    });
  }

  void stopDummyDataTest() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
      print('Dummy data generation stopped.');

      FileUtils.saveCsv(acc);
    }
  }

  // Future<void> load() async {
  //   if (model == null) {
  //     // Correct null comparison
  //     model =
  //         CustomModel(); // Assuming CustomModel's constructor is asynchronous
  //     await model!
  //         .loadModel(); // model is nullable, so we should use the null-aware operator (!.)
  //   }
  // }

  void connectBluetooth() {
    // if (bluetoothInstance == null) {
    //   setOnNewSensorDataCallback(addSensorData);
    // }

    BluetoothConnect().scanForDevices('D9:A7:42:37:ED:C3');

    // bluetoothInstance?.scanForDevices('D9:A7:42:37:ED:C3');
    // bluetoothInstance?.setOnDataReceivedCallback((accX, accY, accZ) {
    //   // This will be called by BluetoothUtils when new data is received
    //   addSensorData(accX, accY, accZ);
    // });
  }

  void addSensorData(double accX, double accY, double accZ) {
    // Add new data points for accelerometer and gyroscope
    accXData.add(FlSpot(
      accXData.length.toDouble(),
      accX,
    ));
    accYData.add(FlSpot(
      accYData.length.toDouble(),
      accY,
    ));
    accZData.add(FlSpot(
      accZData.length.toDouble(),
      accZ,
    ));
    acc.add(Float32List.fromList([accX, accY, accZ]));
    // if (acc.length % 25 == 0 && acc.length >= 50) {
    //   predictRealTime();
    // }

    notifyListeners();
  }

  void addDummyData() {
    final random = math.Random();
    double generateRandom() => -1.8 + random.nextDouble() * (3.6);
    // Generate dummy data
    double accX = generateRandom();
    double accY = generateRandom();
    double accZ = generateRandom();
    // double gyroX = random.nextDouble() * 10;
    // double gyroY = random.nextDouble() * 10;
    // double gyriZ = random.nextDouble() * 10;

    addSensorData(accX, accY, accZ);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
