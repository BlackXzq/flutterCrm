import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter/base/crm/customview/Toast.dart';
import 'package:my_flutter/base/crm/event/LoadingShowEvent.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';
import 'package:my_flutter/base/crm/utils/aj_log_util.dart';
import 'package:dio/dio.dart';
import 'package:my_flutter/base/crm/request/ResponseCode.dart';
import 'package:my_flutter/base/crm/request/ResponseDto.dart';
import 'package:my_flutter/base/crm/constant/CommonUrls.dart';
import 'package:my_flutter/base/crm/event/LogoutEvent.dart';

class ApiClient {
  static const String time = "reqTime";
  static const String token = "token";
  static const String reqData = "reqData";
  static const String sign = "sign";
  String nowTime;
  Map map = new Map();
  Map jsonMap = new Map();
  Map<String, dynamic> param = {
    time: null,
    token: "",
    reqData: null,
    sign: null,
  };

  ApiClient();

  ApiClient put(Object key, Object value) {
    map[key] = value;
    return this;
  }

  ApiClient putAll(Map map) {
    this.map.addAll(map);
    return this;
  }

  //数据请求
  post(
      BuildContext context, String url, Function callback, Function callbackMsg,
      {bool showMsg = true, bool showLoading = false, Function onError}) async {
    AJLogUtil.v("url: ${url}  ", tag: "${context?.widget?.runtimeType}");

    //先校验网络
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Toast.toast(context, '请检查网络设置');
      callbackMsg('');
      return;
    }

    //如果要展示loading，发通知展示
    if (showLoading == true) {
      loadingShowEventBus.fire(LoadingShowEvent(true));
    }

    nowTime = new DateTime.now().millisecondsSinceEpoch.toString();
    String myJsonStr = json.encode(map);
    myJsonStr = myJsonStr.replaceAll(new RegExp('\\\\'), "");
    param[token] = await UserUtils.getToken() ?? "";
    param[time] = nowTime;
    param[reqData] = map;
    param[sign] = getSign(myJsonStr);

    AJLogUtil.v("before myJsonStr is " + myJsonStr);

    Options options = new Options(
      connectTimeout: 10000,
      receiveTimeout: 6000,
    );
    Dio dio = new Dio(options);
    AJLogUtil.v("Crm token str is " + param[token].toString());
    AJLogUtil.v("Crm signed str is " + myJsonStr);
    await dio.post(url, data: param).then((Response response) {
      jsonMap = response.data;
    }).then((_) {
      //如果需要展示loading，请求结束，通知loading取消
      if (showLoading == true) {
        loadingShowEventBus.fire(LoadingShowEvent(false));
      }

      //打印response
      AJLogUtil.v("Crm jsonMap ${jsonMap}");

      if (jsonMap != null) {
        //responseCode
        String repCode = jsonMap[ResponseDto.repCode];
        //message
        String msg = jsonMap[ResponseDto.repMsg];
        switch (repCode) {
          //请求成功
          case ResponseCode.Success:
            //因为不一定所有成功的请求都需要展示message，所以这个作为可选
            if (callbackMsg != null && showMsg == true) {
              callbackMsg(msg);
            }
            callback(jsonMap[ResponseDto.repData]);
            break;
          //token过期，需要重新登录
          case ResponseCode.TokenExpired:
            Toast.toast(context, msg);
            //区分一下，一个是LoginEvent,一个是LogoutEvent，
            logoutEvent.fire(LogoutEvent(true));
            break;
          default:
            if (callbackMsg != null) {
              callbackMsg(msg);
            }
            break;
        }
      }
    }).catchError((error) {
      return false;
    });
  }

  /**
   * 对Sign进行md5加密
   *
   * @return 获取签名
   */
  String getSign(String myJsonStr) {
    AJLogUtil.v("getSign myJsonStr is " + myJsonStr);
    String baseSignMsg =
        reqData + myJsonStr + time + nowTime + token + param[token].toString();
    AJLogUtil.v("getSign baseSignMsg is " + baseSignMsg);
    String sign = AppUtils.generateMd5(baseSignMsg);
    AJLogUtil.v("getSign sign is " + sign);
    return sign;
  }
}
