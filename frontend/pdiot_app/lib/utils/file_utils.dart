import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  Future<List<String>> getFileMonths() async {
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = directory.listSync();
    List<String> months = [];

    for (FileSystemEntity file in files) {
      if (file is File) {
        // Extract the date part from the filename
        String fileName = basename(file.path);
        DateTime fileDate = parseDateFromFileName(fileName);

        // Format the month and add to the list
        String month = DateFormat('MMMM').format(fileDate);
        months.add(month);
      }
    }
    return months;
  }

  DateTime parseDateFromFileName(String fileName) {
    // Adapted to match 'yyyy-MM-dd-kk:mm' format
    RegExp regExp = RegExp(r'\d{4}-\d{2}-\d{2}-\d{2}:\d{2}');
    String dateString = regExp.firstMatch(fileName)?.group(0) ?? '';
    return DateFormat('yyyy-MM-dd-kk:mm').parse(dateString);
  }

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
