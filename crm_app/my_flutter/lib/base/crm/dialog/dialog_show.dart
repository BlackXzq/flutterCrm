import 'dart:io';

import 'package:aj_flutter_plugin/aj_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter/base/model/AppReleaseBean.dart';

//iOS更新提醒
class DialogShow {
  static String getMsgs(AppReleaseBean releaseBean) {
    String resultMsg = ''; //== 分隔符换成\n
    if (releaseBean != null && releaseBean.releaseLog != null) {
      resultMsg = releaseBean.releaseLog.replaceAll('==', '\n');
    }
    return resultMsg;
  }

  /// 单击提示退出
  static Future<bool> dialogUpdateApp(
      BuildContext context, AppReleaseBean appVersionModel, bool isMustUpdate) {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: Text("更新"),
              content: new Text(getMsgs(appVersionModel)),
              actions: <Widget>[
                isMustUpdate
                    ? new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: new Text("取消"),
                      )
                    : Container(),
                new FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (Platform.isIOS) {
                        await launch(appVersionModel.downloadUrl);
                      }
                    },
                    child: new Text("确定"))
              ],
            ));
  }
}
