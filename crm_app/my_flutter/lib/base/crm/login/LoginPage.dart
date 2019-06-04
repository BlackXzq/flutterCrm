import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter/base/crm/CommonMixin.dart';
import 'package:my_flutter/base/crm/KeyboardState.dart';
import 'package:my_flutter/base/crm/constant/ColorConstant.dart';
import 'package:my_flutter/base/crm/constant/CommonUrls.dart';
import 'package:my_flutter/base/crm/customview/ButtonFactory.dart';
import 'package:my_flutter/base/crm/customview/InputWidget.dart';
import 'package:my_flutter/base/crm/customview/Toast.dart';
import 'package:my_flutter/base/crm/customview/WidgetFactory.dart';
import 'package:my_flutter/base/crm/customview/refresh/refresh.dart';
import 'package:my_flutter/base/crm/event/LoginEvent.dart';
import 'package:my_flutter/base/crm/login/LoginRespDto.dart';
import 'package:my_flutter/base/crm/request/ApiClient.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';
import 'package:my_flutter/base/crm/login/RegisterPage.dart';
import '../customview/refresh/refresh.dart';

class LoginPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new LoginPageWidget(),
//          resizeToAvoidBottomPadding: false,
    );

    //checkbox 默认颜色
//        theme: ThemeData(unselectedWidgetColor: const Color(0xFFCDC1C1))
//    );
  }
}

class LoginPageWidget extends StatefulWidget {
  LoginPageWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends KeyboardState<LoginPageWidget> with CommonMixin {
  BuildContext dialogContext;
  double pageMargin = 40;
  double inputItemHeight = 60;

  String phoneNumber = "";
  String password = "";
  StreamSubscription subscription;

  Widget _getLoginWidget() {
    return GestureDetector(
      onTap: () {
        //隐藏键盘
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Stack(
        children: <Widget>[
          Refresh(
              child: ListView(children: <Widget>[
            Container(
              child: Text(
                '欢迎登录货好运',
                style: TextStyle(fontSize: 22, color: Color(0xff454242)),
              ),
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 50),
            ),

            SizedBox(
              height: 36,
            ),
            _getInput(
                assetIcon: "images/login_account.webp", hintText: "请输入手机号"),
            _getPassWord(
                assetIcon: "images/login_password.webp", hintText: "请输入密码"),
            SizedBox(
              height: 60,
            ),
            //登录
            _getLoginConfirmWidget(),
            SizedBox(
              height: 40,
            ),
            getHelpWidget()
          ])),
          getKeyboardWidget(Container(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "images/mine_bottom_bg.webp",
                fit: BoxFit.fill,
              ),
              height: 100,
            ),
            alignment: Alignment.bottomCenter,
          ))
        ],
      ),
    );
  }

  //注册
  _onGotoRegister() {
    AppUtils.push(context, new RegisterPage(), replace: false, needWait: true);
  }

  //忘记密码
  _onFotgetPassword() {
//    AppUtils.push(context, new PasswordResetPage(),
//        replace: false, needWait: true);
  }

  //注册账号和忘记密码
  Widget getHelpWidget() {
    return Row(
      children: <Widget>[
        Container(
          child: InkWell(
            child: Text('注册账号',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8D8D),
                    decoration: TextDecoration.underline)),
            onTap: () {
              _onGotoRegister();
            },
          ),
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 60),
          width: 100,
        ),
        Flexible(
          child: Container(),
          flex: 1,
        ),
        Container(
          child: InkWell(
            child: Text('忘记密码',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8D8D),
                    decoration: TextDecoration.underline)),
            onTap: () {
              _onFotgetPassword();
            },
          ),
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(right: 60),
          width: 100,
        ),
      ],
    );
  }

  login() {
    ApiClient apiClient = new ApiClient()
        .put("loginName", phoneNumber)
        .put("password", AppUtils.generateMd5(password));
    apiClient.post(context, CommonUrls.getLoginUrl, (map) {
      print(" register()  成功 ");
      dismissLoading();
      Future.delayed(Duration(milliseconds: 500), () {
        UserUtils.setLogin(true).then((login) {
          LoginRespDto respDto = LoginRespDto.fromJson(map);
          print(" login Success respDto " + respDto.toString());
          UserUtils.updateUser(respDto);
          AppUtils.gotoMainPage(context);
        });
      });
    }, (msg) {
      Toast.toast(context, msg);
      dismissLoading();
    }, showLoading: true);
  }

  //按钮样式
  Widget _getLoginConfirmWidget() {
    return ButtonFactory.getRoundLargeBtn(
      context,
      backgroundColor: ColorConstant.primaryColor,
      text: '登 录',
      textColor: Colors.white,
      onTap: () {
        print("_getLoginConfirmWidget");
        if (isCommitBtnEnabled()) {
          login();
        }
      },
    );
  }

  //校验
  bool isCommitBtnEnabled() {
    bool phoneNumberCheck =
        phoneNumber?.length == 11 && phoneNumber.startsWith('1');
    bool passwordCheck = password?.length >= 6;
    bool passwordEmpty = password.isEmpty;
    if (phoneNumberCheck == false) {
      Toast.toast(context, '手机号格式不正确');
      return false;
    } else if (passwordEmpty) {
      Toast.toast(context, '请输入正确密码');
      return false;
    } else if (passwordCheck == false) {
      Toast.toast(context, '密码小于6位，请重新输入');
      return false;
    }
    return true;
  }

  Widget getDivider({double height}) {
    return Container(
      color: Color(0xFFEDEEEE),
      height: height,
      margin: EdgeInsets.only(
          left: pageMargin, top: 0, right: pageMargin, bottom: 0),
    );
  }

  //带有图标和delete按键的输入框
  Widget _getInput({String assetIcon, String hintText}) {
    return InputWidget(
      underLine: true,
      autoFocus: false,
      formatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      height: inputItemHeight,
      assetLeadIcon: assetIcon,
      hintText: hintText,
      inputType: TextInputType.phone,
      margin: pageMargin,
      defaultText: phoneNumber ?? "",
      onTextChanged: (label) {
        bool update = WidgetFactory.checkNeedUpdateDelete(phoneNumber, label);
        phoneNumber = label;
        if (update) {
          setState(() {});
        }
      },
    );
  }

  Widget _getPassWord({String assetIcon, String hintText}) {
    return InputWidget(
      underLine: true,
      height: inputItemHeight,
      assetLeadIcon: assetIcon,
      hintText: hintText,
      inputType: TextInputType.text,
      margin: pageMargin,
      maxLength: 18,
      obscureText: true,
      defaultText: password ?? "",
      onTextChanged: (label) {
        bool update = WidgetFactory.checkNeedUpdateDelete(password, label);
        password = label;
        if (update) {
          setState(() {});
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initEvent(context);
    subscription = loginEevnt.on<LoginEvent>().listen((event) {
      print("isLogin " + event.isLogin.toString());
      if (event.isLogin == true) {}
    });
  }

  @override
  void dispose() {
    super.dispose();
    clearLoadingContext(context);
  }

  @override
  Widget build(BuildContext context) {
    print("LoginPage build ");
    return Scaffold(
      body: WidgetFactory.getPageBody(_getLoginWidget(), context, '登录'),
      backgroundColor: Colors.white,
//      resizeToAvoidBottomPadding: false,
    );
  }
}
