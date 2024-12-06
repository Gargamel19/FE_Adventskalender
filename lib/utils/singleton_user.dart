
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';
import 'package:test_app/models/user.dart';

class SecureFunctionSingleton {
  static final SecureFunctionSingleton _instance = SecureFunctionSingleton._internal();
  final _lock = Lock();
  final storage = const FlutterSecureStorage();

  SecureFunctionSingleton._internal();

  factory SecureFunctionSingleton() {
    return _instance;
  }

  // 1. Gesicherte Schreibfunktion mit Timeout
  writeData(User user) async {
    await _lock.synchronized(() async {
      
      await storage.write(key: "id", value: user.id.toString());
      await storage.write(key: "username", value: user.username);
      await storage.write(key: "email", value: user.email);
      await storage.write(key: "userType", value: user.userType.toString());
      await storage.write(key: "jwt", value: user.jwt);
      await storage.write(key: "jwtRefresh", value: user.jwtRefresh);
      await storage.write(key: "lastLogin", value: user.lastLogin);
      await storage.write(key: "latestUpdate", value: user.latestUpdate);

    }, timeout: const Duration(seconds: 2)).catchError((e) {
      print("ERROR ON WRITING DATA: $e");
    });

  }

  // 2. Gesicherte Lesefunktion mit Timeout
  Future<User> readData() async {

    User user = User(
      id: "-1",
      username: "test",
      email: "test@test.com",
      userType: 0,
      jwt: "test",
      jwtRefresh: "test",
      lastLogin: "",
      latestUpdate: "",
      );

    try {
      user = await _lock.synchronized(() async {
        return User(
          id: await storage.read(key: "id") as String,
          username: (await storage.read(key: "username")) as String,
          email: (await storage.read(key: "email")) as String,
          userType: int.parse((await storage.read(key: "userType")) as String),
          jwt: (await storage.read(key: "jwt")) as String,
          jwtRefresh: (await storage.read(key: "jwtRefresh")) as String,
          lastLogin: (await storage.read(key: "lastLogin")) as String,
          latestUpdate: (await storage.read(key: "latestUpdate")) as String);
      }, timeout: const Duration(seconds: 4)).catchError((e) {
        print("ERROR ON READING DATA: $e");
        return user;
      });
    } catch (e) {
      print("ERROR ON READING DATA: $e");
      return user;
    }
    return user;
  }
}
