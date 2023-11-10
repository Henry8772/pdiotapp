import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser extends GetxController {
  static CurrentUser get instance => Get.find<CurrentUser>();

  var id = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserId();
  }

  Future<void> loadUserId() async {
    id.value = await Pref.getUserId();
  }

  void setId(String newId) {
    id.value = newId;
    Pref.saveUserId(newId);
  }
}

class Pref {
  // All the global settings variables
  static String userIdKey = 'userKey';
  static String defaultUserId = 'ef8ede37-9626-4912-8939-ec0a9e91873c';
  static ThemeData theme = ThemeData();

  static Future<void> loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  static Future<void> savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  // Save user ID to shared preferences
  static Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userIdKey, userId);
  }

  // Load user ID from shared preferences
  static Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey) ?? defaultUserId;
  }
}
