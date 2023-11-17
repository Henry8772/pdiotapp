import 'dart:math';
import 'dart:typed_data';

import 'package:pdiot_app/utils/classification_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelType { task1, task2, task3 }

class CustomModel {
  static final CustomModel _singleton = CustomModel._internal();

  IsolateInterpreter? isolateInterpreter;
  ModelType? _currentModelType;

  CustomModel._internal();

  factory CustomModel() {
    return _singleton;
  }

  final Map<ModelType, List<String>> labelLists = {
    ModelType.task1: physicalClasses,
    ModelType.task2: [
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

      // Labels specific to Model B
    ],
    ModelType.task3: [
      // Labels specific to Model C
    ],
  };

  // Function to check if a model is loaded
  bool isModelLoaded(ModelType selectedModel) {
    return isolateInterpreter != null && _currentModelType == selectedModel;
  }

  // Helper method to get the output shape based on model type
  List<int> getOutputShape(ModelType? modelType) {
    switch (modelType) {
      case ModelType.task1:
        return [1, 11]; // Example shape for model A
      case ModelType.task2:
        return [1, 12]; // Example shape for model B
      case ModelType.task3:
        return [1, 16]; // Example shape for model C
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
          modelPath = 'assets/models/model_cnn.tflite';
          break;
        case ModelType.task3:
          modelPath = 'assets/models/model_cnn.tflite';
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
  Future<String> performInference(List<Float32List> inputData) async {
    if (isolateInterpreter == null) {
      print('Model not loaded yet');
      return 'Error: Model not loaded';
    }

    List<List<Float32List>> finalInputData = [inputData];
    var outputShape = getOutputShape(_currentModelType);
    var output = List.filled(outputShape.reduce((a, b) => a * b), 0)
        .reshape(outputShape);

    await isolateInterpreter!.run(finalInputData, output);

    List<double> data = output.flatten();
    int argMaxIndex = data.indexWhere((element) => element == data.reduce(max));
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
