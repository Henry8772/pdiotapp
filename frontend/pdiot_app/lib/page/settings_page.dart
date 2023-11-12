import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _bluetoothDeviceIdController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text('Re-login'),
            trailing: Icon(Icons.login),
            onTap: () {
              // Add action to re-login
            },
          ),
          ListTile(
            title: Text('Connect to Bluetooth'),
            subtitle: TextField(
              controller: _bluetoothDeviceIdController,
              decoration: InputDecoration(
                labelText: 'Enter Bluetooth Device ID',
                border: OutlineInputBorder(),
              ),
            ),
            isThreeLine: true,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Add action to connect to Bluetooth with the device ID
                String deviceId = _bluetoothDeviceIdController.text;
                // Implement connection logic here
              },
              child: Text('Connect to Bluetooth'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bluetoothDeviceIdController.dispose();
    super.dispose();
  }
}
