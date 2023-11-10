import 'dart:ffi';
import 'dart:io';
import 'package:get/get.dart';
import 'package:pdiot_app/utils/file_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import '../model/current_user.dart';
import '../model/custom_model.dart';
import '../utils/database_utils.dart';

class LoginController extends GetxController {
  // Variables, and methods to manage the page's data and logic
  // DatabaseHelper databaseInstance = DatabaseHelper();
  @override
  void onReady() {
    super.onReady();
    // Perform any initialization that needs to happen when the controller is first created
  }

  void login(username, password) async {
    final users = await DatabaseHelper.getUsers();
    for (var user in users!) {
      if (user['username'] == username && user['password'] == password) {
        // Login successful
        print("User founds");
        CurrentUser.instance.setId(user['id'].toString());
        return;
      }
    }
    // Login failed
  }

  void register(username, password) async {
    int userId = await DatabaseHelper.insertUser({
      'username': username,
      'password': password,
    });
    CurrentUser.instance.setId(userId.toString());
    // User registered
  }
}
