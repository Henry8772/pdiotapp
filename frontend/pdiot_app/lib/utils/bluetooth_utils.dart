import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:typed_data';
import '../page/chart_controller.dart';

class AccelerometerReading {
  final double x;
  final double y;
  final double z;

  AccelerometerReading(this.x, this.y, this.z);

  @override
  String toString() => 'AccelerometerReading(x: $x, y: $y, z: $z)';
}

class GyroscopeReading {
  final double x;
  final double y;
  final double z;

  GyroscopeReading(this.x, this.y, this.z);

  @override
  String toString() => 'GyroscopeReading(x: $x, y: $y, z: $z)';
}

class RESpeckSensorData {
  final int timestamp;
  final AccelerometerReading acc;
  final GyroscopeReading gyro;
  final bool highFrequency;

  RESpeckSensorData(this.timestamp, this.acc, this.gyro,
      {this.highFrequency = false});
}

class RESpeckRawPacket {
  final int id;
  final int timestamp;
  final List<RESpeckSensorData> sensorData;

  RESpeckRawPacket(this.id, this.timestamp, this.sensorData);
}

RESpeckRawPacket decodeIMUPacket(Uint8List values,
    {bool highFrequency = false}) {
  final buffer = ByteData.sublistView(values);
  // Assuming the byte order is little endian
  final gyroX = buffer.getInt16(0, Endian.little) / 64.0;
  final gyroY = buffer.getInt16(2, Endian.little) / 64.0;
  final gyroZ = buffer.getInt16(4, Endian.little) / 64.0;

  final accelX = buffer.getInt16(6, Endian.little) / 16384.0;
  final accelY = buffer.getInt16(8, Endian.little) / 16384.0;
  final accelZ = buffer.getInt16(10, Endian.little) / 16384.0;

  final acc = AccelerometerReading(accelX, accelY, accelZ);
  final gyro = GyroscopeReading(gyroX, gyroY, gyroZ);

  final sensorData = RESpeckSensorData(
    0, // Placeholder for timestamp
    acc,
    gyro,
    highFrequency: highFrequency,
  );

  return RESpeckRawPacket(
    0, // Placeholder for packet ID
    0, // Placeholder for packet timestamp
    [sensorData],
  );
}

typedef ConnectionCallback = void Function(bool isConnected);

class BluetoothConnect {
  // Singleton pattern
  static final BluetoothConnect _instance = BluetoothConnect._internal();
  factory BluetoothConnect() => _instance;
  BluetoothConnect._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final List<DiscoveredDevice> _devicesList = [];
  final StreamController<Map<String, dynamic>> _dataStreamController =
      StreamController.broadcast();

  bool isConnected = false;

  final uuidRespeckLive = Uuid.parse("00002010-0000-1000-8000-00805f9b34fb");
  final uuidRespeckLiveV4 = Uuid.parse("00001524-1212-efde-1523-785feabcd125");
  final uuidRespeckImu = Uuid.parse("00001527-1212-efde-1523-785feabcd125");
  final uuidRespeckService = Uuid.parse("00001523-1212-efde-1523-785feabcd125");

  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  // Callback instance
  ConnectionCallback? onConnectionChanged;

  // Expose a stream to listen to data
  // Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  bool isBluetoothConnected() {
    return isConnected;
  }

  void connectToDevice(DiscoveredDevice device,
      {ConnectionCallback? onConnectionChanged}) {
    this.onConnectionChanged = onConnectionChanged;

    _ble
        .connectToDevice(
      id: device.id,
      servicesWithCharacteristicsToDiscover: {},
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print('Device connected');
        isConnected = true;
        discoverServices(device.id);

        // Trigger the callback on successful connection
        onConnectionChanged?.call(true);
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        // Trigger the callback on disconnection
        onConnectionChanged?.call(false);
      }
    }, onError: (Object error) {
      print(error);
      onConnectionChanged?.call(false);
    });
  }

  void scanForDevices(String deviceId,
      {ConnectionCallback? onConnectionChanged}) {
    _ble.scanForDevices(scanMode: ScanMode.lowLatency, withServices: []).listen(
        (device) {
      _devicesList.add(device);
      if (device.name.contains('Res6AL') && device.id == deviceId) {
        connectToDevice(device, onConnectionChanged: onConnectionChanged);
      }
    }, onError: (error) {
      print('Error while scanning for devices: $error');
      onConnectionChanged?.call(false);
    });
  }

  void discoverServices(String deviceId) {
    _ble.discoverServices(deviceId).then((services) {
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.characteristicId == uuidRespeckImu) {
            subscribeToCharacteristic(
                characteristic.characteristicId, deviceId);
          }
        }
      }
    }).catchError((error) {
      print('Error discovering services: $error');
    });
  }

  void subscribeToCharacteristic(Uuid charId, String deviceId) {
    final characteristic = QualifiedCharacteristic(
        serviceId: uuidRespeckService,
        characteristicId: charId,
        deviceId: deviceId);

    _ble.subscribeToCharacteristic(characteristic).listen((data) {
      final imuPacket = decodeIMUPacket(Uint8List.fromList(data));
      _dataStreamController.add({
        'accX': imuPacket.sensorData.first.acc.x,
        'accY': imuPacket.sensorData.first.acc.y,
        'accZ': imuPacket.sensorData.first.acc.z,
        'gyroX': imuPacket.sensorData.first.gyro.x,
        'gyroY': imuPacket.sensorData.first.gyro.y,
        'gyroZ': imuPacket.sensorData.first.gyro.z
      });
    }, onError: (dynamic error) {
      print(error);
    });
  }

  // Ensure to close the stream controller when it's no longer needed
  void dispose() {
    isConnected = false;
    _dataStreamController.close();
  }
}


// class BluetoothConnect {
//   // late final ChartController chartController;
//   final _ble = FlutterReactiveBle();
//   final List<DiscoveredDevice> _devicesList = [];
//   // late Stream<ConnectionStateUpdate> _connection;
//   late Uuid serviceUuid;
//   // late Uuid _characteristicUuid;
//   // late DiscoveredDevice _connectedDevice;

//   final uuidRespeckLive = Uuid.parse("00002010-0000-1000-8000-00805f9b34fb");
//   final uuidRespeckLiveV4 = Uuid.parse("00001524-1212-efde-1523-785feabcd125");
//   final uuidRespeckImu = Uuid.parse("00001527-1212-efde-1523-785feabcd125");
//   final uuidRespeckService = Uuid.parse("00001523-1212-efde-1523-785feabcd125");

//   void Function(double accX, double accY, double accZ)? onDataReceived;

//   // Call this method from where you instantiate BluetoothUtils
//   void setOnDataReceivedCallback(
//       void Function(double accX, double accY, double accZ) callback) {
//     onDataReceived = callback;
//   }

//   void connectToDevice(DiscoveredDevice device) {
//     // Connect to the device
//     _ble
//         .connectToDevice(
//       id: device.id,
//       servicesWithCharacteristicsToDiscover: {},
//       connectionTimeout: const Duration(seconds: 2),
//     )
//         .listen((connectionState) {
//       if (connectionState.connectionState == DeviceConnectionState.connected) {
//         print('Device connected');
//         discoverServices(device.id);
//       }
//     }, onError: (Object error) {
//       print(error);
//       // Handle a possible error
//     });
//   }

//   void scanForDevices(String deviceId) {
//     // print("Scanning for devices...");
//     _ble.scanForDevices(scanMode: ScanMode.lowLatency, withServices: []).listen(
//         (device) {
//       // Add the device to the list
//       _devicesList.add(device);

//       // Check if the device name contains 'Res6AL'
//       if (device.name.contains('Res6AL')) {
//         // print('Found Bluetooth device with name containing "Res6AL":');
//         // print('Name: ${device.name}');
//         // print('Identifier: ${device.id}');

//         if (device.id == deviceId) {
//           connectToDevice(device);
//         }
//       }
//     }, onError: (error) {
//       // Print the error to the console
//       print('Error while scanning for devices: $error');
//     });
//   }

//   void discoverServices(String deviceId) {
//     _ble.discoverServices(deviceId).then((services) {
//       for (final service in services) {
//         for (final characteristic in service.characteristics) {
//           // Check if this characteristic is one of the ones we want to subscribe to
//           // characteristic.characteristicId == uuidRespeckLive ||
//           //     characteristic.characteristicId == uuidRespeckLiveV4 ||
//           if (characteristic.characteristicId == uuidRespeckImu) {
//             // Subscribe to the characteristic
//             subscribeToCharacteristic(
//                 characteristic.characteristicId, deviceId);
//           }
//         }
//       }
//     }).catchError((error) {
//       print('Error discovering services: $error');
//     });
//   }

//   void subscribeToCharacteristic(Uuid charId, String deviceId) {
//     // Subscribe to the characteristic
//     final characteristic = QualifiedCharacteristic(
//         serviceId: uuidRespeckService,
//         characteristicId: charId,
//         deviceId: deviceId);

//     _ble.subscribeToCharacteristic(characteristic).listen((data) {
//       // print('Received raw data from ${characteristic.characteristicId}: $data');
//       final imuPacket = decodeIMUPacket(Uint8List.fromList(data));
//       // Now you can use imuPacket to access the accelerometer and gyroscope data
//       // For example:
//       // print('Accelerometer: ${imuPacket.sensorData.first.acc}');
//       // print('Gyroscope: ${imuPacket.sensorData.first.gyro}');
//       onDataReceived?.call(imuPacket.sensorData.first.acc.x,
//           imuPacket.sensorData.first.acc.y, imuPacket.sensorData.first.acc.z);

//       // code to handle incoming data
//     }, onError: (dynamic error) {
//       print(error);
//       // code to handle errors
//     });
//   }
// }
