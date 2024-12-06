
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:test_app/connector/api_connector_auth.dart';
import 'package:test_app/models/user.dart';
import 'package:test_app/pages/root_page.dart';
import 'package:test_app/provider/user_provider.dart';


import 'package:test_app/utils/logger.dart';
import 'package:test_app/widgets/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var logger = MyLogger.getLogger();
  bool isLoading = false; // Loading state
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<int> signUserIn(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int result = 0;
    var body = {
      'username': usernameController.text,
      'password': passwordController.text,
    };
    // logger.d("body: $body");
    try {
      var response = await ApiServiceAuth().login(body, context);
      int statusCode = response['statusCode'];
      if (statusCode == 200 && mounted) {
        String accessToken = response["body"]['access_token'];
        String refreshToken = response["body"]['refresh_token'];

        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

        User tempUser = User(
            id: decodedToken["sub"],
            username: decodedToken["username"],
            email: decodedToken["email"],
            userType: decodedToken["user_type"],
            jwt: accessToken,
            jwtRefresh: refreshToken,
        );
        await userProvider.updateUser(tempUser);
        userProvider.user;
        showSnackBar('Willkommen, ${userProvider.user.username}!',
            duration: const Duration(seconds: 5));
        result = 1;
      } else if (statusCode == 401) {
        showSnackBar('Falsche E-Mail oder Passwort');
      } else {
        showSnackBar('statusCode: $statusCode');
        showSnackBar('Fehler: Anmeldung nicht erfolgreich');
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
    return result;
  }

  Future<void> handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar('Bitte füllen Sie alle Felder aus');
      return;
    } else if (usernameController.text == "test" &&
        passwordController.text == "test") {
      logger.d("UN and PW: test");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootPage()),
      );
    } else {
      setState(() {
        isLoading = true;
      });

      var result = await signUserIn(context);

      if (result == 1) {

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RootPage()),
          );
        }
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              //Fix for tilted mobile devices
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    /**SvgPicture.asset(
                      'images/logo.svg', // Path to your SVG file
                      width: 100, // Adjust the width as needed
                      height: 100, // Adjust the height as needed
                    ),*/
                    const SizedBox(height: 50),
                    Text(
                      'Willkommen! Bitte melden Sie sich an.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    const SizedBox(height: 25),
                    MyTextField(
                      controller: usernameController,
                      hintText: 'E-mail',
                      obscureText: false,
                      onSubmitted: (value) async {
                        await handleLogin(
                            context); // Ruft die Login-Logik bei Enter auf
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Passwort',
                      obscureText: true,
                      onSubmitted: (value) async {
                        await handleLogin(
                            context); // Ruft die Login-Logik bei Enter auf
                      },
                    ),
                    const SizedBox(height: 25),
                    isLoading
                        ? const CircularProgressIndicator() // Show loading indicator
                        : MyButton(
                            onTap: () async {
                              await handleLogin(context);
                            },
                          ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500])),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final Function()? onTap;

  const MyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Anmelden",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class SquareTile extends StatelessWidget {
  final String imagePath;
  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 40,
      ),
    );
  }
}
