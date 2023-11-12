// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:pdiot_app/model/current_user.dart';
// import 'package:pdiot_app/utils/ui_utils.dart';
// import '../model/custom_model.dart';
// import '../utils/bluetooth_utils.dart';
// // import 'dart:io';

// import '../utils/file_utils.dart';

// class HistoryController extends GetxController {
//   List<SensorData> accData = [];
//   List<Float32List> gyroData = [];
//   var date_time = <String>[].obs;
//   var current_day = <String>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//   }

//   void changeSelectedDay(DateTime day) {
//     String formattedDate = DateFormat('yyyy-MM-dd').format(day);
//     date_time.value = FileUtils.getUserDataTime(formattedDate);
//   }

//   void refreshDateTime() {
//     DateTime now = DateTime.now();
//     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

//     date_time.value = FileUtils.getUserDataTime(formattedDate);
//   }

//   Future<bool> loadData(int ind) async {
//     if (date_time.length > 0) {
//       DateTime now = DateTime.now();
//       String formattedDate = DateFormat('yyyy-MM-dd').format(now);
//       String filename =
//           "${CurrentUser.instance.id + "-"}$formattedDate-${date_time[ind]}";
//       accData = await FileUtils.parseCsv(filename);

//       return true;
//     } else {
//       accData = [];
//       gyroData = [];
//       return false;
//     }
//   }
// }
