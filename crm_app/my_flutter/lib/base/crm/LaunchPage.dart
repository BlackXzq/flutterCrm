import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';

import 'GuidePage.dart';
import 'MainPage.dart';
void main() => runApp(new LaunchPage());

class LaunchPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new LaunchPageWidget(),
    );
  }
}

class LaunchPageWidget extends StatefulWidget {
  LaunchPageWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _LaunchPageState();
  }
}

class _LaunchPageState extends State<LaunchPageWidget>  {
  @override
  void initState() {
    super.initState();
    _waitToJump();
  }

  void _waitToJump() async {
    //等待2秒
    await Future.delayed(Duration(milliseconds: Platform.isIOS ? 800 : 2000))
        .then((result) {
      //检测是否第一次启动
      UserUtils.getFirstLaunch().then((isFirstLaunch) {
        if (isFirstLaunch == null || isFirstLaunch == true) {
          //跳转到引导页
          AppUtils.push(context, new WelcomeWidget(),
              replace: true, needWait: true);
        } else {
          //跳转到首页
          AppUtils.push(context, new MainPage(), replace: true, needWait: true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
      body: new Image.asset("images/launch.webp"),
      backgroundColor: Colors.white,
    ));
  }
}
