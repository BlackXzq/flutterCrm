import 'dart:async';
import 'dart:convert';

import 'package:aj_flutter_plugin/aj_flutter_plugin.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter/base/crm/constant/RouteConstant.dart';
import 'package:my_flutter/base/crm/dialog/ConfirmDialog.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';

class AppUtils {
  /*
  * appurl 跳转URL
  * */
  static Future gotoAppstore(BuildContext context, String appurl) async {
    Navigator.pop(context);
    if (await canLaunch(appurl)) {
      await launch(appurl);
    }
  }

  static Future gotoMainPage(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, RouteConstant.Homepage,
        ModalRoute.withName(RouteConstant.Homepage));
  }

  static Future push(BuildContext context, Widget page,
      {replace = false, reverse = false, needWait = false}) {
    if (replace) {
      return Navigator.pushAndRemoveUntil(context,
          PageRouteBuilder(pageBuilder: (context, _, __) {
        return page;
      }), (route) {
        return !route.isActive;
      });
    }

    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static Future pushName(BuildContext context, String routeName,
      {replace = false, reverse = false, needWait = false}) {
    return Navigator.pushNamed(context, routeName);
  }

  static SlideTransition createTransition(
      Animation<double> animation, Widget child, bool reverse) {
    double offset = reverse ? -1.0 : 1.0;
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: Offset(offset, 0.0),
        end: Offset(0.0, 0.0),
      ).animate(animation),
      child: child, // child is the value returned by pageBuilder
    );
  }

// md5 加密
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  //退出APP
  static Future<void> popApp() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  static onLoginCheckDialog(BuildContext parentContext, Widget page,
      {Function function, String msg}) {
    UserUtils.getLogin().then((login) {
      if (login == true) {
        if (page != null) {
          AppUtils.push(parentContext, page);
        }
        if (function != null) {
          function();
        }
      } else {
        showDialog(
            context: parentContext,
            builder: (context) {
              return _showLoginCheckDialog(parentContext, context, msg: msg);
            }).then((result) {
          print("showDialog future result " + result.toString());
        });
      }
    });
  }

  static showCommonDialog(BuildContext parentContext,
      {String positiveMsg = '',
      String negativeMsg = '',
      Function onDone,
      Function onCancel,
      String msg = ''}) {
    showDialog(
        context: parentContext,
        builder: (context) {
          return showCustomCommonDialog(parentContext, context,
              positiveMsg: positiveMsg,
              negativeMsg: negativeMsg,
              onDone: onDone,
              onCancel: onCancel,
              msg: msg);
        }).then((result) {});
  }

  static Widget showCustomCommonDialog(
      BuildContext parentContext, BuildContext context,
      {String positiveMsg = '',
      String negativeMsg = '',
      Function onDone,
      Function onCancel,
      String msg = ''}) {
    ConfirmDialog messageDialog = new ConfirmDialog(
      title: "",
      message: msg,
      positiveText: positiveMsg,
      negativeText: negativeMsg,
      needHead: false,
      onPositivePressEvent: (str) {
        if (onDone != null) {
          onDone();
        }
        Navigator.pop(context);
      },
      onCloseEvent: () {
        if (onCancel != null) {
          onCancel();
        }
        Navigator.pop(context);
      },
      minHeight: 70,
    );
    return messageDialog;
  }

  static Widget _showLoginCheckDialog(
      BuildContext parentContext, BuildContext context,
      {String msg}) {
    ConfirmDialog messageDialog = new ConfirmDialog(
      title: "是否登录",
      message: msg,
      positiveText: "登录",
      negativeText: '取消',
      needHead: false,
      onPositivePressEvent: (str) {
        print("onPositivePressEvent");
        Navigator.pop(context);
        Navigator.pushNamed(parentContext, RouteConstant.LoginPage);
      },
      onCloseEvent: () {
        print("oncloseEent");
        Navigator.pop(context);
      },
      minHeight: 70,
    );
    return messageDialog;
  }

  static String getNotNullStr(dynamic str) {
    if (null == str || str.startsWith('null')) {
      return '';
    }
    return str;
  }

  static String getNumStr(num number) {
    num value = number;
    String valueStr = '';
    if (value != null && !value.toString().startsWith('null')) {
      valueStr = value.toString();
    }
    return valueStr;
  }
}
