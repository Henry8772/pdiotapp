import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'homepage_controller.dart'; // Import your controller

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instantiate the controller
  HomePageController _controller = Get.put(HomePageController()); //

  @override
  void initState() {
    super.initState();
    _controller.load(); // Loading the model when the widget is initialized.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    ));
  }
}
