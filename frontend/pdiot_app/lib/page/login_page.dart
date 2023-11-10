import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/page/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController _controller = Get.put(LoginController()); //
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => _controller.login(
                  _usernameController.text, _usernameController.text),
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => _controller.register(
                  _usernameController.text, _usernameController.text),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() {
    // Implement login logic
  }

  void _register() {
    // Implement register logic
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
