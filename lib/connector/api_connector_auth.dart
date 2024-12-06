import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_app/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/widgets/snackbar.dart';

class ApiServiceAuth {

  Future<Map<String, dynamic>> login(dynamic body, BuildContext context) async {
    var headers = {
      'Content-Type': 'application/json',
      'X-App-Version': getApiVersion(),
    };
    String baseUrl = await getBaseUrl();
    var uri = Uri.parse('$baseUrl/user/auth/login');

    try {
      var response = await http
          .post(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      if (!context.mounted) throw Exception('Context not mounted');
      Map<String, dynamic> result = handleAPIResponse(
        response.statusCode,
        context,
        () => json.decode(response.body),
        response,
      );
      loggedIn = true;
      
      return result;
    } catch (e) {
      //var message = ("Error at login: $e\n$s");
      showSnackBar(e.toString());
      return {'statusCode': 500, 'url': baseUrl, 'message': 'Error: $e'};
    }
  }

    Future<Map<String, dynamic>> refresh(
      String jwtRefresh, BuildContext context) async {
    var headers = {
      'Content-Type': 'application/json',
      'X-App-Version':  getApiVersion(),
      'Authorization': 'Bearer $jwtRefresh',
    };
    String baseUrl = await getBaseUrl();

    var uri = Uri.parse('$baseUrl/user/auth/refresh');
    try {
      var response = await http
          .post(
            uri,
            headers: headers,
          ).onError((error, stackTrace) {
              throw Exception("Error at refreshJWT: $error\n$stackTrace");
          }).timeout(const Duration(seconds: 120));
      if (!context.mounted) throw Exception("Context not Mounted");
      return handleAPIResponse(
        response.statusCode,
        context,
        () => json.decode(response.body),
        response,
      );
    } catch (e) {
      //print(e);
      //var message = ("Error at refreshJWT: $e\n$s");
      rethrow;
    }
  }

}