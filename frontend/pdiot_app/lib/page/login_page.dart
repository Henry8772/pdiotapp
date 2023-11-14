import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/page/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = Get.put(LoginController()); //
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                login();
                // _controller.login(
                //     _usernameController.text, _usernameController.text);
                // Get.back();
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () async {
                register();
                // _controller.register(
                //     _usernameController.text, _usernameController.text);
                // Get.back();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void login() async {
    bool loginSuccess = await _controller.login(
        _usernameController.text, _passwordController.text);
    if (loginSuccess) {
      print("loginSuccess");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Success!'),
          backgroundColor: Colors.green,
        ),
      );
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect username or password'),
          backgroundColor: Colors.red,
        ),
      );
// Show error message if login fails
    }
  }

  void register() async {
    bool registerSuccess = await _controller.register(
        _usernameController.text, _passwordController.text);
    if (registerSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Register Success!'),
          backgroundColor: Colors.green,
        ),
      ); // Show success message
      // Optionally navigate back or to another page after showing the SnackBar
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error happened'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // void register() async {
  //   bool loginSuccess = await _controller.login(
  //       _usernameController.text, _passwordController.text);
  //   if (loginSuccess) {
  //     Get.back(); // Navigate back if login is successful
  //   } else {
  //     Get.snackbar(
  //       'Error',
  //       'Incorrect username or password',
  //       snackPosition: SnackPosition.BOTTOM,
  //     ); // Show error message if login fails
  //   }
  // }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
