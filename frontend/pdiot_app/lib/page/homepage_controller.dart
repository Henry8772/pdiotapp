import 'dart:io';
import 'dart:typed_data';
import '../model/custom_model.dart';

class MyPageController {
  // Variables, and methods to manage the page's data and logic

  String data = "Initial Data";
  late CustomModel model;

  void fetchData() {
    // Imagine this function fetches/updates data, then updates `data`.
    data = "Fetched Data";
    load();
  }

  Future<void> load() async {
    model = await CustomModel();
    await model.loadModel();
    List<List<dynamic>> csvData =
        await model.loadCsvData(); // your method that loads and parses CSV
    List<Float32List> inputData = await model.prepareData(csvData);
    String result = await model.performInference(inputData);
    // model.performInference([1]);
  }
}
// TODO Implement this library.