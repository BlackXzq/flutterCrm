import 'dart:async';
import 'dart:io';

import 'package:aj_flutter_plugin/aj_flutter_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter/base/crm/constant/CommonUrls.dart';
import 'package:my_flutter/base/crm/constant/UserContant.dart';
import 'package:my_flutter/base/crm/customview/Toast.dart';
import 'package:my_flutter/base/crm/dialog/ConfirmDialog.dart';
import 'package:my_flutter/base/crm/dialog/Loading.dart';
import 'package:my_flutter/base/crm/dialog/VersionUpdateDialog.dart';
import 'package:my_flutter/base/crm/event/LoadingShowEvent.dart';
import 'package:my_flutter/base/crm/event/LoginEvent.dart';
import 'package:my_flutter/base/crm/event/LogoutEvent.dart';
import 'package:my_flutter/base/crm/event/RevertEvent.dart';
import 'package:my_flutter/base/crm/request/ApiClient.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/LoadingSingletonUtil.dart';
import 'package:my_flutter/base/crm/utils/PermissionUtil.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';
import 'package:my_flutter/base/model/AppReleaseBean.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

mixin CommonMixin<T extends StatefulWidget> on State<T> {
  AppReleaseBean releaseBean;
  double downloadRate = 0.0;
  String _versionCode = "1";
  String _versionName = "1.0.0";

  @override
  bool get wantKeepAlive => false;

  //获取版本号
  getVersionCode(BuildContext context,
      {bool isUpdateAction = false, bool needToast = false}) async {
    AjFlutterPlugin info = await AjFlutterPlugin.platformVersion();
    if (info.version != null) {
      _versionCode = "${info.buildNumber}";
      _versionName = "${info.version}";
      if (Platform.isIOS) {
        _getVersionRequest(context,
            isUpdateAction: isUpdateAction, needToast: needToast);
      } else {
        requestPermission(context,
            isUpdateAction: isUpdateAction, needToast: needToast);
      }
    }
  }

  requestPermission(BuildContext context,
      {bool isUpdateAction = false, bool needToast = false}) async {
    List<Permission> list = [
      Permission.WriteExternalStorage,
    ];
    PermissionUtil.getPermissionResult(list, (pass) async {
      if (pass == false) {
        AppUtils.showCommonDialog(context,
            msg: '"获取文件读写权限失败,即将跳转应用信息”>“权限”中开启权限"',
            negativeMsg: '取消',
            positiveMsg: '前往', onDone: () {
          PermissionUtil.openSettings().then((openSuccess) {
            if (openSuccess != true) {}
          });
        });
      } else {
        _getVersionRequest(context,
            isUpdateAction: isUpdateAction, needToast: needToast);
      }
    });
  }

  _getVersionRequest(BuildContext context,
      {bool isUpdateAction = false, bool needToast = false}) {
    print("dart -_getVersionRequest ");
    //1是android，2是iOS
    ApiClient apiClient =
        new ApiClient().put("platformType", Platform.isIOS ? 2 : 1);
    apiClient.post(context, CommonUrls.getVersionUpdateUrl, (map) {
      print("getVersionUpdateUrl map  ${map}");
      releaseBean = AppReleaseBean.fromJson(map);
      print("PageBean createTime  ${releaseBean}");
      if (releaseBean != null) {
        print("_versionCode " +
            releaseBean.versionCode.toString() +
            " remote name " +
            releaseBean.versionName.toString());
        num code = num.parse(_versionCode);
        if (Platform.isIOS) {
          //TODO iOS 部分提示更新
          Version _currentVersion = Version.parse(_versionName);
          Version _latestVersion = Version.parse(releaseBean.versionName);
          if (_latestVersion > _currentVersion) {
            //TODO
            _onVersionUpdateClick(isUpdateAction: isUpdateAction);
          }
        } else {
          if (code < releaseBean.versionCode) {
            _onVersionUpdateClick(isUpdateAction: isUpdateAction);
          } else if (needToast) {
            Toast.toast(context, '当前已经是最新版本');
          }
        }
      }
    }, (msg) {});
  }

  //版本更新
  _onVersionUpdateClick({bool isUpdateAction = false}) async {
    //这个地方主要是判断首页提示更新添加时效（小时 * 分钟 * 秒 * 1000），超过时效提示更新
    if (!isUpdateAction) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int nowTime = new DateTime.now().millisecondsSinceEpoch;
      int oldUpdateTime = sharedPreferences.getInt(UserContant.updateOldTime);
      if (oldUpdateTime != null) {
        // 12小时 * 60分钟 * 60秒 * 1000
        if ((nowTime - oldUpdateTime) < 2 * 60 * 60 * 1000) {
          return;
        }
      } else {
        sharedPreferences.setInt(UserContant.updateOldTime, nowTime);
      }
    }
    showDialog(
        context: context,
        builder: (context) {
          return _showVersionUpdateDialog(context);
        }).then((result) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int nowTime = new DateTime.now().millisecondsSinceEpoch;
      sharedPreferences.setInt(UserContant.updateOldTime, nowTime);
      print("showDialog future result " + result.toString());
    });
  }

  bool isMustUpdate() {
    if (releaseBean != null) {
      if (releaseBean.isMustUpdate == 1) {
        //强制更新
        return true;
      }
    }
    return false;
  }

  List<String> getMsgs() {
    List<String> list = [];
    if (releaseBean != null && releaseBean.releaseLog != null) {
      list = releaseBean.releaseLog.split('==');
    }
    return list;
  }

  _showVersionUpdateDialog(context) {
    VersionUpdateDialog messageDialog = new VersionUpdateDialog(
      positiveText: "更新",
      versionMsgList: getMsgs(),
      mustUpdate: isMustUpdate(),
      downloadUrl: releaseBean.downloadUrl,
      minHeight: 160,
    );
    return messageDialog;
  }

  //打电话
  _callPhone(String number) async {
    await launch("tel:" + number);
  }

  @override
  void initState() {
    super.initState();
  }

//退出下单
  onOrderOutClick(Function keyBack) {
    showDialog(
        context: context,
        builder: (context) {
          return _showOrderOutDialog(context, keyBack);
        }).then((result) {
      print("showDialog future result " + result.toString());
    });
  }

  Widget _showOrderOutDialog(BuildContext context, Function keyBack) {
    ConfirmDialog messageDialog = new ConfirmDialog(
      title: "退出",
      message: '是否退出寄件页面?',
      positiveText: "是",
      needHead: false,
      negativeText: '否',
      onPositivePressEvent: (str) {
        print("onPositivePressEvent");
        //跳转到拨打页面
        Navigator.pop(context, str);
        if (keyBack != null) {
          keyBack();
        }
      },
      onCloseEvent: () {
        print("oncloseEent");
        Navigator.pop(context);
      },
      minHeight: 70,
    );
    return messageDialog;
  }

  onOrderDoneClick(Function keyBack) {
    showDialog(
        context: context,
        builder: (context) {
          return _showOrderDoneDialog(context, keyBack);
        }).then((result) {});
  }

  Widget _showOrderDoneDialog(BuildContext context, Function keyBack) {
    ConfirmDialog messageDialog = new ConfirmDialog(
      title: "退出",
      message: '您已下单成功，稍后客服将与您联系。',
      positiveText: "我知道了",
      msgFontSize: 14,
      keybackEvent: () {
        Navigator.pop(context, '');
        if (keyBack != null) {
          keyBack();
        }
      },
      needHead: false,
      onPositivePressEvent: (str) {
        Navigator.pop(context, str);
        if (keyBack != null) {
          keyBack();
        }
      },
      onCloseEvent: null,
      minHeight: 70,
    );
    return messageDialog;
  }

  //Loading 处理
  bool isLoading = false;
  BuildContext dialogContext;

  //barrierColor 可自定义背景颜色
  showLoading(BuildContext context) {
    getCountdownTimer();
    isLoading = true;
    showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierColor: Color(0x30000000),
      barrierDismissible: true,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        dialogContext = context;
        return WillPopScope(
            child: LoadingWidget(),
            onWillPop: () async {
              //有个逻辑是，当在loading过程中，如果按了返回键，个别场景需要重置数据
              loginEevnt.fire(RevertEvent(true));
              dismissLoading();
              return false;
            });
      },
    );
//    showDialog(
//        context: context,
//        builder: (context) {
//          dialogContext = context;
//          return WillPopScope(
//              child: Loading(),
//              onWillPop: () async {
//                //有个逻辑是，当在loading过程中，如果按了返回键，个别场景需要重置数据
//                loginEevnt.fire(RevertEvent(true));
//                dismissLoading();
//                return false;
//              });
//        }).then((result) {});
  }

  dismissLoading() {
    resetTimer();
    if (dialogContext != null && isLoading == true) {
      isLoading = false;
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }
    }
  }

  clearLoadingContext(BuildContext context) {
    LoadingSingletonUtil.removeContext(context);
  }

  StreamSubscription subscription;
  StreamSubscription loadingShowSubscription;

  initEvent(BuildContext context) {
    if (subscription == null) {
      subscription = logoutEvent.on<LogoutEvent>().listen((event) {
        if (event.logout == true) {
          dismissLoading();
          UserUtils.logout(context);
        }
      });
    }
    if (loadingShowSubscription == null) {
      LoadingSingletonUtil.addContext(context);
      loadingShowSubscription =
          loadingShowEventBus.on<LoadingShowEvent>().listen((event) {
        if (event.show == true) {
          if (LoadingSingletonUtil.showLoading(context)) {
            showLoading(context);
          }
        } else {
          dismissLoading();
        }
      });
    }
  }

  //15s后dialog强制消失
  Timer _countdownTimer;
  int _totalSeconds = 15;
  int _countdownNum = 15;

  resetTimer() {
    if (_countdownTimer != null) {
      _countdownNum = _totalSeconds;
      _countdownTimer.cancel();
      _countdownTimer = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    resetTimer();
  }

  void getCountdownTimer() {
    if (_countdownTimer != null) {
      _countdownTimer.cancel();
      return;
    }
    _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      if (_countdownNum > 0) {
        _countdownNum--;
      } else {
        dismissLoading();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
