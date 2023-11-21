import 'dart:math';
import 'dart:typed_data';

import 'package:pdiot_app/utils/classification_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelType { unloaded, physical, respiratory }

enum SubModelType { physical11, physical5, respiratory4 }

class CustomModel {
  static final CustomModel _singleton = CustomModel._internal();

  IsolateInterpreter? isolateInterpreter;
  ModelType _currentModelType = ModelType.unloaded;
  IsolateInterpreter? isolateInterpreterPhysical;
  IsolateInterpreter? isolateInterpreterRespiratory;

  bool modelLoaded = false;

  CustomModel._internal();

  factory CustomModel() {
    return _singleton;
  }

  final Map<SubModelType, List<String>> labelLists = {
    SubModelType.physical5: physicalClasses5,
    SubModelType.physical11: physicalClasses11,
    SubModelType.respiratory4: respiratoryClasses,
  };

  ModelType getCurrentModel() {
    return _currentModelType;
  }

  // Function to check if a model is loaded

  bool isModelLoaded(ModelType parameterModel) {
    return modelLoaded && parameterModel == _currentModelType;
  }

  // bool isModelLoaded(ModelType selectedModel) {
  //   return isolateInterpreter != null && _currentModelType == selectedModel;
  // }

  // Helper method to get the output shape based on model type
  getOutputList(SubModelType modelType) {
    switch (modelType) {
      case SubModelType.physical11:
        return List.filled(1 * 11, 0).reshape([1, 11]);
      case SubModelType.physical5:
        return List.filled(1 * 5, 0).reshape([1, 5]);
      case SubModelType.respiratory4:
        return List.filled(1 * 4, 0).reshape([1, 4]);
      default:
        return [1, 11]; // Default shape
    }
  }

  Future<bool> loadModel(ModelType modelType) async {
    String physicalModelPath11Class =
        'assets/models/model_online_task_1.tflite';
    String physicalModelPath5Class =
        'assets/models/model_online_task_1_5_class.tflite';
    String respiratoryModelPath =
        'assets/models/model_online_4CNN_3dense_4class_79_v2.tflite';

    _currentModelType = modelType;

    try {
      if (modelType == ModelType.physical) {
        // Load only the physical model
        final physicalInterpreter =
            await Interpreter.fromAsset(physicalModelPath11Class);
        isolateInterpreterPhysical = await IsolateInterpreter.create(
            address: physicalInterpreter.address);
        print('Physical 11 model loaded successfully in isolate');
      } else if (modelType == ModelType.respiratory) {
        // Load both physical and respiratory models
        final physicalInterpreter =
            await Interpreter.fromAsset(physicalModelPath5Class);
        isolateInterpreterPhysical = await IsolateInterpreter.create(
            address: physicalInterpreter.address);
        print('Physical 5 model loaded successfully in isolate');

        final respiratoryInterpreter =
            await Interpreter.fromAsset(respiratoryModelPath);
        isolateInterpreterRespiratory = await IsolateInterpreter.create(
            address: respiratoryInterpreter.address);
        print('Respiratory 4 model loaded successfully in isolate');
      }
      modelLoaded = true;
      return true;
    } catch (e) {
      print('Failed to load models in isolate: $e');
      return false;
    }
  }

  // Future<bool> loadModel() async {
  //   // String physicalModelPath = 'assets/models/model_online_task_1.tflite';
  //   String physicalModelPath =
  //       'assets/models/model_online_task_1_5_class.tflite';
  //   String respiratoryModelPath =
  //       'assets/models/model_online_4CNN_3dense_4class_79_v2.tflite';
  //   // String respiratoryModelPath = 'assets/models/model_4_class_v1.tflite';

  //   try {
  //     // Load the physical model
  //     final physicalInterpreter =
  //         await Interpreter.fromAsset(physicalModelPath);
  //     isolateInterpreterPhysical =
  //         await IsolateInterpreter.create(address: physicalInterpreter.address);
  //     print('Physical model loaded successfully in isolate');

  //     // Load the respiratory model
  //     final respiratoryInterpreter =
  //         await Interpreter.fromAsset(respiratoryModelPath);
  //     isolateInterpreterRespiratory = await IsolateInterpreter.create(
  //         address: respiratoryInterpreter.address);
  //     print('Respiratory model loaded successfully in isolate');
  //     modelLoaded = true;

  //     return true;
  //   } catch (e) {
  //     print('Failed to load models in isolate: $e');
  //     return false;
  //   }
  // }

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
      List<Float32List> inputAccData, List<Float32List> inputGyroData) async {
    Map<ModelType, String> results = {};

    if (isolateInterpreterPhysical != null) {
      SubModelType physicalModel = _currentModelType == ModelType.physical
          ? SubModelType.physical11
          : SubModelType.physical5;
      var resultTask1 = await _performInferenceOnModel(
          physicalModel, isolateInterpreterPhysical!, inputAccData);
      results[ModelType.physical] = resultTask1;
    }

    if (isolateInterpreterRespiratory != null) {
      var resultTask3 = await _performInferenceOnModel(
          SubModelType.respiratory4,
          isolateInterpreterRespiratory!,
          inputGyroData);
      results[ModelType.respiratory] = resultTask3;
    }

    return results;
  }

  Future<String> _performInferenceOnModel(SubModelType modelType,
      IsolateInterpreter interpreter, List<Float32List> inputData) async {
    var output = getOutputList(modelType);

    await interpreter.run([inputData], output);
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

  String getDefaultReturnValue(SubModelType modelType) {
    switch (modelType) {
      case SubModelType.physical11:
        return 'Miscellaneous movements';
      case SubModelType.physical5:
        return 'Sitting/standing';
      case SubModelType.respiratory4:
        return 'Sitting/standing';
      default:
        return 'Other'; // Default for other model types
    }
  }
}

// Extension method to flatten a list of lists
extension FlattenExtension<T> on List<List<T>> {
  List<T> flatten() => expand((x) => x).toList();
}
