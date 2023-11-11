import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdiot_app/model/current_user.dart';
import '../model/custom_model.dart';
import '../utils/bluetooth_utils.dart';
// import 'dart:io';

import '../utils/file_utils.dart';

class ChartController with ChangeNotifier {
  BluetoothConnect? bluetoothInstance;

  List<FlSpot> accXData = [FlSpot(0, 0)];
  List<FlSpot> accYData = [FlSpot(0, 0)];
  List<FlSpot> accZData = [FlSpot(0, 0)];

  String output =
      "Waiting for result"; // consider using RxString for reactive programming if you're using GetX.
  CustomModel? model;

  List<Float32List> acc = [];
// Start with a dummy data point
  double minY = 0;
  double maxY = 1;

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

  Future<void> load() async {
    if (model == null) {
      // Correct null comparison
      model =
          CustomModel(); // Assuming CustomModel's constructor is asynchronous
      await model!
          .loadModel(); // model is nullable, so we should use the null-aware operator (!.)
    }
  }

  void connectBluetooth() {
    if (bluetoothInstance == null) {
      bluetoothInstance = BluetoothConnect();
      setOnNewSensorDataCallback(addSensorData);
    }

    bluetoothInstance?.scanForDevices();
    bluetoothInstance?.setOnDataReceivedCallback((accX, accY, accZ) {
      // This will be called by BluetoothUtils when new data is received
      addSensorData(accX, accY, accZ);
    });
  }

  Future<void> predictRealTime() async {
    if (model == null) {
      // handle the case where the model might not be loaded yet
      print('Model not loaded yet');
      load();
    }
    List<Float32List> last2SecData = acc.sublist(acc.length - 50);

    String result = await model!.performInference(last2SecData);

    output = result;
  }

  void addSensorData(double accX, double accY, double accZ) {
    // final now = DateTime.now();
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
    if (acc.length % 25 == 0 && acc.length >= 50) {
      predictRealTime();
    }

    updateYBounds(accX);
    updateYBounds(accY);
    updateYBounds(accZ);

    // Notify listeners (in this case, the UI)
    notifyListeners();
  }

  void updateYBounds(double newValue) {
    // Assuming minY and maxY are properties of your controller
    if (newValue < minY) {
      minY = newValue;
    }
    if (newValue > maxY) {
      maxY = newValue;
    }
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
