import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:my_flutter/base/crm/constant/ColorConstant.dart';
import 'package:my_flutter/base/crm/customview/ButtonFactory.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';
import 'package:transformer_page_view/transformer_page_view.dart';

import 'MainPage.dart';

class WelcomeWidget extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new MyHomePage(title: 'Guide Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class Welcome extends StatelessWidget {
  final List<String> images = [
    "images/guide_1.webp",
    "images/guide_2.webp",
    "images/guide_3.webp",
  ];

  final List<Color> backgroundColors = [
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  bool loop = false;
  double size = 12.0;
  double activeSize = 16.0;

  PageController controller;
  PageIndicatorLayout layout = PageIndicatorLayout.WARM;

  Widget getBtn(BuildContext context) {
    return ButtonFactory.getRoundSmallBtn(
      backgroundColor: ColorConstant.primaryColor,
      text: '立即体验',
      width: 120,
      height: 30,
      fontSize: 14,
      radius: 6,
      textColor: Colors.white,
      onTap: () {
        AppUtils.push(context, new MainPage(), replace: true, needWait: true);
      },
    );
  }

  Widget getLastPage(TransformInfo info, BuildContext context) {
    return new Stack(children: <Widget>[
      new ParallaxColor(
        colors: backgroundColors,
        info: info,
        child: new Column(
          children: <Widget>[
            new Expanded(
                child: new ParallaxContainer(
              child: new Image.asset(images[info.index]),
              position: info.position,
              opacityFactor: 1.0,
              translationFactor: 50.0,
            )),
          ],
        ),
      ),
      new Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: EdgeInsets.only(bottom: 66), child: getBtn(context)))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    controller = new TransformerPageController(
        itemCount: backgroundColors.length, loop: loop);
    return Stack(children: <Widget>[
      new TransformerPageView(
          index: 0,
          pageController: controller,
          transformer: new PageTransformerBuilder(
              builder: (Widget child, TransformInfo info) {
            //如果是最后一页，加入‘立即体验’按钮
            if (info.index == images.length - 1) {
              return getLastPage(info, context);
            }
            return new ParallaxColor(
              colors: backgroundColors,
              info: info,
              child: new Column(
                children: <Widget>[
                  new Expanded(
                      child: new ParallaxContainer(
                    child: new Image.asset(images[info.index]),
                    position: info.position,
                    opacityFactor: 1.0,
                    translationFactor: 50.0,
                  )),
                ],
              ),
            );
          }),
          itemCount: images.length),
//      new Align(
//        alignment: Alignment.bottomCenter,
//        child: new Padding(
//          padding: new EdgeInsets.only(bottom: 20.0),
//          child: new PageIndicator(
//            layout: layout,
//            size: size,
//            activeSize: activeSize,
//            controller: controller,
//            activeColor: ColorConstant.primaryColor,
//            color: Color(0XFFEfEFF4),
//            space: 6.0,
//            count: images.length,
//          ),
//        ),
//      )
    ]);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    updateFirstLaunch();
  }

  updateFirstLaunch() async {
    UserUtils.updateFirstLaunch(false);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Expanded(
                child: new Welcome(),
              ),
            ],
          ),
          Container(
            child: InkWell(
              child: Text(
                '跳过',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                AppUtils.push(context, new MainPage(),
                    replace: true, needWait: true);
              },
            ),
            margin: EdgeInsets.only(top: 40, right: 25),
            alignment: Alignment.topRight,
          )
        ],
      ),
    );
  }
}
