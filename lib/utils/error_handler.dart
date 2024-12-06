
import 'package:flutter/material.dart';
import 'package:test_app/utils/logger.dart';

var logger = MyLogger .getLogger();
class ErrorHandler{

  void initialize() {
  // List of error substrings to suppress
    List<String> suppressedErrors = [
      'Unable to load asset',
      'Cannot open file',
      'Yet another error message to suppress'
    ];
    FlutterError.onError = (FlutterErrorDetails details) {
      bool shouldSuppress = suppressedErrors.any((error) => details.exceptionAsString().contains(error));
      if (!shouldSuppress) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        // logger.d("Suppressed error: ${details.exceptionAsString()}");
      }
    };

  }

  void log(error, stack){
    //var _message = "Zone Error: ${error.runtimeType.toString()}";
  }

}
