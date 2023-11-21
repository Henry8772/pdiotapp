import 'dart:math';
import 'dart:typed_data';

import 'package:pdiot_app/utils/classification_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelType { task0, physical, task2, respiratory }

class CustomModel {
  static final CustomModel _singleton = CustomModel._internal();

  IsolateInterpreter? isolateInterpreter;
  ModelType _currentModelType = ModelType.task0;
  IsolateInterpreter? isolateInterpreterPhysical;
  IsolateInterpreter? isolateInterpreterRespiratory;

  bool modelLoaded = false;

  CustomModel._internal();

  factory CustomModel() {
    return _singleton;
  }

  final Map<ModelType, List<String>> labelLists = {
    ModelType.physical: physicalClasses,
    ModelType.task2: combinedClasses,
    ModelType.respiratory: respiratoryClasses,
  };

  ModelType getCurrentModel() {
    return _currentModelType;
  }

  // Function to check if a model is loaded

  bool isModelLoaded() {
    return modelLoaded;
  }

  // bool isModelLoaded(ModelType selectedModel) {
  //   return isolateInterpreter != null && _currentModelType == selectedModel;
  // }

  // Helper method to get the output shape based on model type
  getOutputList(ModelType? modelType) {
    switch (modelType) {
      case ModelType.physical:
        return List.filled(1 * 5, 0).reshape([1, 5]);
      case ModelType.task2:
        return List.filled(1 * 20, 0).reshape([1, 20]);
      case ModelType.respiratory:
        return List.filled(1 * 4, 0).reshape([1, 4]);
      default:
        return [1, 11]; // Default shape
    }
  }

  Future<bool> loadModel() async {
    // String physicalModelPath = 'assets/models/model_online_task_1.tflite';
    String physicalModelPath =
        'assets/models/model_online_task_1_5_class.tflite';
    String respiratoryModelPath =
        'assets/models/model_online_4CNN_3dense_4class_79_v2.tflite';
    // String respiratoryModelPath = 'assets/models/model_4_class_v1.tflite';

    try {
      // Load the physical model
      final physicalInterpreter =
          await Interpreter.fromAsset(physicalModelPath);
      isolateInterpreterPhysical =
          await IsolateInterpreter.create(address: physicalInterpreter.address);
      print('Physical model loaded successfully in isolate');

      // Load the respiratory model
      final respiratoryInterpreter =
          await Interpreter.fromAsset(respiratoryModelPath);
      isolateInterpreterRespiratory = await IsolateInterpreter.create(
          address: respiratoryInterpreter.address);
      print('Respiratory model loaded successfully in isolate');
      modelLoaded = true;

      return true;
    } catch (e) {
      print('Failed to load models in isolate: $e');
      return false;
    }
  }

  // Updated load model method
  // Future<bool> loadModel(ModelType modelType) async {
  //   String modelPath;

  //   switch (modelType) {
  //     case ModelType.physical:
  //       modelPath = 'assets/models/model_online_task_1.tflite';
  //       isolateInterpreterPhysical?.close();
  //       isolateInterpreterPhysical = null;
  //       break;
  //     case ModelType.respiratory:
  //       modelPath = 'assets/models/model_4_class_v1.tflite';
  //       isolateInterpreterRespiratory?.close();
  //       isolateInterpreterRespiratory = null;
  //       break;
  //     default:
  //       print('Model type not supported for isolated interpreter');
  //       return false;
  //   }

  //   try {
  //     final interpreter = await Interpreter.fromAsset(modelPath);
  //     var isolateInterpreter =
  //         await IsolateInterpreter.create(address: interpreter.address);
  //     if (modelType == ModelType.physical) {
  //       isolateInterpreterPhysical = isolateInterpreter;
  //     } else if (modelType == ModelType.respiratory) {
  //       isolateInterpreterRespiratory = isolateInterpreter;
  //     }
  //     print('Model $modelType loaded successfully in isolate');
  //     return true;
  //   } catch (e) {
  //     print('Failed to load the model in isolate: $e');
  //     return false;
  //   }
  // }

  Future<Map<ModelType, String>> performInference(
      List<Float32List> inputAccData,
      List<Float32List> inputGyroData,
      List<Float32List> inputAllData) async {
    Map<ModelType, String> results = {};

    if (isolateInterpreterPhysical != null) {
      var resultTask1 = await _performInferenceOnModel(
          ModelType.physical, isolateInterpreterPhysical!, inputAccData);
      results[ModelType.physical] = resultTask1;
    }

    if (isolateInterpreterRespiratory != null) {
      var resultTask3 = await _performInferenceOnModel(
          ModelType.respiratory, isolateInterpreterRespiratory!, inputGyroData);
      results[ModelType.respiratory] = resultTask3;
    }

    print(results);

    return results;
  }

  Future<String> _performInferenceOnModel(ModelType modelType,
      IsolateInterpreter interpreter, List<Float32List> inputData) async {
    print("$modelType Input is ${inputData.shape}");
    var output = getOutputList(modelType);

    await interpreter.run([inputData], output);
    print("$modelType Output is $output");
    List<double> data = output[0];
    int argMaxIndex = data
        .indexWhere((element) => element == data.reduce((a, b) => max(a, b)));

    if (argMaxIndex == -1) {
      return getDefaultReturnValue(modelType);
    } else {
      var currentLabelList = labelLists[modelType] ?? [];
      return currentLabelList.isNotEmpty
          ? currentLabelList[argMaxIndex]
          : getDefaultReturnValue(modelType);
    }
  }

  String getDefaultReturnValue(ModelType modelType) {
    switch (modelType) {
      case ModelType.physical:
        return 'Miscellaneous movements';
      case ModelType.respiratory:
        return 'Other';
      default:
        return 'Miscellaneous movements'; // Default for other model types
    }
  }

  // Updated perform inference method
  // Future<String> performInference(List<Float32List> inputAccData,
  //     List<Float32List> inputAllData, List<Float32List> inputGyroData) async {
  //   if (isolateInterpreter == null) {
  //     print('Model not loaded yet');
  //     return 'Error: Model not loaded';
  //   }

  //   List<List<Float32List>> finalInputData = [];

  //   // print(_currentModelType);

  //   if (_currentModelType == ModelType.task1) {
  //     finalInputData = [inputAccData];
  //   } else if (_currentModelType == ModelType.task3) {
  //     finalInputData = [inputGyroData];
  //   } else {
  //     finalInputData = [inputAllData];
  //   }

  //   List<double> data = output[0];
  //   // print(data);
  //   int argMaxIndex = data.indexWhere((element) => element == data.reduce(max));

  //   print(argMaxIndex);
  //   if (argMaxIndex == -1) {
  //     return 'Miscellaneous movements';
  //   } else {
  //     var currentLabelList = labelLists[_currentModelType] ?? [];

  //     return currentLabelList.isNotEmpty
  //         ? currentLabelList[argMaxIndex]
  //         : 'Miscellaneous movements';
  //   }

  //   // Retrieve the label list for the current model
  // }
}

// Extension method to flatten a list of lists
extension FlattenExtension<T> on List<List<T>> {
  List<T> flatten() => expand((x) => x).toList();
}
