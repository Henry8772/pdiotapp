import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:pdiot_app/model/current_user.dart';
import 'package:pdiot_app/utils/database_utils.dart';
import 'dart:typed_data';
import '../model/custom_model.dart';
import '../utils/ui_utils.dart';

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
  ]; // Ad

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
    if (model == null) {
      // Correct null comparison
      model =
          CustomModel(); // Assuming CustomModel's constructor is asynchronous
      await model!
          .loadModel(); // model is nullable, so we should use the null-aware operator (!.)
    }
  }

  Future<void> buttonClicked(int ind) async {
    if (model == null) {
      // handle the case where the model might not be loaded yet
      print('Model not loaded yet');
      load();
    }
    output.value = 'Predicting';

    List<List<dynamic>> csvData =
        await model!.loadCsvData(ind); // Using the null-aware operator
    List<Float32List> inputData = await model!.prepareData(csvData);

    String result = await model!.performInference(inputData);

    output.value =
        result; // If you're using RxString, you should set its value like this.
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
