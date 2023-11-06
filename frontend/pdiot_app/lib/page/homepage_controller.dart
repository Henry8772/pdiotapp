import 'dart:ffi';
import 'dart:io';
import 'package:get/get.dart';
import 'dart:typed_data';
import '../model/custom_model.dart';

class HomePageController extends GetxController {
  // Variables, and methods to manage the page's data and logic

  RxString output = "Waiting for result"
      .obs; // consider using RxString for reactive programming if you're using GetX.
  CustomModel? model; // Make model nullable

  @override
  void onReady() {
    super.onReady();
    // Perform any initialization that needs to happen when the controller is first created
    load();
  }

  Future<void> load() async {
    if (model == null) {
      // Correct null comparison
      model =
          await CustomModel(); // Assuming CustomModel's constructor is asynchronous
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
}
