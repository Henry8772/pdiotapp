import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/bluetooth_utils.dart';

class ChartController with ChangeNotifier {
  BluetoothConnect? bluetoothInstance;

  List<FlSpot> accXData = [FlSpot(0, 0)];
  List<FlSpot> accYData = [FlSpot(0, 0)];
  List<FlSpot> accZData = [FlSpot(0, 0)]; // Start with a dummy data point
  Timer? _timer;
  double minY = 0;
  double maxY = 1;

  void Function(double accX, double accY, double accZ)? onNewSensorData;

  void setOnNewSensorDataCallback(
      void Function(double accX, double accY, double accZ) callback) {
    onNewSensorData = callback;
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

    // Ensure only the last 15 data points are kept
    if (accXData.length > 15) {
      accXData.removeAt(0);
    }
    if (accYData.length > 15) {
      accXData.removeAt(0);
    }
    if (accZData.length > 15) {
      accZData.removeAt(0);
    }

    updateYBounds(accX);
    updateYBounds(accY);
    updateYBounds(accZ);
    print(minY);
    print(maxY);

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
