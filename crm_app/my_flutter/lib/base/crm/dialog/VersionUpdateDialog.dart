import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter/base/crm/constant/ColorConstant.dart';
import 'package:my_flutter/base/crm/constant/Commons.dart';
import 'package:my_flutter/base/crm/customview/Toast.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class VersionUpdateDialog extends Dialog {
  String title;
  String message;
  String negativeText;
  String positiveText;
  String iconPath;
  Function onCloseEvent;
  double minHeight;
  double barHeight = 48;
  double radius = 20;
  bool mustUpdate;
  String downloadUrl;
  List<String> versionMsgList;

  VersionUpdateDialog(
      {Key key,
      this.iconPath,
      this.negativeText,
      this.positiveText,
      this.minHeight = 60,
      this.downloadUrl = '',
      this.mustUpdate = false,
      this.versionMsgList})
      : assert(minHeight > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return new VersionUpdateWidget(
      iconPath: iconPath,
      negativeText: negativeText,
      positiveText: positiveText,
      downloadUrl: downloadUrl,
      minHeight: minHeight,
      mustUpdate: mustUpdate,
      versionMsgList: versionMsgList,
    );
//          resizeToAvoidBottomPadding: false,
  }
}

class VersionUpdateWidget extends StatefulWidget {
  String title;
  String message;
  String negativeText;
  String positiveText;
  String iconPath;
  double minHeight;
  double barHeight = 48;
  double radius = 20;
  double rate;
  String downloadUrl;
  bool mustUpdate;
  List<String> versionMsgList;

  VersionUpdateWidget(
      {Key key,
      this.iconPath,
      this.negativeText,
      this.positiveText,
      this.minHeight = 60,
      this.downloadUrl = '',
      this.rate = 0.0,
      this.mustUpdate = false,
      this.versionMsgList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    if (Platform.isIOS) {
      return new _iOSVersionUpdateWidgetState();
    }
    return new _VersionUpdateWidgetState();
  }
}

class _VersionUpdateWidgetState extends State<VersionUpdateWidget>
     {
  static const platformapkinstall =
      const MethodChannel(Commons.apkinstallChannel);

  @override
  void initState() {
    super.initState();
  }

  List<Widget> getVersionLayout() {
    List<Widget> list = [];
    List<Widget> msgItems = [];
    list.add(SizedBox(
      height: 12,
    ));
    if (widget.versionMsgList != null) {
      msgItems = widget.versionMsgList.map((msg) {
        return Container(
          constraints: BoxConstraints(minHeight: 24),
          child: new Text(
            msg,
            style: TextStyle(fontSize: 15.0, color: Color(0xFF666666)),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 12, right: 12),
        );
      }).toList();
    }
    list.addAll(msgItems);
    list.add(SizedBox(
      height: 20,
    ));
    list.add(Padding(
      padding: EdgeInsets.only(left: 6, right: 6),
      child: LinearProgressIndicator(
        value: widget.rate,
      ),
    ));
    list.add(SizedBox(
      height: 12,
    ));
    return list;
  }

  Widget getDivider({double height = 1.0}) {
    return Container(
      color: Color(0xFFf0f0f0),
      height: height,
    );
  }

  Widget _buildOperationBar() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Expanded(
            flex: 1,
            child: _getNegativeWidget(),
          ),
          new Expanded(
            flex: 1,
            child: _getPositiveWidget(),
          ),
        ]);
  }

  Widget _getNegativeWidget() {
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(bottomLeft: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text(widget.mustUpdate ? "退出" : '取消',
                    style: TextStyle(color: Color(0xFF333333), fontSize: 16.0)),
              ),
              onTap: () {
                if (widget.mustUpdate) {
                  AppUtils.popApp();
                } else {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radius))),
        ));
  }

  Widget _getPositiveWidget() {
    return Material(
        color: ColorConstant.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(bottomRight: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text('更新',
                    style: TextStyle(color: Colors.white, fontSize: 16.0)),
              ),
              onTap: () {
                if (widget.downloadUrl == null || widget.downloadUrl.isEmpty) {
                  Toast.toast(context, '没有安装包下载地址');
                }
                //TODO
                //开始下载
                if (widget != null) {
                  downloadFile(widget.downloadUrl);
                }
              },
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(widget.radius))),
        ));
  }

  //用dio实现文件下载
  downloadFile(String apkUrl) async {
    Response response;
    Dio dio = new Dio();
    // 获取本地文档目录
    String dir = (await getExternalStorageDirectory()).path;
    //保证唯一
    File file = new File('$dir/ftp_' +
        new DateTime.now().millisecondsSinceEpoch.toString() +
        '.apk');
    response =
        await dio.download(apkUrl, file.path, onProgress: (received, total) {
      print("total" + total.toString() + " received " + received.toString());
      double ratio = received / total;
      setState(() {
        widget.rate = ratio;
      });
      ratio = ratio * 100;
      print("rate" + ratio.toString() + "%");
      if (ratio >= 100) {
        _notifyInstall(file);
      }
    });
  }

  _notifyInstall(File file) async {
    String versionCode;
    try {
      print("dart -_versionUpdate");
//      在通道上调用此方法
      Map<String, String> argument = new Map();
      argument["path"] = file.path;
      final int result = await platformapkinstall.invokeMethod(
          Commons.apkInstallMethod, argument);
      versionCode = '$result';
    } on PlatformException catch (e) {
      print("dart -PlatformException ");
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: new Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
        child: new Material(
          type: MaterialType.transparency,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                decoration: ShapeDecoration(
                  color: Color(0xffffffff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.radius),
                    ),
                  ),
                ),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Text(
                        '新版发布',
                        style:
                            TextStyle(fontSize: 20.0, color: Color(0xFFFFA033)),
                      ),
                      height: 36,
                      margin: EdgeInsets.only(top: 6),
                      alignment: Alignment.center,
                    ),
                    new Container(
                      constraints: BoxConstraints(minHeight: widget.minHeight),
                      child: Column(
                        children: getVersionLayout(),
                      ),
                    ),
                    getDivider(),
                    this._buildOperationBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        if (widget.mustUpdate) {
          AppUtils.popApp();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

class _iOSVersionUpdateWidgetState extends State<VersionUpdateWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getVersionLayout() {
    List<Widget> list = [];
    List<Widget> msgItems = [];
    list.add(SizedBox(
      height: 12,
    ));
    if (widget.versionMsgList != null) {
      msgItems = widget.versionMsgList.map((msg) {
        return Container(
          constraints: BoxConstraints(minHeight: 24),
          child: new Text(
            msg,
            style: TextStyle(fontSize: 15.0, color: Color(0xFF666666)),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 12, right: 12),
        );
      }).toList();
    }
    list.addAll(msgItems);
    list.add(SizedBox(
      height: 12,
    ));
    return list;
  }

  Widget getDivider({double height = 1.0}) {
    return Container(
      color: Color(0xFFf0f0f0),
      height: height,
    );
  }

  Widget _buildOperationBar() {
    //widget.mustUpdate
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          widget.mustUpdate
              ? Container()
              : new Expanded(
                  flex: 1,
                  child: _getNegativeWidget(),
                ),
          new Expanded(
            flex: 1,
            child: _getPositiveWidget(),
          ),
        ]);
  }

  Widget _getNegativeWidget() {
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(bottomLeft: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text('取消',
                    style: TextStyle(color: Color(0xFF333333), fontSize: 16.0)),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radius))),
        ));
  }

  Widget _getPositiveWidget() {
    return Material(
        color: ColorConstant.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: widget.mustUpdate
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radius),
                  bottomRight: Radius.circular(widget.radius))
              : BorderRadius.only(bottomRight: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text('更新',
                    style: TextStyle(color: Colors.white, fontSize: 16.0)),
              ),
              onTap: () {
                AppUtils.gotoAppstore(context, widget.downloadUrl);
              },
              borderRadius: widget.mustUpdate
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(widget.radius),
                      bottomRight: Radius.circular(widget.radius))
                  : BorderRadius.only(
                      bottomRight: Radius.circular(widget.radius))),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: new Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
        child: new Material(
          type: MaterialType.transparency,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                decoration: ShapeDecoration(
                  color: Color(0xffffffff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.radius),
                    ),
                  ),
                ),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Text(
                        '新版发布',
                        style:
                            TextStyle(fontSize: 20.0, color: Color(0xFFFFA033)),
                      ),
                      height: 36,
                      margin: EdgeInsets.only(top: 6),
                      alignment: Alignment.center,
                    ),
                    new Container(
                      constraints: BoxConstraints(minHeight: widget.minHeight),
                      child: Column(
                        children: getVersionLayout(),
                      ),
                    ),
                    getDivider(),
                    this._buildOperationBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        if (widget.mustUpdate) {
          AppUtils.popApp();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
