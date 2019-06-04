import 'package:flutter/material.dart';
import 'package:my_flutter/base/crm/constant/UserContant.dart';
import 'package:my_flutter/base/crm/event/LoginEvent.dart';
import 'package:my_flutter/base/crm/login/LoginPage.dart';
import 'package:my_flutter/base/crm/login/LoginRespDto.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserUtils {
  //是否登录
  static Future<bool> getLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(UserContant.isLogin);
  }

  static Future<bool> setLogin(bool isLogin) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(UserContant.isLogin, isLogin);
    if (isLogin == false) {
      sharedPreferences.setString(UserContant.name, '');
      sharedPreferences.setString(UserContant.userCode, '');
      sharedPreferences.setString(UserContant.token, '');
    }
    loginEevnt.fire(LoginEvent(isLogin));
  }

  static updateFirstLaunch(bool firstLaunch) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(UserContant.isFirstLaunch, firstLaunch);
  }

  //蛋疼的玩法，临时存储
  static updateHomeItemsCount(int count) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(UserContant.homeItemCount, count);
  }

  static Future<int> getHomeItemsCount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(UserContant.homeItemCount);
  }

  static Future<bool> getFirstLaunch() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(UserContant.isFirstLaunch);
  }

  static gotoLogin(BuildContext context) {
    AppUtils.push(context, LoginPage());
  }

  //保存用户信息
  static updateUser(LoginRespDto bean) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(UserContant.name, bean.loginName);
    sharedPreferences.setString(UserContant.userCode, bean.code);
    sharedPreferences.setString(UserContant.token, bean.token);
  }

  static Future<String> getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(UserContant.name);
  }

  static Future<String> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(UserContant.token);
  }

  static Future<String> getCode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(UserContant.userCode);
  }

  static logout(BuildContext context) {
    setLogin(false).then((login) {
      AppUtils.push(context, LoginPage());
    });
  }
}
