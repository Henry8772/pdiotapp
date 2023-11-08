import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  String listToCsv(List<Float32List> list) {
    StringBuffer csvStringBuffer = StringBuffer();
    for (var floatList in list) {
      csvStringBuffer.writeln(floatList.join(','));
    }
    return csvStringBuffer.toString();
  }

  Future<void> saveCsv(List<Float32List> list, String fileName) async {
    String csvData = listToCsv(list);
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName.csv';
    File file = File(filePath);
    await file.writeAsString(csvData);
    print('Data saved to $filePath');
  }

  Future<List<Float32List>> parseCsv(String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName.csv';
    File file = File(filePath);
    String fileContent = await file.readAsString();
    List<String> lines = fileContent.split('\n');

    List<Float32List> list = lines.map((line) {
      List<String> strings = line.split(',');
      Float32List floats = Float32List(strings.length);
      for (int i = 0; i < strings.length; i++) {
        floats[i] = double.parse(strings[i]);
      }
      return floats;
    }).toList();

    return list;
  }
}
