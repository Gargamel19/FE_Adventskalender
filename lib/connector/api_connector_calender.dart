import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_app/models/calender.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/snackbar.dart';

class ApiServiceCalender {

  static Future<List<Calender>> allCalender(BuildContext context) async {
    String baseURI = await getBaseUrl();
    print('$baseURI/calender/all');
    try {
      Map<String, String> headers = await getHeaders();
      final response = await http.get(Uri.parse('$baseURI/calender/all'), headers: headers);
      if (response.statusCode == 200) {
        if (!context.mounted) return [];
        Map<String, dynamic> result = handleAPIResponse(
          response.statusCode,
          context,
          () => json.decode(response.body),
          response,
        );
        List<Calender> calenderList = [];
        result["body"].forEach(
          (calender) {
            calenderList.add(Calender.fromJson(calender));
          }
        );
        return calenderList;
      } else {
        showSnackBar('Failed to load calender from API');
        return [];
      }
    } catch (e, s) {
      var message = "Error fetching orders: $e $s";
      if (context.mounted) {
        showSnackBar(message);
      }
      rethrow;
    }
  }

  static Future<List<Calender>> myCalender(BuildContext context) async {
    String baseURI = await getBaseUrl();
    Map<String, String> headers = await getHeaders();
    print('$baseURI/calender/my');
    final response = await http.get(Uri.parse('$baseURI/calender/my'), headers: headers);
    if (response.statusCode == 200) {
      if (!context.mounted) return [];
      Map<String, dynamic> result = handleAPIResponse(
        response.statusCode,
        context,
        () => json.decode(response.body),
        response,
      );
      
      List<Calender> calenderList = [];
      result["body"].forEach(
        (calender) {
          calenderList.add(Calender.fromJson(calender));
        }
      );
      return calenderList;
    } else {
      showSnackBar('Failed to load calender from API');
      return [];
    }
  }
  
}