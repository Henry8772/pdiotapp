import 'package:get/get.dart';
import '../model/current_user.dart';
import '../utils/database_utils.dart';

class LoginController extends GetxController {
  // Variables, and methods to manage the page's data and logic
  // DatabaseHelper databaseInstance = DatabaseHelper();

  void login(username, password) async {
    final users = await DatabaseHelper.getUsers();
    for (var user in users!) {
      if (user['username'] == username && user['password'] == password) {
        // Login successful
        print("User founds");
        CurrentUser.instance.setId(user['id'].toString());
        return;
      }
    }
    // Login failed
  }

  void register(username, password) async {
    int userId = await DatabaseHelper.insertUser({
      'username': username,
      'password': password,
    });
    CurrentUser.instance.setId(userId.toString());
    // User registered
  }
}
