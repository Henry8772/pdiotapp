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

class BluetoothConnect {
  late final ChartController chartController;
  final _ble = FlutterReactiveBle();
  final List<DiscoveredDevice> _devicesList = [];
  // late Stream<ConnectionStateUpdate> _connection;
  late Uuid serviceUuid;
  // late Uuid _characteristicUuid;
  // late DiscoveredDevice _connectedDevice;

  final uuidRespeckLive = Uuid.parse("00002010-0000-1000-8000-00805f9b34fb");
  final uuidRespeckLiveV4 = Uuid.parse("00001524-1212-efde-1523-785feabcd125");
  final uuidRespeckImu = Uuid.parse("00001527-1212-efde-1523-785feabcd125");
  final uuidRespeckService = Uuid.parse("00001523-1212-efde-1523-785feabcd125");

  void Function(double accX, double accY, double accZ)? onDataReceived;

  // Call this method from where you instantiate BluetoothUtils
  void setOnDataReceivedCallback(
      void Function(double accX, double accY, double accZ) callback) {
    onDataReceived = callback;
  }

  void connectToDevice(DiscoveredDevice device) {
    // Connect to the device
    _ble
        .connectToDevice(
      id: device.id,
      servicesWithCharacteristicsToDiscover: {},
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print('Device connected');
        discoverServices(device.id);
      }
    }, onError: (Object error) {
      print(error);
      // Handle a possible error
    });
  }

  void scanForDevices() {
    print("Scanning for devices...");
    _ble.scanForDevices(scanMode: ScanMode.lowLatency, withServices: []).listen(
        (device) {
      // Add the device to the list
      _devicesList.add(device);

      // Check if the device name contains 'Res6AL'
      if (device.name.contains('Res6AL')) {
        print('Found Bluetooth device with name containing "Res6AL":');
        print('Name: ${device.name}');
        print('Identifier: ${device.id}');

        if (device.id == 'D9:A7:42:37:ED:C3') {
          connectToDevice(device);
        }
      }
    }, onError: (error) {
      // Print the error to the console
      print('Error while scanning for devices: $error');
    });
  }

  void discoverServices(String deviceId) {
    _ble.discoverServices(deviceId).then((services) {
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          // Check if this characteristic is one of the ones we want to subscribe to
          // characteristic.characteristicId == uuidRespeckLive ||
          //     characteristic.characteristicId == uuidRespeckLiveV4 ||
          if (characteristic.characteristicId == uuidRespeckImu) {
            // Subscribe to the characteristic
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
    // Subscribe to the characteristic
    final characteristic = QualifiedCharacteristic(
        serviceId: uuidRespeckService,
        characteristicId: charId,
        deviceId: deviceId);

    _ble.subscribeToCharacteristic(characteristic).listen((data) {
      // print('Received raw data from ${characteristic.characteristicId}: $data');
      final imuPacket = decodeIMUPacket(Uint8List.fromList(data));
      // Now you can use imuPacket to access the accelerometer and gyroscope data
      // For example:
      // print('Accelerometer: ${imuPacket.sensorData.first.acc}');
      // print('Gyroscope: ${imuPacket.sensorData.first.gyro}');
      onDataReceived?.call(imuPacket.sensorData.first.acc.x,
          imuPacket.sensorData.first.acc.y, imuPacket.sensorData.first.acc.z);

      // code to handle incoming data
    }, onError: (dynamic error) {
      print(error);
      // code to handle errors
    });
  }

  // void _connectToDevice(DiscoveredDevice device) {
  //   _connection = _ble
  //       .connectToDevice(
  //     id: device.id,
  //     connectionTimeout: const Duration(seconds: 5),
  //   )
  //       .listen((connectionState) {
  //     if (connectionState.connectionState == DeviceConnectionState.connected) {
  //       _connectedDevice = device;
  //       _discoverServices();
  //     }
  //   }, onError: (error) {
  //     // Handle connection errors here
  //   });
  // }

  // void _discoverServices() {
  //   _ble.discoverServices(_connectedDevice.id).then((services) {
  //     final service =
  //         services.firstWhere((service) => service.serviceId == _serviceUuid);
  //     final characteristic = service.characteristics.firstWhere(
  //         (characteristic) =>
  //             characteristic.characteristicId == _characteristicUuid);
  //     _subscribeToCharacteristic(characteristic);
  //   }).catchError((error) {
  //     // Handle service discovery errors here
  //   });
  // }

  // void _subscribeToCharacteristic(QualifiedCharacteristic characteristic) {
  //   _ble.subscribeToCharacteristic(characteristic).listen((data) {
  //     // Use the IMU data
  //     print('IMU Data: $data');
  //   }, onError: (error) {
  //     // Handle characteristic subscription errors here
  //   });
}
