import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser extends GetxController {
  static CurrentUser get instance => Get.find<CurrentUser>();

  var id = '0'.obs;
  var username = 'NOT LOGIN-DEFAULT'.obs;
  var userFiles = <String>[];
  String bluetoothId = '';

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    id.value = await Pref.getUserId();
    username.value = await Pref.getUserName();
    bluetoothId = await Pref.getBluetoothID();
    await loadUserFiles();
  }

  Future<void> loadUserFiles() async {
    List<String> allFiles = await Pref.getFileNames();
    userFiles =
        allFiles.where((file) => file.startsWith('${id.value}-')).toList();
  }

  void setCurrentUser(String newId, String usernameParam) {
    id.value = newId;
    username.value = usernameParam;
    Pref.saveUserId(newId);
    Pref.saveUserName(usernameParam);
    loadUserFiles();
  }

  Future<void> addFileName(String newFileName) async {
    // Add new file name to the SharedPreferences
    List<String> allFiles = await Pref.getFileNames();
    allFiles.add(newFileName);
    await Pref.saveFileNames(allFiles);

    // Update local userFiles list if the new file is related to the current user
    if (newFileName.startsWith('${id.value}-')) {
      userFiles.add(newFileName);
    }
  }
}

class Pref {
  // All the global settings variables
  static String userIdKey = 'userKey';
  static String userNameKey = 'userNameKey';
  static String fileNamesKey = 'fileNames'; // Key for the file names list
  static String defaultUserId = '0';
  static String bluetoothIDKey = 'bluetoothKey';
  static String defaultBluetoothId = '__:__:__:__:__:__';
  static String defaultUserName = 'NOT LOGIN-DEFAULT';
  static ThemeData theme = ThemeData();

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

  static Future<void> saveBluetoothId(String bluetoothId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(bluetoothIDKey, bluetoothId);
  }

  // Load user ID from shared preferences
  static Future<String> getBluetoothID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(bluetoothIDKey) ?? defaultBluetoothId;
  }

  static Future<void> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userNameKey, userName);
  }

  // Load user ID from shared preferences
  static Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey) ?? defaultUserName;
  }

  // Save list of file names to shared preferences
  static Future<void> saveFileNames(List<String> fileNames) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(fileNamesKey, fileNames);
  }

  // Load list of file names from shared preferences
  static Future<List<String>> getFileNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(fileNamesKey) ?? [];
  }
}
