import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'homepage_controller.dart'; // Import your controller

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // Instantiate the controller
  MyPageController _controller = Get.put(MyPageController()); //

  @override
  void initState() {
    super.initState();
    _controller.load(); // Loading the model when the widget is initialized.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Real-time Motion prediciton")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.buttonClicked(0);
                  });
                },
                child: const Text('Motion Data 1'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.connectBluetooth();
                  });
                },
                child: const Text('Bluetooth'),
              ),
              SizedBox(height: 20), // spacing between buttons
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.buttonClicked(1);
                  });
                },
                child: const Text('Motion Data 2'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.buttonClicked(2);
                  });
                },
                child: const Text('Motion Data 3'),
              ),
              Obx(() {
                // This will rebuild only this Text widget whenever _controller.output changes.
                return Text(
                    "Result: ${_controller.output.value}"); // .value is used to get the actual String from output
              }), // Use controller's data
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings))
        ]));
  }
}
