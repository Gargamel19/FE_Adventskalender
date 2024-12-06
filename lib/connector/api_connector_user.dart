import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/models/user.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/snackbar.dart';

class ApiServiceUser {

  static Future<User> getUser(BuildContext context, String userID) async {
    String baseURI = await getBaseUrl();
    User dummyUser = User(id: userID, username: 'Unknown', email: 'Unknown', userType: 0);
    try {
      Map<String, String> headers = await getHeaders();
      final response = await http.get(Uri.parse('$baseURI/user/$userID'), headers: headers);
      if (response.statusCode == 200) {
        if (!context.mounted) return dummyUser; 
        Map<String, dynamic> result = handleAPIResponse(
          response.statusCode,
          context,
          () => json.decode(response.body),
          response,
        );
        return User.fromJson(result["body"]);
      } else {
        showSnackBar('Failed to load calender from API');
        return dummyUser;
      }
    } catch (e, s) {
      var message = "Error fetching orders: $e $s";
      if (context.mounted) {
        showSnackBar(message);
      }
      rethrow;
    }
  }

  /**static Future<List<User>> allUser(BuildContext context) async {
    String baseURI = await getBaseUrl();
    List<User> dummyList = [];
    try {
      Map<String, String> headers = await getHeaders();
      final response = await http.get(Uri.parse('$baseURI/user'), headers: headers);
      if (response.statusCode == 200) {
        if (!context.mounted) return dummyList; 
        Map<String, dynamic> result = handleAPIResponse(
          response.statusCode,
          context,
          () => json.decode(response.body),
          response,
        );
        dummyList = (result["body"] as List).map((i) {
            return User.fromJson(i as Map<String, dynamic>);
          }).toList();
        return dummyList;
      } else {
        showSnackBar('Failed to load calender from API');
        return dummyList;
      }
    } catch (e, s) {
      var message = "Error fetching orders: $e $s";
      if (context.mounted) {
        showSnackBar(message);
      }
      rethrow;
    }
  }*/
  
}