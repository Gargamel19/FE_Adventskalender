import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';


class MyLogger {
  static Logger? _logger;
 

  static Future<void> initLogger() async {
    if (Platform.isWindows) {
      try {
        final directory =
            await getApplicationDocumentsDirectory();
        final logDirectory = Directory('${directory.path}/logs');
        if (!await logDirectory.exists()) {
          await logDirectory.create(recursive: true);
        }

        DateTime today = DateTime.now();
        String filePath =
            "${logDirectory.path}/${today.year}-${today.month}-${today.day}.log";

        _logger = Logger(
          filter: ReleaseFilter(),
          output: FileOutput(file: File(filePath)),
        );
      } catch (e) {
        debugPrint("Failed to initialize file logger: $e");
        _logger = Logger(
          filter: ReleaseFilter(),
          output: ConsoleOutput(), // Fallback to console output
        );
      }
    } else {
      _logger = Logger(
        filter: ReleaseFilter(),
        output: ConsoleOutput(), // Use console output on non-Windows platforms
      );
    }
  }

  static Logger getLogger() {
    if (_logger == null) {
      initLogger();
      if (_logger == null) {
        throw Exception(
            "Logger not initialized. Call MyLogger.initLogger() first.");
      }
    }
    return _logger!;
  }

  static void setLogger(Logger logger) {
    _logger = logger;
  }
}

class ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
