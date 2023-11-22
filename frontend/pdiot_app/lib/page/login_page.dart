import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/main.dart';
import 'package:pdiot_app/page/login_controller.dart';

class LoginPage extends StatefulWidget {
  final bool fromSettings;

  LoginPage({Key? key, this.fromSettings = false}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = Get.put(LoginController()); //
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/大背景@3x.png'),
                fit: BoxFit.cover)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
                left: 31,
                top: 86,
                child: Text("Login / Register",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
            Positioned(
                top: 228,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 343,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 64,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    isLoginMode = true;
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: isLoginMode
                                            ? Color(0xffF6F6F6)
                                            : Colors.white),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: isLoginMode
                                                ? Radius.circular(16)
                                                : Radius.zero,
                                            bottomRight: !isLoginMode
                                                ? Radius.circular(16)
                                                : Radius.zero,
                                          ),
                                          color: !isLoginMode
                                              ? Color(0xffF6F6F6)
                                              : Colors.white),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Login",
                                            style: isLoginMode
                                                ? TextStyle(
                                                    color: Color(0xff0A84FF),
                                                    fontSize: 16)
                                                : TextStyle(
                                                    color: Color(0xff75818F),
                                                    fontSize: 16),
                                          ),
                                          if (isLoginMode)
                                            Container(
                                              width: 16,
                                              height: 2,
                                              decoration: BoxDecoration(
                                                  color: Color(0xff0A84FF),
                                                  borderRadius:
                                                      BorderRadius.circular(2)),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    isLoginMode = false;
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: !isLoginMode
                                            ? Color(0xffF6F6F6)
                                            : Colors.white),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: !isLoginMode
                                                ? Radius.circular(16)
                                                : Radius.zero,
                                            bottomLeft: isLoginMode
                                                ? Radius.circular(16)
                                                : Radius.zero,
                                          ),
                                          color: isLoginMode
                                              ? Color(0xffF6F6F6)
                                              : Colors.white),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Register",
                                            style: !isLoginMode
                                                ? TextStyle(
                                                    color: Color(0xff0A84FF),
                                                    fontSize: 16)
                                                : TextStyle(
                                                    color: Color(0xff75818F),
                                                    fontSize: 16),
                                          ),
                                          if (!isLoginMode)
                                            Container(
                                              width: 16,
                                              height: 2,
                                              decoration: BoxDecoration(
                                                  color: Color(0xff0A84FF),
                                                  borderRadius:
                                                      BorderRadius.circular(2)),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (isLoginMode) loginWidget(),
                        if (!isLoginMode) registerWidget(),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget loginWidget() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Username',
            style: titleStyle,
          ),
          SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: _usernameController,
              style: titleStyle,
              decoration: InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xffD7D8DB)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  fillColor: Color(0xffF4F5F6).withOpacity(0.8),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Password',
            style: titleStyle,
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: _passwordController,
              style: titleStyle,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                  hintText: 'Please enter password',
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xffD7D8DB)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  fillColor: Color(0xffF4F5F6).withOpacity(0.8),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none)),
            ),
          ),
          const SizedBox(
            height: 31,
          ),
          GestureDetector(
            onTap: login,
            child: Container(
              width: 319,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [
                    Color(0xff4A8DFF),
                    Color(0xff1D52FF),
                  ])),
              child: Text(
                'Login',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget registerWidget() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Username',
            style: titleStyle,
          ),
          SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: _usernameController,
              style: titleStyle,
              decoration: InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xffD7D8DB)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  fillColor: Color(0xffF4F5F6).withOpacity(0.8),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Password',
            style: titleStyle,
          ),
          SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 48,
            child: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: _passwordController,
              style: titleStyle,
              decoration: InputDecoration(
                  hintText: 'Please enter password',
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xffD7D8DB)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  fillColor: Color(0xffF4F5F6).withOpacity(0.8),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none)),
            ),
          ),
          SizedBox(
            height: 31,
          ),
          GestureDetector(
            onTap: register,
            child: Container(
              width: 319,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [
                    Color(0xff4A8DFF),
                    Color(0xff1D52FF),
                  ])),
              child: Text(
                'Register',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }

  void login() async {
    bool loginSuccess = await _controller.login(
        _usernameController.text, _passwordController.text);
    if (loginSuccess) {
      print("loginSuccess");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Success!'),
          backgroundColor: Colors.green,
        ),
      );

      onLoginRrgisterSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect username or password'),
          backgroundColor: Colors.red,
        ),
      );
// Show error message if login fails
    }
  }

  void onLoginRrgisterSuccess() {
    if (widget.fromSettings) {
      // Navigate back to the previous page
      Get.back();
    } else {
      // Navigate to MainPage and remove all previous routes
      Get.offAll(() => MainPage());
    }
  }

  void register() async {
    bool registerSuccess = await _controller.register(
        _usernameController.text, _passwordController.text);
    if (registerSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Register Success!'),
          backgroundColor: Colors.green,
        ),
      ); // Show success message
      // Optionally navigate back or to another page after showing the SnackBar
      onLoginRrgisterSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error happened'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  TextStyle titleStyle = TextStyle(
      fontWeight: FontWeight.w400, fontSize: 16, color: Color(0xff333333));

  // void register() async {
  //   bool loginSuccess = await _controller.login(
  //       _usernameController.text, _passwordController.text);
  //   if (loginSuccess) {
  //     Get.back(); // Navigate back if login is successful
  //   } else {
  //     Get.snackbar(
  //       'Error',
  //       'Incorrect username or password',
  //       snackPosition: SnackPosition.BOTTOM,
  //     ); // Show error message if login fails
  //   }
  // }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
