import 'package:flutter/material.dart';

class LoadingSingletonUtil {
  static List<BuildContext> contextList = [];
  static int showTime = 0;
  static addContext(BuildContext context) {
    List<BuildContext> tmpList = contextList.where((ctx) {
      return context.widget.runtimeType == ctx.widget.runtimeType;
    }).toList();
    if (tmpList == null || tmpList.isEmpty) {
      contextList.add(context);
    }
  }

  static bool showLoading(BuildContext context) {
    int currentTime = new DateTime.now().millisecondsSinceEpoch;
    bool canShowLoading = false;
    contextList.map((ctx) {
      if (context?.widget == ctx?.widget) {
        //说明不是同时弹出Loading
        if (showTime == 0 || (showTime != 0 && currentTime - showTime >= 200)) {
          //跳过
          canShowLoading = true;
          showTime = currentTime;
          return true;
        }
      }
    }).toList();

    return canShowLoading;
  }

  static bool removeContext(BuildContext context) {
    contextList.remove(context);
  }

  static bool checkLoadingStamp() {}
}
