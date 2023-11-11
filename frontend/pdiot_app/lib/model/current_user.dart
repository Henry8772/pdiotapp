import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser extends GetxController {
  static CurrentUser get instance => Get.find<CurrentUser>();

  var id = '0'.obs;
  var userFiles = <String>[];

  @override
  void onInit() {
    super.onInit();
    loadUserId();
  }

  Future<void> loadUserId() async {
    id.value = await Pref.getUserId();
    await loadUserFiles();
  }

  Future<void> loadUserFiles() async {
    List<String> allFiles = await Pref.getFileNames();
    userFiles =
        allFiles.where((file) => file.startsWith('${id.value}_')).toList();
  }

  void setId(String newId) {
    id.value = newId;
    Pref.saveUserId(newId);
    loadUserFiles();
  }

  Future<void> addFileName(String newFileName) async {
    // Add new file name to the SharedPreferences
    List<String> allFiles = await Pref.getFileNames();
    allFiles.add(newFileName);
    await Pref.saveFileNames(allFiles);

    // Update local userFiles list if the new file is related to the current user
    if (newFileName.startsWith('${id.value}_')) {
      userFiles.add(newFileName);
    }
  }
}

class Pref {
  // All the global settings variables
  static String userIdKey = 'userKey';
  static String fileNamesKey = 'fileNames'; // Key for the file names list
  static String defaultUserId = 'ef8ede37-9626-4912-8939-ec0a9e91873c';
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
