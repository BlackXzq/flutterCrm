import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_flutter/base/crm/customview/CustomAppBar.dart';

class WidgetFactory {
  static const double arrowSize = 13;
  static const double itemHeight = 44;
  static const double appBarHeight = 48;
  static const double indicatorWidth = 42;
  static const double indicatorheight = 10;
  static Widget getPageBody(Widget body, BuildContext context, String title,
      {bool displayBackButton = true,
      bool isShowBackground = true,
      List<Widget> actionWidgets,
      Function keyBack}) {
    return Container(
        child: Column(children: <Widget>[
      CustomAppBar.getCutomAppBar(context, title,
          displayBackButton: displayBackButton,
          actionWidgets: actionWidgets,
          isShowBackground: isShowBackground,
          keyBack: keyBack),
      Expanded(
        child: body,
        flex: 1,
      )
    ]));
  }

  /**
   * 为何要这样处理？因为自定义输入框的时候，输入过程中，不断的update会导致selection在最后，影响输入
   */
  static bool checkNeedUpdateDelete(String lastLabel, String curLabel) {
    if (Platform.isIOS) {
      return false;
    }
    bool update = false;
    //从非空到空，需要刷新
    if (lastLabel != null && lastLabel.isNotEmpty) {
      if (curLabel.isEmpty) {
        update = true;
      }
    }
    //从空到非空，需要刷新
    if (lastLabel == null || lastLabel.isEmpty) {
      if (curLabel.isNotEmpty) {
        update = true;
      }
    }
    return update;
  }

  static Widget getDivider({double height = 1.0}) {
    return Container(
      color: Color(0xFFF1F1F1),
      height: height,
    );
  }
}
