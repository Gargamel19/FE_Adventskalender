import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:test_app/connector/api_connector_auth.dart';
import 'package:test_app/pages/login_screen.dart';
import 'package:test_app/pages/root_page.dart';
import 'package:test_app/provider/calender_provider.dart';
import 'package:test_app/provider/user_provider.dart';
import 'package:test_app/states/app_state.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test_app/utils/error_handler.dart';
import 'package:test_app/utils/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  ErrorHandler errorHandler = ErrorHandler();

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    errorHandler.initialize();

    await MyLogger.initLogger();
    await initializeProviders();
    await dotenv.load(fileName: ".env");

    if (Platform.isWindows) {
      WindowManager.instance.setMinimumSize(const Size(430, 700));
    }

    logger.d('App started, environment: dev');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(ChangeNotifierProvider(
              create: (context) => AppState(),
              child: const MainApp(),
            )));
  }, (error, stackTrace) {
    errorHandler.log(error, stackTrace);
  });
}

final navigatorKey = GlobalKey<NavigatorState>();

// Secure storage instance for JWT
const storage = FlutterSecureStorage();

Future<void> initializeProviders() async {
  var userProvider = UserProvider();
  await userProvider.readFromSecureStorage();
  CalenderProvider();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();


class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://flutter.dev'),
      ); // error when instantiating the WebViewController in Windows app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView'),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}


class MainApp extends StatelessWidget {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CalenderProvider()),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        navigatorKey: navigatorKey,
        title: 'Adventskalender',
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[350],
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: const TextTheme(
            displayMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(fontSize: 14),
            bodySmall: TextStyle(
              fontSize: 12,
            ),
            titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontSize: 9),
          ),
        ),
        home: const LoginCheck(),
      ),
    );
  }
}


class LoginCheck extends StatefulWidget {
  const LoginCheck({super.key});

  @override
  State<LoginCheck> createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {
  bool _isUserLoggedIn = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  _checkLogin() async {
    // Check if JWT exists in secure storage and if JWT is expired
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.readFromSecureStorage();
    String jwt = userProvider.user.jwt;
    if (jwt == "test") {
      setState(() {
        _isUserLoggedIn = false;
        _initialized = true;
      });
    } else {
      try {
        var decodedJWT = JwtDecoder.decode(jwt);
        DateTime exp =
            DateTime.fromMillisecondsSinceEpoch(decodedJWT["exp"] * 1000);
        DateTime localTime = DateTime.now().toLocal();
        bool expired = localTime.isAfter(exp);
        if (expired) {
          Map<String, dynamic> response = await ApiServiceAuth()
              .refresh(userProvider.user.jwtRefresh, context);
          if (response["statusCode"] == 200) {
            jwt = response["body"]["access_token"];
            userProvider.user.setTokens(jwt, response["body"]["refresh_token"]);
            await userProvider.writeToSecureStorage(userProvider.user);
            setState(() {
              _isUserLoggedIn = true; // If JWT exists, consider user logged in
            });
          }
        } else {
          setState(() {
            _isUserLoggedIn = (jwt != "test" &&
                !expired); // If JWT exists, consider user logged in
          });
        }
      } catch (e) {
        setState(() {
          _isUserLoggedIn = false;
        });
      }

      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    HttpOverrides.global = MyHttpOverrides();
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isUserLoggedIn ? const RootPage() : const LoginScreen();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Bypass SSL verification only for the specified trusted host
        return true;//host ==
            //'127.0.0.1'; // Replace with your trusted host
      };
  }
}