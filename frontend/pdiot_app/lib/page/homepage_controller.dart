import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:pdiot_app/model/current_user.dart';
import 'package:pdiot_app/utils/database_utils.dart';
import '../model/custom_model.dart';

class HomePageController extends GetxController {
  // Variables, and methods to manage the page's data and logic
  bool isRecording = false;

  static const activities = [
    'Shuffle walking',
    'Lying down on stomach',
    'Ascending stairs',
    'Sitting/standing',
    'Running',
    'Lying down right',
    'Descending stairs',
    'Miscellaneous movements',
    'Normal walking',
    'Lying down on left',
    'Lying down back'
  ];

  RxString output = "Waiting for result"
      .obs; // consider using RxString for reactive programming if you're using GetX.
  CustomModel? model; // Make model nullable

  @override
  void onReady() {
    super.onReady();
    // Perform any initialization that needs to happen when the controller is first created
  }

  String getRandomActivity() {
    final random = Random();
    int randomIndex =
        random.nextInt(activities.length); // Generates a random index
    return activities[randomIndex]; // Returns the activity at the random index
  }

  Future<void> load() async {
    CustomModel().loadModel(ModelType.task1);
  }

  Future<bool> saveSessionToDatabase(
      Map<String, int> sessionDurations, DateTime startTime) async {
    int userId = int.parse(CurrentUser.instance.id.value);
    int sessionId = await DatabaseHelper.createNewSession(userId, startTime);

    sessionDurations.forEach((activityName, duration) async {
      int activityId = await DatabaseHelper.getActivityIdByName(
          activityName); // Get activity ID by name
      Map<String, dynamic> sessionActivity = {
        'sessionId': sessionId,
        'activityId': activityId,
        'duration': duration,
      };

      await DatabaseHelper.insertSessionActivity(sessionActivity);
    });

    return true;
  }
}
