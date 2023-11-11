import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

import '../model/current_user.dart';

class FileUtils {
  static Future<List<String>> getFileMonths() async {
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

  static List<String> getUserDataTime() {
    return CurrentUser.instance.userFiles
        .map((file) => file.split('_'))
        .where((parts) => parts.length > 1)
        .map((parts) => parts[1])
        .map((dateTime) => dateTime.split('-'))
        .where((dateTimeParts) => dateTimeParts.length == 4)
        .map((dateTimeParts) {
          // Splitting the time part further to extract hours, minutes, and seconds
          List<String> timeParts = dateTimeParts[3].split(':');
          if (timeParts.length == 3) {
            return '${timeParts[0]}:${timeParts[1]}:${timeParts[2]}';
          } else {
            return '';
          }
        })
        .where((formattedDateTime) => formattedDateTime.isNotEmpty)
        .toList();
  }

  static DateTime parseDateFromFileName(String fileName) {
    // Adapted to match 'yyyy-MM-dd-kk:mm' format
    RegExp regExp = RegExp(r'\d{4}-\d{2}-\d{2}-\d{2}:\d{2}');
    String dateString = regExp.firstMatch(fileName)?.group(0) ?? '';
    return DateFormat('yyyy-MM-dd-kk:mm').parse(dateString);
  }

  static String listToCsv(List<Float32List> list) {
    StringBuffer csvStringBuffer = StringBuffer();
    for (var floatList in list) {
      csvStringBuffer.writeln(floatList.join(','));
    }
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

    String fileName = "${CurrentUser.instance.id.value}_$formattedDate";
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

  static Future<List<Float32List>> parseCsv(String fileName) async {
    // Get the user-specific directory path
    String userDirPath = await getUserDirectoryPath();

    // Create the file path inside the user's directory
    String filePath = '$userDirPath/$fileName.csv';

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
