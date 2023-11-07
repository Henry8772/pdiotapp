import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/custom_model.dart';
import '../utils/bluetooth_utils.dart';
import 'dart:io';

class ChartController with ChangeNotifier {
  BluetoothConnect? bluetoothInstance;

  List<FlSpot> accXData = [FlSpot(0, 0)];
  List<FlSpot> accYData = [FlSpot(0, 0)];
  List<FlSpot> accZData = [FlSpot(0, 0)];

  String output =
      "Waiting for result"; // consider using RxString for reactive programming if you're using GetX.
  CustomModel? model;

  List<Float32List> acc = []; // Start with a dummy data point
  Timer? _timer;
  double minY = 0;
  double maxY = 1;

  DateTime? lastDataTimestamp;
  int dataCount = 0;

  void Function(double accX, double accY, double accZ)? onNewSensorData;

  void setOnNewSensorDataCallback(
      void Function(double accX, double accY, double accZ) callback) {
    onNewSensorData = callback;
  }

  Future<void> load() async {
    if (model == null) {
      // Correct null comparison
      model =
          await CustomModel(); // Assuming CustomModel's constructor is asynchronous
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

    print('${last2SecData.length}, ${last2SecData[0].length}');

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
    if (acc.length % 3 == 0 && acc.length >= 50) {
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

  // void _addDummyData() {
  //   final random = math.Random();
  //   // Generate dummy data
  //   double nextAccX = random.nextDouble() * 10;
  //   double nextGyroX = random.nextDouble() * 10;

  //   // Add new data points
  //   accelerometerXData.add(FlSpot(
  //     accelerometerXData.length.toDouble(),
  //     nextAccX,
  //   ));
  //   gyroscopeXData.add(FlSpot(
  //     gyroscopeXData.length.toDouble(),
  //     nextGyroX,
  //   ));

  //   // Ensure only the last 15 data points are kept
  //   if (accelerometerXData.length > 15) {
  //     accelerometerXData.removeAt(0);
  //   }
  //   if (gyroscopeXData.length > 15) {
  //     gyroscopeXData.removeAt(0);
  //   }

  //   // Notify listeners (in this case, the UI)
  //   notifyListeners();
  // }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
