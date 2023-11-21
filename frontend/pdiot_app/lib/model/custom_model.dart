import 'dart:math';
import 'dart:typed_data';

import 'package:pdiot_app/utils/classification_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelType { task0, task1, task2, task3 }

class CustomModel {
  static final CustomModel _singleton = CustomModel._internal();

  IsolateInterpreter? isolateInterpreter;
  ModelType _currentModelType = ModelType.task0;

  CustomModel._internal();

  factory CustomModel() {
    return _singleton;
  }

  final Map<ModelType, List<String>> labelLists = {
    ModelType.task1: physicalClasses,
    ModelType.task2: combinedClasses,
    ModelType.task3: respiratoryClasses,
  };

  ModelType getCurrentModel() {
    return _currentModelType;
  }

  // Function to check if a model is loaded

  bool isModelLoaded(ModelType selectedModel) {
    return isolateInterpreter != null && _currentModelType == selectedModel;
  }

  // Helper method to get the output shape based on model type
  getOutputList(ModelType? modelType) {
    switch (modelType) {
      case ModelType.task1:
        return List.filled(1 * 11, 0).reshape([1, 11]);
      case ModelType.task2:
        return List.filled(1 * 20, 0).reshape([1, 20]);
      case ModelType.task3:
        return List.filled(1 * 4, 0).reshape([1, 4]);
      default:
        return [1, 11]; // Default shape
    }
  }

  // Updated load model method
  Future<bool> loadModel(ModelType modelType) async {
    if (_currentModelType != modelType) {
      // Dispose of the existing model if a different type is requested
      isolateInterpreter?.close();
      isolateInterpreter = null;
      _currentModelType = modelType;

      String modelPath;
      switch (modelType) {
        case ModelType.task1:
          modelPath = 'assets/models/model_online_task_1.tflite';
          break;
        case ModelType.task2:
          // modelPath = 'assets/models/model_task23.tflite';
          modelPath = 'assets/models/model_online_3CNN_2dense_74.tflite';
          break;
        case ModelType.task3:
          modelPath = 'assets/models/model_4_class_v1.tflite';
          break;
        case ModelType.task0:
          modelPath = 'assets/models/model_online_task_1.tflite';
          break;
      }

      try {
        final interpreter = await Interpreter.fromAsset(modelPath);
        isolateInterpreter =
            await IsolateInterpreter.create(address: interpreter.address);
        print('Model $modelType loaded successfully in isolate');
        return true;
      } catch (e) {
        print('Failed to load the model in isolate: $e');
        return false;
      }
    }
    return false;
  }

  // Updated perform inference method
  Future<String> performInference(List<Float32List> inputAccData,
      List<Float32List> inputAllData, List<Float32List> inputGyroData) async {
    if (isolateInterpreter == null) {
      print('Model not loaded yet');
      return 'Error: Model not loaded';
    }

    List<List<Float32List>> finalInputData = [];

    // print(_currentModelType);

    if (_currentModelType == ModelType.task1) {
      finalInputData = [inputAccData];
    } else if (_currentModelType == ModelType.task3) {
      finalInputData = [inputGyroData];
    } else {
      finalInputData = [inputAllData];
    }

    // print(finalInputData.length);
    // print(finalInputData[0].length);
    // print(finalInputData.shape);

    // print(outputShape);

    var output = getOutputList(_currentModelType);

    // if (_currentModelType == ModelType.task1) {
    //   output = List.filled(outputShape.reduce((a, b) => a * b), 0)
    //       .reshape(outputShape);
    // } else if (_currentModelType == ModelType.task2) {
    //   output = List.filled(1 * 20, 0).reshape([1, 20]);
    // } else {
    //   output = List.filled(1 * 26, 0).reshape([1, 26]);
    // }

    await isolateInterpreter!.run(finalInputData, output);
    // print(output);

    List<double> data = output[0];
    // print(data);
    int argMaxIndex = data.indexWhere((element) => element == data.reduce(max));

    print(argMaxIndex);
    if (argMaxIndex == -1) {
      return 'Miscellaneous movements';
    } else {
      var currentLabelList = labelLists[_currentModelType] ?? [];

      return currentLabelList.isNotEmpty
          ? currentLabelList[argMaxIndex]
          : 'Miscellaneous movements';
    }

    // Retrieve the label list for the current model
  }
}

// Extension method to flatten a list of lists
extension FlattenExtension<T> on List<List<T>> {
  List<T> flatten() => expand((x) => x).toList();
}
