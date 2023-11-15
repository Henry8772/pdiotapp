import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/page/activity_history_page.dart';

import 'package:pdiot_app/page/settings_page.dart';
import 'package:pdiot_app/utils/database_utils.dart';
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
  }

  @override
  void dispose() {
    notifyHelper.dispose();
    _pageController.dispose(); // Dispose of the controller
    super.dispose();
  }

  final pages = [
    // const LoginPage(),
    ActivitiHistoryPage(),
    HomePage(),
    // ChartPage(),

    SettingsPage(),
  ];

  final pageTitles = ["History", "Home", "Settings"];

  @override
  Widget build(BuildContext context) {
    return mainContent(context);
  }

  Future<bool> checkIfUserLoggedIn() async {
    await CurrentUser.instance.loadUser();
    if (CurrentUser.instance.username.value == 'NOT LOGIN-DEFAULT') {
      return false;
    } else {
      return true;
    }
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int index) => _pageController.jumpToPage(index),
        elevation: 0,
        selectedLabelStyle: TextStyle(color: Color(0xff666F83), fontSize: 12),
        unselectedLabelStyle: TextStyle(color: Color(0xff3E87F6), fontSize: 12),
        items: [
          BottomNavigationBarItem(
              label: 'Test',
              icon: Image.asset(
                  'assets/images/Test_${_currentIndex == 0 ? 1 : 0}.png',
                  width: 20)),
          BottomNavigationBarItem(
              label: 'Home',
              icon: Image.asset(
                  'assets/images/home_${_currentIndex == 1 ? 1 : 0}.png',
                  width: 20)),
          BottomNavigationBarItem(
              label: 'Setting',
              icon: Image.asset(
                  'assets/images/Setting_${_currentIndex == 2 ? 1 : 0}.png',
                  width: 20))
        ],
      ),
    );
  }
}
