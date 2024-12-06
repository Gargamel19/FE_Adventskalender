import 'package:flutter/material.dart';
import 'package:test_app/connector/api_connector_calender.dart';
import 'package:test_app/models/calender.dart';

class CalenderProvider extends ChangeNotifier {
  static final CalenderProvider _instance = CalenderProvider._internal();
  
  CalenderProvider._internal();

  factory CalenderProvider() {
    return _instance;
  }


  int page = 0;

  List<Calender> calenderList = [];

  fetchMyCalender(BuildContext context) async {
    calenderList = await ApiServiceCalender.myCalender(context);
    print(calenderList.length);
    notifyListeners();
  }

  fetchAllCalender(BuildContext context) async {
    calenderList = await ApiServiceCalender.allCalender(context);
    print(calenderList.length);
    notifyListeners();
  }


}