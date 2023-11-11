import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/custom_model.dart';
import '../utils/bluetooth_utils.dart';
// import 'dart:io';

import '../utils/file_utils.dart';

class HistoryController extends GetxController {
  List<Float32List> accData = [];
  List<Float32List> gyroData = [];
  var date_time = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshDateTime();
  }

  void refreshDateTime() {
    date_time.value = FileUtils.getUserDataTime();
  }
}
