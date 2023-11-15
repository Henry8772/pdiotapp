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
  TextEditingController _bluetoothDeviceIdController = TextEditingController();
  bool _isBluetoothConnected = false;
  bool _isConnecting = false;
  String _connectedDeviceId = '';
  // String _enteredDeviceId = CurrentUser.instance.bluetoothId;

  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController with an initial value
    _bluetoothDeviceIdController =
        TextEditingController(text: CurrentUser.instance.bluetoothId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: Image.asset('assets/images/组 117@2x.png')),
          const Positioned(
            top: 54,
            left: 16,
            child: Text("Settings",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Positioned(top: 98, left: 16, right: 16, child: userCard()),
          Positioned(
            top: 240,
            left: 16,
            right: 16,
            child: bluetoothWidget(),
          )
        ],
      ),
    );
  }

  void connectBluetooth(String deviceId) {
    Pref.saveBluetoothId(deviceId);
    setState(() {
      _isConnecting = true;
    });
    BluetoothConnect().scanForDevices(deviceId,
        onConnectionChanged: (isConnected) {
      if (isConnected) {
        setState(() {
          _isBluetoothConnected = isConnected;
          _isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bluetooth is connected'),
            backgroundColor: Colors.green,
          ),
        );

        // Show notification
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

  Widget userCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      margin: const EdgeInsets.only(top: 20), // Added margin for spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        leading: const Icon(Icons.account_circle, size: 40.0),
        title: Obx(() => Text(
              CurrentUser.instance.username.value,
              maxLines: 1, // Ensures the text doesn't span more than one line
              overflow:
                  TextOverflow.ellipsis, // Adds an ellipsis if text is too long
              style: const TextStyle(
                color: Color(0xff333333),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Re-login',
              style: TextStyle(color: Color(0xff333333), fontSize: 18),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/切图 2.png',
              width: 20,
            ),
          ],
        ),
        onTap: () {
          Get.to(() => LoginPage());
        },
      ),
    );
  }

  Widget bluetoothWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect to Bluetooth',
            style: TextStyle(
              color: Color(0xff333333),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 48,
            child: TextFormField(
              controller: _bluetoothDeviceIdController,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xff333333)),
              decoration: InputDecoration(
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xffD7D8DB)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  fillColor: Color(0xffF4F5F6).withOpacity(0.8),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none)),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          GestureDetector(
            onTap: () {
              if (!_isBluetoothConnected && !_isConnecting) {
                connectBluetooth(_bluetoothDeviceIdController.text);
              }
              // connectBluetooth(_bluetoothDeviceIdController.text);
            },
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _isBluetoothConnected
                    ? LinearGradient(colors: [
                        Colors.green[400]!,
                        Colors.green[700]!
                      ]) // Gradient for "Connected" state
                    : LinearGradient(colors: [
                        Color(0xff4A8DFF),
                        Color(0xff1D52FF)
                      ]), // Original gradient
              ),
              child: Text(
                _isConnecting
                    ? 'Connecting Device'
                    : _isBluetoothConnected
                        ? 'Connected'
                        : 'Connect to RESpeck', // Text based on connection status
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
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
