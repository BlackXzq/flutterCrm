import 'dart:io';
import 'dart:ui';

import 'package:aj_flutter_plugin/aj_flutter_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_bottom_tab_bar/eachtab.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_flutter/base/crm/CommonMixin.dart';
import 'package:my_flutter/base/crm/constant/ColorConstant.dart';
import 'package:my_flutter/base/crm/constant/Commons.dart';
import 'package:my_flutter/base/crm/constant/RouteConstant.dart';
import 'package:my_flutter/base/crm/customview/Toast.dart';
import 'package:my_flutter/base/crm/event/LoginEvent.dart';
import 'package:my_flutter/base/crm/event/PageSnapEvent.dart';
import 'package:my_flutter/base/crm/home/HomePage.dart';
import 'package:my_flutter/base/crm/login/LoginPage.dart';
import 'package:my_flutter/base/crm/utils/Localizations.dart';
import 'package:my_flutter/base/crm/search/OrderSearchPage.dart';
import 'home/HomePage.dart';
import 'utils/StatusbarUtil.dart';

void main() => runApp(new MainPage());

class MainPage extends StatelessWidget {
  //多语言参考
  List<Locale> an = [
    const Locale('zh', 'CH'),
    const Locale('en', 'US'),
  ];
  List<Locale> ios = [
    const Locale('en', 'US'),
    const Locale('zh', 'CH'),
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//    return  new MyHomePage(title: 'Flutter Demo Home Page');
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
      theme: ThemeData(
        unselectedWidgetColor: const Color(0xFFCDC1C1),
        platform: TargetPlatform.iOS,
      ),
      routes: <String, WidgetBuilder>{
        RouteConstant.Homepage: (BuildContext context) => new MainPage(),
        RouteConstant.LoginPage: (BuildContext context) => new LoginPage(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        ChineseCupertinoLocalizations.delegate,
      ],
      supportedLocales: Platform.isIOS ? ios : an,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _MyHomePageState();
  }
}

class MyTabController extends TabController {
  @override
  void animateTo(int value,
      {Duration duration = kTabScrollDuration, Curve curve = Curves.ease}) {
    super.animateTo(value,
        duration: const Duration(milliseconds: 1), curve: curve);
  }
}

class _MyHomePageState extends State<MyHomePage>
    with
        CommonMixin,
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  int firstBackPressTime = 0;
  static const platformExitChannel =
      const MethodChannel(Commons.exitAppChannel);

  PageView pageView;
  Duration duration1, duration2;

  //普通图标的大小
  double iconSize = 20.0;

  //导航条的高度
  double naviBarHeight = 60.0;
  double naviBarContentHeight = 49.0;
  Color textHintColor = Color(0xFF6B6B6B);
  Color textActiveColor = Color(0xFFF59800);

  //导航的标题
  List<String> titles = ['首页', '查询', '在线客服', '我的'];

  //导航条背景图
  String naviBgAsset = "images/navi_bg.webp";

  //首页图标
  String homeSelectAsset = 'images/ico_homeselect.webp';
  String homeUnSelectAsset = 'images/ico_homeunselect.webp';

  //查询图标
  String searchSelectAsset = 'images/ico_searchselect.webp';
  String searchUnSelectAsset = 'images/ico_searchunselect.webp';

  //服务热线图标
  String servicecallSelectAsset = 'images/ico_serviceselect.webp';
  String servicecallUnSelectAsset = 'images/ico_serviceunselect.webp';

  //我的图标
  String mineSelectAsset = 'images/ico_userselect.webp';
  String mineUnSelectAsset = 'images/ico_userunselect.webp';

  TabController _tabController;
  int _selectedIndex = 0;

  @override
  bool get wantKeepAlive => true;

  EachTab getEachTab(int position, String title, String activeIconPath,
      String defaultIconPath) {
    return EachTab(
        height: naviBarContentHeight - 8,
        padding: EdgeInsets.all(0),
        icon: _selectedIndex == position
            ? Image.asset(
                activeIconPath,
                width: iconSize,
                height: iconSize,
              )
            : Image.asset(
                defaultIconPath,
                width: iconSize,
                height: iconSize,
              ),
        text: title,
        iconPadding: EdgeInsets.fromLTRB(0, 0, 0, 2),
        textStyle: TextStyle(fontSize: 10));
  }

  void onTap(int index) {}

  Widget getTabView() {
    return Container(
      child: new TabBar(
        isScrollable: false,
        controller: _tabController,
        indicatorColor: Colors.transparent,
        labelColor: textActiveColor,
        labelPadding: EdgeInsets.all(0),
        unselectedLabelColor: textHintColor,
        onTap: onTap,
        tabs: <Widget>[
          getEachTab(0, titles[0], homeSelectAsset, homeUnSelectAsset),
          getEachTab(1, titles[1], searchSelectAsset, searchUnSelectAsset),
          getEachTab(
              2, titles[2], servicecallSelectAsset, servicecallUnSelectAsset),
          getEachTab(3, titles[3], mineSelectAsset, mineUnSelectAsset),
        ],
      ),
      color: Colors.white,
      height: naviBarHeight,
    );
  }

  Widget getNewPageView() {
    return Scaffold(
      bottomNavigationBar: SafeArea(
          child: Container(
        height: naviBarHeight,
        child: Stack(
          children: <Widget>[getTabView()],
        ),
      )),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(), //设置滑动的效果，这个禁用滑动
        controller: _tabController,
        //四个一级页面
        children: <Widget>[
          HomePage(),
          OrderSearchPage(),
          HomePage(),
          HomePage(),
        ],
      ),
    );
  }

  _requestStatusBarColor() {
    StatusbarUtil.setStatusBarLight(color: Colors.transparent);
  }

  //收到通知，跳转到哪一页
  _init() {
    loginEevnt.on<PageSnapEvent>().listen((event) {
      if (event.snap) {
        _tabController.animateTo(1);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //版本更新提示
    getVersionCode(context, needToast: false);
    _init();
    _tabController =
        new TabController(vsync: this, initialIndex: 0, length: titles.length);
    _tabController.addListener(() {
      _requestStatusBarColor();
      if (!mounted) {
        return;
      }
      setState(() => _selectedIndex = _tabController.index);
    });
    _requestStatusBarColor();
  }

  void snapToAddOrderPage() {
    setState(() {
      print("snapToAddOrderPage");
    });
  }

  Widget getMainWidget() {
    if (Platform.isAndroid) {
      return WillPopScope(
        child: getNewPageView(),
        onWillPop: () {
          int secondTime = new DateTime.now().millisecondsSinceEpoch;
          if (secondTime - firstBackPressTime > 2000) {
            //退出到桌面
            Toast.toast(context, '再按一次返回键回到桌面');
            firstBackPressTime = secondTime; // 更新firstTime
          } else {
            // 如果两次按键时间间隔小于2秒，退到桌面
            exitApp();
          }
        },
      );
    } else {
      return getNewPageView();
    }
  }

  int nowTime;
  @override
  Widget build(BuildContext context) {
    return getMainWidget();
  }
}
