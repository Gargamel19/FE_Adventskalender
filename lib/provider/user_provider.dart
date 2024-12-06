import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:test_app/connector/api_connector_auth.dart';
import 'package:test_app/models/user.dart';
import 'package:test_app/utils/logger.dart';
import 'package:test_app/utils/singleton_user.dart';
import 'package:test_app/utils/utils.dart';

class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();
  final storage = const FlutterSecureStorage();
  
  int page = 0;

  SecureFunctionSingleton singletonUser = SecureFunctionSingleton();

  User _user = User(
      id: "-1",
      username: "test",
      email: "test@test.com",
      userType: 0,
      );

  // Private constructor
  UserProvider._internal();

  // Public factory
  factory UserProvider() {
    return _instance;
  }

  User get user => _user;

  updateUser(User tempUser) async {
    await writeToSecureStorage(tempUser);
    await readFromSecureStorage();
    notifyListeners();
  }

  updateUserTokens(String accessToken, String refreshToken) async{
    _user.jwt = accessToken;
    _user.jwtRefresh = refreshToken;
    await writeToSecureStorage(_user);
    await readFromSecureStorage();
  }

  updateUserAT(String accessToken) async {
    _user.jwt = accessToken;
    await writeToSecureStorage(_user);
    await readFromSecureStorage();
  }

  updateUserRFT(String refreshToken) async {
    _user.jwtRefresh = refreshToken;
    await writeToSecureStorage(_user);
    await readFromSecureStorage();
  }


  clearUser() async {
    _user = User(
      id: "-1",
      username: "test",
      email: "test@test.com",
      userType: 0,
      );
    await writeToSecureStorage(_user);
    notifyListeners();
  }

  refreshJWT(context) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    var logger = MyLogger.getLogger();
    logger.i("checking JWT");
    String jwtRefresh = userProvider.user.jwtRefresh;
    logger.i("Refresh JWT");
    Map<String, dynamic> response = await ApiServiceAuth().refresh(jwtRefresh, context);
    
    if(response["statusCode"]==200){
      await userProvider.updateUserTokens(response["body"]["access_token"], response["body"]["refresh_token"]);
    }else{
      throw handleLogout(context);
    }
  }

  writeToSecureStorage(User tempUser) async {
    await singletonUser.writeData(tempUser);
  }

  readFromSecureStorage() async {
    _user = await singletonUser.readData();
  }
}