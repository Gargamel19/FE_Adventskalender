
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_app/pages/login_screen.dart';
import 'package:test_app/provider/user_provider.dart';
import 'package:test_app/utils/logger.dart';
import 'package:test_app/widgets/snackbar.dart';

const String _releaseDate = String.fromEnvironment('release_date', defaultValue: '');
const String _environment = String.fromEnvironment('environment', defaultValue: '');
const String _platform = String.fromEnvironment('platform', defaultValue: '');
const String _appVersion = String.fromEnvironment('app_version', defaultValue: '');
const String _apiVersion = String.fromEnvironment('api_version', defaultValue: '');

bool loggedIn = false;

String getReleaseDate(){
  return _releaseDate.isNotEmpty? _releaseDate: dotenv.env["release_date"] ?? "1.1.1997";
}

String getEnvironment(){
  return _environment.isNotEmpty? _environment: dotenv.env["environment"] ?? "development";
}

String getPlatform(){
  return _platform.isNotEmpty? _platform: dotenv.env["platform"] ?? "desktop";
}

String getAppVersion(){
  return _appVersion.isNotEmpty? _appVersion: dotenv.env["app_version"] ?? "1.0";
}

String getApiVersion(){
  return _apiVersion.isNotEmpty? _apiVersion: dotenv.env["api_version"] ?? "1.1.0";
}

void quitAppWithDelay(BuildContext context) {
    const snackBar = SnackBar(
      content: Text(
          'Version veraltet, die App wird in 30 Sekunden geschlossen. Bitte starten Sie die App neu.'),
      duration: Duration(seconds: 30), // Set the duration here
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // Display a message before exiting
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // Set a delay before quitting the app
    Future.delayed(const Duration(seconds: 30), () async {
      // For iOS or any platform
      quitApp();
    });
  }

  void quitApp() async {
    final logger = MyLogger.getLogger();
    // For iOS or any platform
    if (Platform.isWindows) {
      logger.d('Quitting app');
      exit(0);
    }
  }

  handleLogout(BuildContext context) async {
    try {
      await UserProvider().clearUser();
      // Show success message or handle result
      if (context.mounted && loggedIn) {
        loggedIn = false;
        showSnackBar("Erfolgreich abgemeldet");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      showSnackBar('Fehler bei Abmeldung');
      //var message = ("Error in logout: $e\n$s");
    }
  }


Map<String, dynamic> handleAPIResponse(int statusCode, BuildContext context, Function callback, dynamic response) {
    final logger = MyLogger.getLogger();
    var res = {};
    try {
      var res = jsonDecode(response.body);
      switch (statusCode) {
        case 200 || 201:
          return {
            'statusCode': statusCode,
            'body': callback(),
          };
        case 409:
          logger.d(statusCode);
          quitAppWithDelay(context);
          showSnackBar('${res.description}');
          break;
        case 401 || 422:
          //does'nt exist as response in the backend
          logger.d("Dead JWT");
          //showSnackBar('Benutzer-Sitzung abgelaufen, bitte neu anmelden.');
          handleLogout(context);
          break;
        case 502:
          logger.d("Server Error");
          showSnackBar('Server Error');
          break;
        default:
          logger.d("Status Code: $statusCode Message: ${response.body}");
          break;
      }
    } on TypeError catch (e) {
      logger.d(e);
      //var message = ("Error in handleAPIResponse: $e\n$s");
      showSnackBar("Fehler bei API Aufruf");
    } catch (e) {
      //var message = ("Error in handleAPIResponse: $e\n$s");
      showSnackBar("Fehler bei API Aufruf");
    }
    return {'statusCode': statusCode, 'body': res};
  }


Future<Map<String, String>> getHeaders() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? jwt = await secureStorage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
      'X-App-Version':  getApiVersion(),
    };
  }

  Future<String> getBaseUrl() async {
    if (!Platform.isWindows) {
      return 'http://10.0.2.2:5000';
    }else{
      return 'http://127.0.0.1:5000';
    }
  }