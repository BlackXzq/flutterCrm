import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusbarUtil {
  static setStatusBarLight({Color color = Colors.transparent}) {
    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: color,
          statusBarBrightness: Brightness.light,
//          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }

  static setStatusBarDark({Color color = Colors.transparent}) {
    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: color,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }
}
