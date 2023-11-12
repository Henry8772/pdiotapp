import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdiot_app/utils/ui_utils.dart';

import '../model/current_user.dart';

class FileUtils {
  static List<String> getUserDataTime(String day) {
    print(CurrentUser.instance.userFiles);
    List<String> dateSplit = day.split("-");

    return CurrentUser.instance.userFiles
        .map((file) => file.split('-'))
        .where((parts) =>
            parts.length > 4 &&
            parts[1] == dateSplit[0] && // Year
            parts[2] == dateSplit[1] && // Month
            parts[3] == dateSplit[2]) // Day
        .map((parts) => parts[4]) // Extracting the time part
        .where((timePart) => timePart.isNotEmpty)
        .toList();
  }

  static String listToCsv(List<Float32List> list) {
    StringBuffer csvStringBuffer = StringBuffer();
    list.asMap().forEach((index, floatList) {
      // Prepend the current index to each line
      String line = "$index,${floatList.join(',')}";
      csvStringBuffer.writeln(line);
    });
    return csvStringBuffer.toString();
  }

  static Future<String> getUserDirectoryPath() async {
    // Retrieve the application documents directory
    Directory appDocDir = await getApplicationDocumentsDirectory();

    // Assuming CurrentUser is a class with a static 'instance' property and 'id' field
    String userId = CurrentUser.instance.id.value;

    // Create a directory path for the user
    String userDirPath = '${appDocDir.path}/$userId';

    // Create the directory if it doesn't exist
    Directory userDir = Directory(userDirPath);
    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }

    return userDirPath;
  }

  static Future<void> saveCsv(List<Float32List> list) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd-kk:mm:ss').format(now);
    String csvData = listToCsv(list);

    String fileName = "${CurrentUser.instance.id.value}-$formattedDate";
    CurrentUser.instance.addFileName(fileName);

    // Get the user-specific directory path
    String userDirPath = await getUserDirectoryPath();

    // Create the file path inside the user's directory
    String filePath = '$userDirPath/$fileName.csv';

    // Save the CSV file in the user's directory
    File file = File(filePath);
    await file.writeAsString(csvData);
    print('Data saved to $filePath');
  }

  // static Future<List<Float32List>> parseCsv(String fileName) async {
  //   String userDirPath = await getUserDirectoryPath();
  //   String filePath = '$userDirPath/$fileName.csv';

  //   File file = File(filePath);
  //   try {
  //     String fileContent = await file.readAsString();
  //     List<String> lines =
  //         fileContent.split('\n').where((line) => line.isNotEmpty).toList();

  //     List<Float32List> list = lines.map((line) {
  //       List<String> strings = line.split(',');
  //       Float32List floats = Float32List(strings.length);
  //       for (int i = 0; i < strings.length; i++) {
  //         floats[i] =
  //             double.parse(strings[i].trim()); // Trim to remove any whitespace
  //       }
  //       return floats;
  //     }).toList();

  //     return list;
  //   } catch (e) {
  //     // Handle exceptions, like file read errors or parse errors
  //     print('Error reading or parsing file: $e');
  //     return []; // or rethrow the exception
  //   }
  // }

  static Future<List<SensorData>> parseCsv(String fileName) async {
    String userDirPath = await getUserDirectoryPath();
    String filePath = '$userDirPath/$fileName.csv';

    File file = File(filePath);
    try {
      String fileContent = await file.readAsString();
      List<String> lines =
          fileContent.split('\n').where((line) => line.isNotEmpty).toList();

      List<SensorData> sensorDataList = lines.map((line) {
        List<String> values = line.split(',');
        // Assuming the CSV format is: time, xAxis, yAxis, zAxis
        int time = int.parse(values[0].trim());
        double xAxis = double.parse(values[1].trim());
        double yAxis = double.parse(values[2].trim());
        double zAxis = double.parse(values[3].trim());

        return SensorData(time, xAxis, yAxis, zAxis);
      }).toList();

      return sensorDataList;
    } catch (e) {
      // Handle exceptions, like file read errors or parse errors
      print('Error reading or parsing file: $e');
      return []; // or rethrow the exception
    }
  }
}
