import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aj_qrscan/flutter_aj_qrscan.dart';
import 'package:my_flutter/base/crm/constant/ColorConstant.dart';
import 'package:my_flutter/base/crm/constant/CommonUrls.dart';
import 'package:my_flutter/base/crm/constant/Commons.dart';
import 'package:my_flutter/base/crm/customview/ButtonFactory.dart';
import 'package:my_flutter/base/crm/customview/InputWidget.dart';
import 'package:my_flutter/base/crm/customview/ListIndictor.dart';
import 'package:my_flutter/base/crm/customview/Toast.dart';
import 'package:my_flutter/base/crm/customview/WidgetFactory.dart';
import 'package:my_flutter/base/crm/customview/XAppBar.dart';
import 'package:my_flutter/base/crm/customview/refresh/refresh.dart';
import 'package:my_flutter/base/crm/event/LoginEvent.dart';
import 'package:my_flutter/base/crm/request/ApiClient.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/PermissionUtil.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';

class OrderSearchPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new OrderSearchPageWidget();
  }
}

class OrderSearchPageWidget extends StatefulWidget {
  OrderSearchPageWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _OrderSearchPageState();
  }
}

class orderListKeepPage extends StatefulWidget {
  int index;
  TabController controller;
  orderListKeepPage(this.index, this.controller);

  @override
  State<StatefulWidget> createState() {
    return new orderListKeepPageState();
  }
}

class orderListKeepPageState extends State<orderListKeepPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isLogin;
  String searchWaybillNo = '';

  static const scanChannel = MethodChannel(Commons.scanChannel);

  @override
  void initState() {
    super.initState();
    _initLogin();
  }

  _initLogin() async {
    await UserUtils.getLogin().then((login) {
      if (!mounted) return;
      setState(() {
        if (login == null) {
          login = false;
        }
        isLogin = login;
      });
    });
    loginEevnt.on<LoginEvent>().listen((event) {
      if (!mounted) return;

      setState(() {
        isLogin = event.isLogin;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      backgroundColor: ColorConstant.defaultPageBackgroundColor,
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _getEmptyPage() {
    int greyColor = 0xFFA7A2A2;
    //模拟未登录
    //只展示一页，而且是
    //请求登录
    Widget logoWidget = Image.asset(
      "images/search_empty.webp",
      width: 80,
      height: 80,
    );
    Widget descriptionWidget = Center(
        child: Container(
            child: Column(
              children: <Widget>[
                //当前没有寄件信息
                Text('您还没有物流跟踪~',
                    style: TextStyle(
                      color: Color(greyColor),
                      fontSize: 14,
                    ))
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            alignment: Alignment.center));
    //去登陆
    Widget loginBtn = InkWell(
        child: Container(
          width: 80,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Color(greyColor), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Text('去登录',
              style: TextStyle(
                color: Color(0xFFFFA033),
                fontSize: 12,
              )),
        ),
        onTap: () {
          UserUtils.gotoLogin(context);
        },
        borderRadius: BorderRadius.all(Radius.circular(12)));
    return new Column(
      children: <Widget>[
        logoWidget,
        SizedBox(height: 12),
        descriptionWidget,
        SizedBox(height: 20),
        loginBtn,
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  bool isOrderPage() {
    return widget.index == 1;
  }

  //扫一扫
  _onScanRequest() async {
    if (Platform.isIOS) {
      try {
        String barcode = await FlutterAjQrscan.qrscan();
        //成功回调
//        Toast.toast(context, barcode);
        _getWaybillNoByWaybillNo(barcode);
      } catch (e) {
        if (e.code == FlutterAjQrscan.CameraAccessDenied) {
          Toast.toast(context, "扫描失败,请在iOS\"设置\"-\"隐私\"-\"相机\"中开启权限");
        } else {
          Toast.toast(context, "Unknown error: $e");
        }
      }
    } else {
      List<Permission> list = [
        Permission.Camera,
      ];
      PermissionUtil.getPermissionResult(list, (pass) async {
        if (pass == false) {
          AppUtils.showCommonDialog(context,
              msg: '"相机权限获取失败,是否跳转“应用信息”>“权限”中开启相机权限？"',
              negativeMsg: '取消',
              positiveMsg: '前往', onDone: () {
            PermissionUtil.openSettings().then((openSuccess) {
              if (openSuccess != true) {}
            });
          });
        } else {
          try {
            Map<String, String> argument = new Map();
            final String result =
                await scanChannel.invokeMethod(Commons.scanMethod, argument);
            _getWaybillNoByWaybillNo(result);
            //通过订单号查物流详情 TODO
          } on PlatformException catch (e) {} finally {}
        }
      });
    }
  }

  _getWaybillNoByWaybillNo(String waybillNo) {
    if (waybillNo == null || waybillNo.isEmpty) {
      Toast.toast(context, '运单号格式不正确');
      return;
    }
//    AppUtils.push(context, OrderTraceInfoPage(waybillNo));
  }

  Widget _getSearchInputWidget() {
    return InputWidget(
      autoFocus: false,
      outLine: true,
      textCenterHorizotal: false,
      textCenterVertical: true,
      contentPaddingLeft: 15,
      deleteIconMarginRight: isOrderPage() ? 16 : 40,
      onActionWidgetTap: () {
        _onScanRequest();
      },
      actionWidget: isOrderPage()
          ? null
          : Image.asset(
              'images/scan_grey.png',
              width: 18,
              height: 18,
            ),
      actionWidgetMarginBottom: 16,
      actionWidgetMarginRight: 10,
      //默认的文字左边距小点
      outlineUnselectColor: Color(0xFFDDDDDD),
      maxLength: 25,
      hintText: isOrderPage() ? '请输入查询的订单号' : '请输入查询的运单号',
      inputType: TextInputType.text,
      defaultText: searchWaybillNo ?? "",
      onTextChanged: (label) {
        bool update =
            WidgetFactory.checkNeedUpdateDelete(searchWaybillNo, label);
        searchWaybillNo = label;
        if (update) {
          setState(() {});
        }
      },
    );
  }

  _getWaybillNoByOrderCode(String orderCode) {
//    String url = CommonUrls.getTraceInfoByOrderNoUrl;
//    ApiClient apiClient = new ApiClient().put("orderNo", orderCode);
//    apiClient.post(context, url, (map) {
//      OrderTraceRespDto traceRespDto = OrderTraceRespDto.fromJson(map);
//      if (traceRespDto != null && traceRespDto.waybillNo != null) {
//        AppUtils.push(context, OrderTraceInfoPage(traceRespDto.waybillNo));
//      } else {
//        Toast.toast(context, '查询物流详情失败');
//      }
//    }, (msg) {
//      Toast.toast(context, msg);
//    });
  }

  Widget _getLoginConfirmWidget() {
    return ButtonFactory.getRoundLargeBtn(
      context,
      backgroundColor: ColorConstant.primaryColor,
      text: '查询',
      textColor: Colors.white,
      onTap: () {
        print("_getSearchInputWidget");
        String result = searchWaybillNo.replaceAll('　', '').replaceAll(' ', '');
        if (result.isNotEmpty) {
          if (isOrderPage()) {
            _getWaybillNoByOrderCode(result);
          } else {
            _getWaybillNoByWaybillNo(result);
          }
        } else {
          if (isOrderPage()) {
            Toast.toast(context, '请输入订单号');
          } else {
            Toast.toast(context, '请输入运单号');
          }
        }
      },
    );
  }

  Widget _getBody() {
    if (isLogin == false) {
      return _getEmptyPage();
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Refresh(
          child: ListView(children: <Widget>[
        SizedBox(
          height: 28,
        ),
        _getSearchInputWidget(),
        SizedBox(
          height: 32,
        ),
        _getLoginConfirmWidget(),
      ])),
    );
  }
}

class _OrderSearchPageState extends State<OrderSearchPageWidget> {
  @override
  void dispose() {
    super.dispose();
//    if (eventBus != null) {
//      eventBus.destroy();
//    }
  }

  @override
  void initState() {
    super.initState();
    initIndicator().then((img) {
      setState(() {
        image = img;
      });
    });
  }

  static Future<ui.Image> getImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<ui.Image> initIndicator() async {
    return await getImage('images/list_indicator.webp');
  }

  ui.Image image;
  double indicatorTransX = 0;
  double indicatorTransY = 0;
  TabController tabController;
  final List<Tab> myTabs = <Tab>[
    new Tab(text: '运单号查询'),
    new Tab(text: '订单号查询'),
  ];

  Widget _getOrderSearchWidget() {
    print('EEEEEEEEEEEEEEEEEEEEEEE ------- indicatorTransX ${indicatorTransX}' +
        " indicatorTransY ${indicatorTransY}");
    return new DefaultTabController(
        length: myTabs.length,
        child: new Scaffold(
          appBar: new XAppBar(
            elevation: 2,
            backgroundColor: Colors.transparent,
            toolbarOpacity: 0.0,
            displayBackButton: false,
            backgroundAssetPath: 'images/appbar_bg.webp',
            title: Text('物流跟踪',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            bottom: new TabBar(
              tabs: myTabs,
              controller: tabController,
              isScrollable: false,
              indicator: ListIndictor(
                  image: image,
                  transX: indicatorTransX,
                  transY: indicatorTransY),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: ColorConstant.primaryColor,
              labelStyle: new TextStyle(fontSize: 16.0),
              unselectedLabelColor: Color(0xFF404040),
              unselectedLabelStyle: new TextStyle(fontSize: 16.0),
            ),
          ),
          body: new TabBarView(
            children: myTabs.map((Tab tab) {
              return new orderListKeepPage(myTabs.indexOf(tab), tabController);
            }).toList(),
            controller: tabController,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    indicatorTransX = (MediaQuery.of(context).size.width / myTabs.length -
            WidgetFactory.indicatorWidth) /
        2;
    indicatorTransY = (46 - WidgetFactory.indicatorheight);
    return Scaffold(
      body: _getOrderSearchWidget(),
      backgroundColor: ColorConstant.defaultPageBackgroundColor,
    );
//    return Scaffold(
////      appBar: CustomAppBar.getAppBar(context, '物流跟踪', displayBackButton: false),
//      body: WidgetFactory.getPageBody(_getBody(), context, '物流跟踪',
//          displayBackButton: false),
//      backgroundColor: ColorConstant.defaultPageBackgroundColor,
//      resizeToAvoidBottomPadding: false,
//    );
  }
}
