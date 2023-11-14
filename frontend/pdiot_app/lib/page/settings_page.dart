import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/model/current_user.dart';
import 'package:pdiot_app/page/login_page.dart';
import 'package:pdiot_app/utils/bluetooth_utils.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _bluetoothDeviceIdController =
      TextEditingController();
  bool _isBluetoothConnected = false;
  String _connectedDeviceId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.account_circle, size: 40.0), // Larger icon
              title: Obx(() => Text(
                    CurrentUser.instance.username.value,
                    style: Theme.of(context).textTheme.headline6,
                  )),
              onTap: () {
                // User profile tap action
              },
            ),
          ),
          Divider(),
          ListTile(
            title:
                Text('Re-login', style: Theme.of(context).textTheme.subtitle1),
            trailing: Icon(Icons.login),
            onTap: () {
              Get.to(() => LoginPage());
            },
          ),
          Divider(),
          ListTile(
            title: Text('Connect to Bluetooth',
                style: Theme.of(context).textTheme.subtitle1),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: _isBluetoothConnected
                  ? Text('Connected to $_connectedDeviceId')
                  : TextField(
                      controller: _bluetoothDeviceIdController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Bluetooth Device ID',
                        border: OutlineInputBorder(),
                        isDense: true, // Reduces padding
                      ),
                    ),
            ),
            isThreeLine: true,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: connectBluetooth,
              child: Text('Connect to Bluetooth'),
            ),
          ),
        ],
      ),
    );
  }

  void connectBluetooth() {
    // if (bluetoothInstance == null) {
    //   setOnNewSensorDataCallback(addSensorData);
    // }

    BluetoothConnect().scanForDevices('D9:A7:42:37:ED:C3',
        onConnectionChanged: (isConnected) {
      if (isConnected) {
        if (isConnected) {
          // Show notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bluetooth is connected'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  void disconnectBluetooth() {
    // Implement your disconnection logic here
    setState(() {
      _isBluetoothConnected = false;
      _connectedDeviceId = '';
    });
  }

  @override
  void dispose() {
    _bluetoothDeviceIdController.dispose();
    super.dispose();
  }
}
