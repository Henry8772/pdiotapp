import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'package:csv/csv.dart';
import 'dart:convert';

class CustomModel {
  Interpreter? interpreter;
  late Delegate delegate;

  List<String> labelList = [
    'Miscellaneous movements',
    'Lying down right',
    'Descending stairs',
    'Lying down back',
    'Lying down on left',
    'Lying down on stomach',
    'Shuffle walking',
    'Lying down right',
    'Lying down back',
    'Sitting',
    'Standing',
    'Lying down on stomach'
  ];

  List<String> motionList = [
    'assets/data/Respeck_s2029523_Ascending stairs_Normal_clean_30-09-2023_22-05-37.csv',
    'assets/data/Respeck_s2029523_Lying down back_Coughing_clean_30-09-2023_21-25-30.csv',
    'assets/data/Respeck_s2029523_Sitting_Normal_unprocessed_30-09-2023_20-52-23.csv'
  ];
  // IsolateInterpreter? isolateInterpreter;

  // Function to load the model
  Future<void> loadModel() async {
    // This bundling is done via the flutter assets

    try {
      // Creating the interpreter using the Interpreter.fromAsset constructor
      // delegate = GpuDelegateV2(
      //   options: GpuDelegateOptionsV2(
      //     isPrecisionLossAllowed: false,
      //     inferencePriority1: TfLiteGpuInferencePriority.minLatency,
      //     inferencePriority2: TfLiteGpuInferencePriority.auto,
      //     inferencePriority3: TfLiteGpuInferencePriority.auto,
      //   ),
      // );
      // var interpreterOptions = InterpreterOptions()..addDelegate(delegate);
      interpreter = await Interpreter.fromAsset(
        'models/model_online.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      interpreter?.allocateTensors();
      // Create interpreter options

      // Add the Flex delegate

      // isolateInterpreter =
      // await IsolateInterpreter.create(address: interpreter!.address);
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load the model: $e');
    }
  }

  Future<List<List<dynamic>>> loadCsvData(int ind) async {
    // Adjust the path to your CSV file as needed
    final String data = await rootBundle.loadString(motionList[ind]);

    // Parse the CSV data
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(data, eol: "\n");

    List<List<dynamic>> extractedData = rowsAsListOfValues.map((row) {
      return [row[1], row[2], row[3]]; // Selecting the specific columns
    }).toList();
    return extractedData;
  }

  // Future<List<Float32List>> prepareData(List<List<dynamic>> csvData) async {
  //   // Select only the first 700 rows if there are more
  //   List<List<dynamic>> selectedRows =
  //       csvData.length > 700 ? csvData.sublist(1, 700 + 1) : csvData;

  //   // Check if there are enough rows in the CSV data.
  //   if (selectedRows.length != 700) {
  //     throw Exception(
  //         'Not enough data rows. Expected at least 700 rows of data.');
  //   }

  //   // Convert the CSV data into a flat list of doubles since the model input should be a Float32List.
  //   List<Float32List> flatList = [];
  //   for (var row in selectedRows) {
  //     // Each row is expected to have exactly 3 columns.
  //     if (row.length != 3) {
  //       throw Exception('Expected exactly 3 columns for each row of data.');
  //     }
  //     List<double> tmpflatList = [];

  //     for (var value in row) {
  //       // Attempt to convert each value to a double and add it to the flat list.
  //       try {
  //         tmpflatList.add(double.parse(value.toString()));
  //       } catch (error) {
  //         throw Exception('Error in converting value to double: $error');
  //       }
  //     }
  //     Float32List inputAsFloat32List = Float32List.fromList(tmpflatList);
  //     flatList.add(inputAsFloat32List);
  //   }

  //   // The TensorFlow Lite interpreter expects a Float32List.

  //   return flatList;
  // }

  Future<List<Float32List>> prepareData(List<List<dynamic>> csvData) async {
    // Select only the first 700 rows if there are more
    List<List<dynamic>> selectedRows =
        csvData.length > 50 ? csvData.sublist(1, 50 + 1) : csvData;

    // Check if there are enough rows in the CSV data.
    if (selectedRows.length != 50) {
      throw Exception(
          'Not enough data rows. Expected at least 700 rows of data.');
    }

    // Convert the CSV data into a flat list of doubles since the model input should be a Float32List.
    List<Float32List> flatList = [];
    for (var row in selectedRows) {
      // Each row is expected to have exactly 3 columns.
      if (row.length != 3) {
        throw Exception('Expected exactly 3 columns for each row of data.');
      }
      List<double> tmpflatList = [];

      for (var value in row) {
        // Attempt to convert each value to a double and add it to the flat list.
        try {
          tmpflatList.add(double.parse(value.toString()));
        } catch (error) {
          throw Exception('Error in converting value to double: $error');
        }
      }
      Float32List inputAsFloat32List = Float32List.fromList(tmpflatList);
      flatList.add(inputAsFloat32List);
    }

    // The TensorFlow Lite interpreter expects a Float32List.

    return flatList;
  }

  // Function to perform inference
  Future<String> performInference(List<Float32List> inputData) async {
    if (interpreter == null) {
      print('Model not loaded yet');
    }

    // The shape of your input data depends on your model. Adjust accordingly.
    var inputShape = interpreter!.getInputTensor(0).shape;
    var inputType = interpreter!.getInputTensor(0).type;
    print(inputShape);

    List<List<Float32List>> finalInputData = [inputData];
    print(finalInputData.shape);
    print(finalInputData);

    // // Depending on your model, you need to adjust the following parameters:
    var outputSize = interpreter!.getOutputTensor(0).shape;

    // print(outputSize);
    // Create a container for the result.
    var output = List.filled(1 * 12, 0).reshape([1, 12]);

    interpreter!.run(inputData, output);

    // Extracting the first row since the shape is [1, 12], we only have one row
    List<double> data = output[0];

    int argMaxIndex = 0; // start with the initial index

    for (int i = 1; i < data.length; i++) {
      if (data[i] > data[argMaxIndex]) {
        argMaxIndex = i; // update with the new index if a larger value is found
      }
    }
    return labelList[argMaxIndex]; // this output can be post-
  }
}
