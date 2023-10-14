import 'package:flutter/material.dart';
import 'homepage_controller.dart'; // Import your controller

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // Instantiate the controller
  MyPageController _controller = MyPageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_controller.data), // Use controller's data
            ElevatedButton(
              onPressed: () {
                // Use controller's logic, and refresh UI
                setState(() {
                  _controller.fetchData();
                });
              },
              child: Text("Fetch Data"),
            ),
          ],
        ),
      ),
    );
  }
}
