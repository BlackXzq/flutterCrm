import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:amap_base_location/amap_base_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter/base/crm/CommonMixin.dart';
import 'package:my_flutter/base/crm/constant/ColorConstant.dart';
import 'package:my_flutter/base/crm/constant/Commons.dart';
import 'package:my_flutter/base/crm/constant/UserContant.dart';
import 'package:my_flutter/base/crm/customview/CarouselSlider.dart';
import 'package:my_flutter/base/crm/customview/Toast.dart';
import 'package:my_flutter/base/crm/event/LoginEvent.dart';
import 'package:my_flutter/base/crm/event/PageSnapEvent.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/PermissionUtil.dart';
import 'package:my_flutter/base/crm/login/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter/base/crm/customview/FrameAnimationImage.dart';
import 'package:aj_flutter_plugin/aj_flutter_plugin.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';

class HomePage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new HomePageWidget(),
      backgroundColor: ColorConstant.defaultPageBackgroundColor,
    );
  }
}

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePageWidget>
    with
        AutomaticKeepAliveClientMixin,
        CommonMixin,
        SingleTickerProviderStateMixin {
  AMapLocation _amapLocation;

  @override
  bool get wantKeepAlive => true;
  StreamSubscription subscription;

  static const scanChannel = MethodChannel(Commons.scanChannel);

  _getVersionName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("versionCoode is " +
        sharedPreferences.get(UserContant.versionName).toString());
  }

  //要测试定位，Android版本记得从app run，
  // 不要用flutter run，appKey在manifest里配置，还有main.dart配置
  _getLocation() async {
    if (Platform.isIOS) {
      int localState = await AjFlutterPlugin.getLocationPermissions();
      if (localState == 2 || localState == 1) {
        getLocationData();
      } else {
        AppUtils.showCommonDialog(context,
            msg: '定位失败,请在iOS\"设置\"-\"隐私\"-\"定位服务\"中开启定位权限',
            negativeMsg: '取消',
            positiveMsg: '确定',
            onDone: () {});
      }
    } else {
      List<Permission> list = [
        Permission.AccessCoarseLocation,
      ];
      PermissionUtil.getPermissionResult(list, (pass) async {
        if (pass == false) {
          AppUtils.showCommonDialog(context,
              msg: '"定位失败,是否跳转“应用信息”>“权限”中开启定位权限？"',
              negativeMsg: '取消',
              positiveMsg: '前往', onDone: () {
            PermissionUtil.openSettings().then((openSuccess) {
              if (openSuccess != true) {}
            });
          });
        } else {
          //打开定位服务
          PermissionUtil.openGpsService();
          getLocationData();
        }
      });
    }
  }

  getLocationData() {
    final options = LocationClientOptions(
      isOnceLocation: true,
      locatingWithReGeocode: true,
    );
    _amapLocation.getLocation(options).then((location) {
      if (location == null) {
        Toast.toast(context, '定位失败');
        return;
      } else if (location.adCode == null || location.adCode.isEmpty) {
        Toast.toast(context, location.errorInfo ?? '定位失败');
        return;
      } else {
        Toast.toast(context, '定位成功,当前位置: ' + location.address);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _amapLocation = AMapLocation();
    _getVersionName();
  }

  @override
  void dispose() {
    super.dispose();
    _amapLocation.stopLocate();
    print('dispose');
  }

  //是否登录
  bool login = false;

  //是否有物流信息
  bool hasTransportInfo = false;
  double iconSize = 30.0;
  double bigIconSize = 68.0;
  Color textHintColor = Color(0xFF6B6B6B);
  Color textActiveColor = Color(0xFFF59800);
  double extraChildWidth = 104;
  double pageMargin = 5;
  double scale = 0.92;

  //搜索
  _onSearchRequest() {
    loginEevnt.fire(PageSnapEvent(true));
  }

  //Banner展示
  Widget _getBanner() {
    return Stack(children: <Widget>[
      Container(
          //banner高度
          height: MediaQuery.of(context).size.width * 702 / 1125,
          width: MediaQuery.of(context).size.width,
          child: Image.asset(
            "images/home_banner.webp",
            fit: BoxFit.cover,
          )),
      Align(
        child: Container(
          width: 40,
          height: 40,
          child: InkWell(
            child: Container(
              width: 40,
              height: 40,
              child: Image.asset(
                "images/scan.webp",
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              alignment: Alignment.center,
            ),
            onTap: () {
//              AppUtils.onLoginCheckDialog(context, null,
//                  msg: '是否登录后扫描？', function: () {});
              AppUtils.push(context, LoginPage());
            },
          ),
          alignment: Alignment.center,
          margin: EdgeInsets.only(
              left: 6, top: 8 + MediaQuery.of(context).padding.top),
        ),
        alignment: Alignment.centerLeft,
      ),
      Align(
        child: Container(
          width: 40,
          height: 40,
          child: InkWell(
            child: Container(
              width: 40,
              height: 40,
              child: Image.asset(
                "images/search.webp",
                width: 20,
                height: 20,
              ),
              alignment: Alignment.center,
            ),
            onTap: () {
              _onSearchRequest();
            },
          ),
          alignment: Alignment.center,
          margin: EdgeInsets.only(
              right: 6, top: 8 + MediaQuery.of(context).padding.top),
        ),
        alignment: Alignment.centerRight,
      )
    ]);
  }

  Widget _getEmptyTransportInfo() {
    int greyColor = 0xFFA7A2A2;
    //模拟未登录
    //只展示一页，而且是
    //请求登录
    Widget logoWidget = Image.asset(
      "images/home_transportinfo_empty.webp",
      width: 40,
      height: 40,
    );
    Widget descriptionWidget = Center(
        child: Container(
            child: Column(
              children: <Widget>[
                //当前没有寄件信息
                Text('当前没有寄件状态',
                    style: TextStyle(
                      color: Color(greyColor),
                      fontSize: 12,
                    )),
                Text('最近快递信息展示在此',
                    style: TextStyle(
                      color: Color(greyColor),
                      fontSize: 12,
                    ))
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            alignment: Alignment.center));
    //去登陆
    Widget loginBtn = InkWell(
        child: Container(
          width: 60,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
                color: Color(
                  0xFFECEEEE,
                ),
                width: 1),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Text('登录',
              style: TextStyle(
                color: Color(0xFFFFA033),
                fontSize: 12,
              )),
        ),
        onTap: () {
          AppUtils.push(context, LoginPage());
        },
        borderRadius: BorderRadius.all(Radius.circular(bigIconSize / 2)));
    return Container(
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            logoWidget,
            descriptionWidget,
            loginBtn,
          ]),
      color: Colors.white,
    );
  }

  Widget _getSwiperItem() {
    return _getEmptyTransportInfo();
  }

  Widget getCarouselSwiper() {
    return null;
  }

  Widget getBaseSliderContainer(Widget child) {
    //阴影系数
    double elevation = 2.0;
    //阴影颜色
    Color shadowColor = Color(0x66000000);

    double contentMargin = login && hasTransportInfo ? 18 : 6;
    return Container(
        child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Material(
              elevation: elevation,
              shadowColor: shadowColor,
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                margin: EdgeInsets.only(
                    top: contentMargin,
                    right: contentMargin,
                    left: contentMargin),
                child: child,
              ),
            )));
  }

  List<Widget> getSliderItems() {
    List<Widget> list = [];
    //阴影系数
    double elevation = 2.0;
    //阴影颜色
    Color shadowColor = Color(0x66000000);
    double contentMargin = 18;
    Widget widget = Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(right: pageMargin, left: pageMargin),
        child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Material(
              elevation: elevation,
              shadowColor: shadowColor,
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                margin: EdgeInsets.only(
                    top: contentMargin,
                    right: contentMargin,
                    left: contentMargin),
                child: _getSwiperItem(),
              ),
            )));
    list.add(widget);
    list.add(widget);
    list.add(widget);
    return list;
  }

  //获取最近详情
  Widget _getSwiper() {
    //最近物流，每一页距离顶部
    double margin = 150;
    double _textScaleFactor = MediaQuery.of(context).textScaleFactor;
    //最近物流，每一页的高度
    double height = 142 + 50 * (_textScaleFactor - 1);
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        margin: EdgeInsets.only(top: margin),
        child: CarouselSlider(
          height: height,
          autoPlay: false,
          pageWidth: screenWidth,
          extraWidth: extraChildWidth,
          pageMargin: pageMargin,
          scale: scale,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          viewportFraction: scale,
          onPageChanged: (pos) {},
          items: getSliderItems(),
        ));
  }

  //Test
  Widget getPageIndicatorSwiper() {
    return Container(
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            // 用Container实现图片圆角的效果
            decoration: BoxDecoration(
              image: DecorationImage(
                image: new AssetImage(
                  "images/banner_default1.jpg",
                ), // 图片数组
                fit: BoxFit.cover,
              ), // 图片数组
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            height: 180,
          );
        },
        itemCount: 3,
        loop: false,
        viewportFraction: 0.8,
        scale: 0.9,
        containerHeight: 180,
        pagination: new SwiperPagination(),
        indicatorLayout: PageIndicatorLayout.SCALE,
      ),
      height: 180,
    );
  }

  Widget getBody() {
    return new ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: <Widget>[
          Stack(
            children: <Widget>[_getBanner(), _getSwiper()],
          ),
          _buildGif(),
          getPageIndicatorSwiper(),
          getLocationWidget()
        ]);
  }

  Widget _buildGif() {
    List<String> _assetList = [];
    _assetList.add('images/loading00.png');
    _assetList.add('images/loading01.png');
    _assetList.add('images/loading02.png');
    _assetList.add('images/loading03.png');
    _assetList.add('images/loading04.png');
    _assetList.add('images/loading05.png');
    _assetList.add('images/loading06.png');

    _assetList.add('images/loading07.png');
    _assetList.add('images/loading08.png');
    _assetList.add('images/loading09.png');
    _assetList.add('images/loading10.png');
    _assetList.add('images/loading11.png');
    _assetList.add('images/loading12.png');
    _assetList.add('images/loading13.png');
    _assetList.add('images/loading14.png');
    _assetList.add('images/loading15.png');
    _assetList.add('images/loading16.png');
    _assetList.add('images/loading17.png');
    _assetList.add('images/loading18.png');
    _assetList.add('images/loading19.png');
    return Center(
        child: FrameAnimationImage(
      _assetList,
      width: 100,
      height: 100,
    ));
  }

  //定位
  Widget getLocationWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60, bottom: 60),
        child: InkWell(
          child: Text('定位'),
          onTap: () {
            _getLocation();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('HomePage build ');
    return getBody();
  }
}
