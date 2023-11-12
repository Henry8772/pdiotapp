import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/page/activity_history_page.dart';
import 'package:pdiot_app/page/chartpage.dart';
import 'package:pdiot_app/page/history_page.dart';
import 'package:pdiot_app/page/login_page.dart';
import 'package:pdiot_app/page/settings_page.dart';
import 'package:pdiot_app/utils/database_utils.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'model/current_user.dart';
import 'page/homepage.dart';

void main() {
  runApp(
    const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      home: MainPage(),
    ),
  );
  Get.put(CurrentUser());
  DatabaseHelper.initDatabase();
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var notifyHelper;

  final _pageController = PageController(initialPage: 1); // Moved to here
  var _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    // notifyHelper = NotifyHelper();
    // notifyHelper.initializeNotification();
    // notifyHelper.requestIOSPermissions();
  }

  @override
  void dispose() {
    notifyHelper.dispose();
    _pageController.dispose(); // Dispose of the controller
    super.dispose();
  }

  final pages = [
    const LoginPage(),
    HomePage(),
    // ChartPage(),
    ActivitiHistoryPage(),
    SettingsPage(),
  ];

  final pageTitles = ["Login", "Home", "History", "Settings"];

  @override
  Widget build(BuildContext context) {
    return mainContent(context);
  }

  Widget mainContent(BuildContext context) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    if (textScaleFactor < 1) {
      textScaleFactor = 1;
      // Maximum size before overruns SolomonBottomBar
    } else if (textScaleFactor > 1.3) {
      textScaleFactor = 1.3;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Real-time Motion prediciton")),
      body: PageView.builder(
        controller: _pageController, // Use the instance variable here
        onPageChanged: (int index) {
          setState(() => _currentIndex = index % pages.length);
        },
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return pages[index % pages.length];
        },
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (int index) => _pageController.jumpToPage(index),
        items: [
          /// Medication

          SalomonBottomBarItem(
            icon: const Icon(Icons.account_box),
            title: Text("Login", textScaleFactor: textScaleFactor),
            selectedColor: Colors.purple,
          ),

          /// Home

          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: Text("Home", textScaleFactor: textScaleFactor),
            selectedColor: Colors.purple,
          ),

          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: Text("Test", textScaleFactor: textScaleFactor),
            selectedColor: Colors.purple,
          ),

          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: Text("Settings", textScaleFactor: textScaleFactor),
            selectedColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
