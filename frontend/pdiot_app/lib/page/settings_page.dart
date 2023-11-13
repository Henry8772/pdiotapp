import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/model/current_user.dart';
import 'package:pdiot_app/page/login_page.dart';

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
              child: TextField(
                controller: _bluetoothDeviceIdController,
                decoration: InputDecoration(
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
                primary: Theme.of(context).primaryColor, // Theme-based color
                padding: EdgeInsets.symmetric(vertical: 12.0),
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                String deviceId = _bluetoothDeviceIdController.text;
                // Bluetooth connection logic
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
