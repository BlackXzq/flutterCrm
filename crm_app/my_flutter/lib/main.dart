import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter/base/crm/LaunchPage.dart';
import 'package:amap_base_location/amap_base_location.dart';

void main() async{

  //TODO
  if(Platform.isIOS){
    await AMap.init('72b1a23d95a9e010aa7f87f9853e1985');//app flutter debug

//    await AMap.init('bb39f501af63052fdda564dd6d544c9f');//app 混合 debug com.anjiplus.ftp.app1
//    await AMap.init('b236f086732319fcd0de744cc011264e');//app 混合 release  com.anjiplus.ftp.app
    
  } else {
    //  await AMap.init('26f632da417af4406df24bdda480fbbd');
    await AMap.init('97f04cfcf85e081fe3632d9860255116');//app debug
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(_widgetForRoute('route'));
}

Widget _widgetForRoute(String route) {
  print("");
  switch (route) {
    case 'route':
      return LaunchPage();
    default:
      return Center(
        child: Text('Unknown route: $route', textDirection: TextDirection.ltr),
      );
  }
}
