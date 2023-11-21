import 'package:get/get.dart';
// import 'package:pdiot_app/model/current_user.dart';
// import 'package:pdiot_app/utils/database_utils.dart';
import '../model/custom_model.dart';

class HomePageController extends GetxController {
  // Variables, and methods to manage the page's data and logic
  bool isRecording = false;

  RxString output = "Waiting for result"
      .obs; // consider using RxString for reactive programming if you're using GetX.
  CustomModel? model; // Make model nullable

  @override
  void onReady() {
    super.onReady();
    // Perform any initialization that needs to happen when the controller is first created
  }

  // String getRandomActivity() {
  //   final random = Random();
  //   int randomIndex =
  //       random.nextInt(activities.length); // Generates a random index
  //   return activities[randomIndex]; // Returns the activity at the random index
  // }
}
