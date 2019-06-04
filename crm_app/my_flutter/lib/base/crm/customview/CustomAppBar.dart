import 'package:flutter/material.dart';
import 'package:my_flutter/base/crm/constant/ColorConstant.dart';
import 'package:my_flutter/base/crm/customview/WidgetFactory.dart';

class CustomAppBar {
  static Widget getAppBar(BuildContext context, String title,
      {bool displayBackButton = true}) {
    Widget backBtn = displayBackButton == true
        ? IconButton(
            icon: Image.asset(
              "images/arrow_left.webp",
              width: 16,
              height: 16,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            })
        : Container();
    return AppBar(
      leading: backBtn,
      elevation: 0.0,
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      backgroundColor: ColorConstant.primaryColor,
      centerTitle: true,
    );
  }

  static Widget getActionWidget(List<Widget> actionWidgets) {
    List<Widget> widgts = [];
    if (actionWidgets != null) {
      widgts = actionWidgets.map((widget) {
        return Row(
          children: <Widget>[
            widget,
            SizedBox(
              width: 8,
            )
          ],
        );
      }).toList();
      Widget row =
          Row(children: widgts, mainAxisAlignment: MainAxisAlignment.end);
      return Container(
        alignment: Alignment.centerRight,
        child: row,
        padding: EdgeInsets.only(right: 12),
      );
    }
    return Container();
  }

  static Widget getCutomAppBar(BuildContext context, String title,
      {bool displayBackButton = true,
      List<Widget> actionWidgets,
      bool isShowBackground = true,
      Function keyBack}) {
    var _statusBarHeight = MediaQuery.of(context).padding.top;

    Widget backBtn = displayBackButton == true
        ? Padding(
            padding: EdgeInsets.only(top: _statusBarHeight),
            child: IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "images/arrow_left.webp",
                    width: 16,
                    height: 16,
                  ),
                ),
                onPressed: () {
                  if (keyBack != null) {
                    keyBack();
                  } else {
                    Navigator.of(context).pop();
                  }
                }),
          )
        : Container();
    return Container(
      child: Stack(
        children: <Widget>[
          Image.asset(
            'images/appbar_bg.webp',
            width: MediaQuery.of(context).size.width,
            height: WidgetFactory.appBarHeight + _statusBarHeight,
            fit: BoxFit.cover,
            color: isShowBackground ? null : Colors.transparent,
          ),
          Align(alignment: Alignment.centerLeft, child: backBtn),
          Padding(
            padding: EdgeInsets.only(top: _statusBarHeight),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: _statusBarHeight),
            child: getActionWidget(actionWidgets),
            width: MediaQuery.of(context).size.width,
          )
        ],
      ),
      height: WidgetFactory.appBarHeight + _statusBarHeight,
      width: MediaQuery.of(context).size.width,
    );
  }
}
