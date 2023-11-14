import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelType { modelA, modelB, modelC }

class CustomModel {
  static final CustomModel _singleton = CustomModel._internal();

  IsolateInterpreter? isolateInterpreter;
  ModelType? _currentModelType;

  CustomModel._internal();

  factory CustomModel() {
    return _singleton;
  }

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

  // Updated load model method
  Future<void> loadModel(ModelType modelType) async {
    if (_currentModelType != modelType) {
      // Dispose of the existing model if a different type is requested
      isolateInterpreter?.close();
      isolateInterpreter = null;
      _currentModelType = modelType;

      String modelPath;
      switch (modelType) {
        case ModelType.modelA:
          modelPath = 'assets/models/model_cnn.tflite';
          break;
        case ModelType.modelB:
          modelPath = 'assets/models/model_cnn_b.tflite';
          break;
        case ModelType.modelC:
          modelPath = 'assets/models/model_cnn_c.tflite';
          break;
      }

      try {
        final interpreter = await Interpreter.fromAsset(modelPath);
        isolateInterpreter =
            await IsolateInterpreter.create(address: interpreter.address);
        print('Model $modelType loaded successfully in isolate');
      } catch (e) {
        print('Failed to load the model in isolate: $e');
      }
    }
  }

  // Updated perform inference method
  Future<String> performInference(List<Float32List> inputData) async {
    if (isolateInterpreter == null) {
      print('Model not loaded yet');
      return 'Error: Model not loaded';
    }

    List<List<Float32List>> finalInputData = [inputData];
    var output = List.filled(1 * 12, 0).reshape([1, 12]);

    await isolateInterpreter!.run(finalInputData, output);

    List<double> data = output[0];

    int argMaxIndex = 0;
    for (int i = 1; i < data.length; i++) {
      if (data[i] > data[argMaxIndex]) {
        argMaxIndex = i;
      }
    }
    return labelList[argMaxIndex];
  }
}
