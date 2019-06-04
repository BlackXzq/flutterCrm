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
import 'package:my_flutter/base/crm/login/LoginRespDto.dart';
import 'package:my_flutter/base/crm/request/ApiClient.dart';
import 'package:my_flutter/base/crm/utils/AppUtils.dart';
import 'package:my_flutter/base/crm/utils/UserUtils.dart';

void main() => runApp(new RegisterPage());

class RegisterPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new RegisterPageWidget(),
//          resizeToAvoidBottomPadding: false,
    );

    //checkbox 默认颜色
//        theme: ThemeData(unselectedWidgetColor: const Color(0xFFCDC1C1)));
  }
}

class RegisterPageWidget extends StatefulWidget {
  RegisterPageWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _RegisterPageState();
  }
}

class _RegisterPageState extends KeyboardState<RegisterPageWidget>
    with CommonMixin {
  bool agree = false;
  double pageMargin = 40;
  double inputItemHeight = 60;

  String verifyHint = "获取验证码";
  String phoneNumber = "";
  String verifyCode = "";
  String password = "";
  Timer _countdownTimer;
  int totalSeconds = 59;
  int _countdownNum = 59;
  BuildContext dialogContext;
  @override
  void dispose() {
    super.dispose();
    clearLoadingContext(context);
    print('dispose is ');
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void register() {
    ApiClient apiClient = new ApiClient()
        .put("loginName", phoneNumber)
        .put("code", verifyCode)
        .put("password", AppUtils.generateMd5(password));
    apiClient.post(context, CommonUrls.getRegisterUrl, (map) {
      print(" register()  成功 ");
      Future.delayed(Duration(milliseconds: 500), () {
        UserUtils.setLogin(true).then((login) {
          LoginRespDto respDto = LoginRespDto.fromJson(map);
          UserUtils.updateUser(respDto);
          AppUtils.gotoMainPage(context);
        });
      });
    }, (msg) {
      Toast.toast(context, msg);
    }, showLoading: true);
  }

  void getVerifyCode() {
    if (_countdownTimer != null) {
      return;
    }
    if (phoneNumber == null || phoneNumber.isEmpty) {
      Toast.toast(context, '手机号格式不正确');
      return;
    }
    ApiClient apiClient =
        new ApiClient().put("loginName", phoneNumber).put("codeType", 1);
    apiClient.post(context, CommonUrls.getVerifyCodeUrl, (map) {
      print(" getVerifyCode ");
      getCountdownTimer();
    }, (msg) {
      Toast.toast(context, msg);
    }, showLoading: true);
  }

  void getCountdownTimer() {
    setState(() {
      if (_countdownTimer != null) {
        return;
      }
      verifyHint = '${_countdownNum--}S';
      _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
        setState(() {
          if (_countdownNum > 0) {
            verifyHint = '${_countdownNum--}S';
          } else {
            verifyHint = '获取验证码';
            _countdownNum = totalSeconds;
            _countdownTimer.cancel();
            _countdownTimer = null;
          }
        });
      });
    });
  }

  Widget _getRegisterWidget() {
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
                '欢迎注册车好运',
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
            _getVerifyCode(
                assetIcon: "images/login_password.webp", hintText: "请输入验证码"),
            _getPassWord(
                assetIcon: "images/login_password.webp", hintText: "请输入密码"),
            //协议
            _getProtocalWidget(),
            SizedBox(
              height: 40,
            ),
            //登录
            _getRegisterConfirmWidget(),
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

  //按钮样式
  Widget _getRegisterConfirmWidget() {
    return ButtonFactory.getRoundLargeBtn(
      context,
      backgroundColor: ColorConstant.primaryColor,
      text: '注 册',
      textColor: Colors.white,
      onTap: () {
        if (isCommitBtnEnabled() && isAllowRegister()) {
          print("_getRegisterConfirmWidget");
          register();
        }
      },
    );
  }

  //校验
  bool isCommitBtnEnabled() {
    bool phoneNumberCheck = phoneNumber != null &&
        phoneNumber.startsWith('1') &&
        phoneNumber?.length == 11;
    bool verifyCodeCheck = verifyCode?.length == 6;
    bool verifyEmpty = verifyCode.isEmpty;
    bool passwordCheck = password?.length >= 6;
    bool passwordEmpty = password.isEmpty;
    //校验
    if (phoneNumberCheck == false) {
      Toast.toast(context, '手机号格式不正确');
      return false;
    } else if (verifyEmpty) {
      Toast.toast(context, '请输入正确验证码');
      return false;
    } else if (verifyCodeCheck == false) {
      Toast.toast(context, '验证码小于6位，请重新输入');
      return false;
    } else if (passwordEmpty) {
      Toast.toast(context, '请输入正确密码');
    } else if (passwordCheck == false) {
      Toast.toast(context, '密码小于6位，请重新输入');
      return false;
    }
    return true;

    return phoneNumberCheck == true &&
        verifyCodeCheck == true &&
        passwordCheck == true;
  }

  bool isAllowRegister() {
    if (agree == false) {
      Toast.toast(context, '请同意并勾选《注册协议条款》');
      return false;
    }
    return true;
  }

  //协议部分widget
  Widget _getProtocalWidget() {
    return Container(
      child: Row(
        children: <Widget>[
          Checkbox(
            value: agree,
            checkColor: Colors.white,
            activeColor: ColorConstant.selectedWidgetColor,
            onChanged: (bool value) {
              setState(() {
                agree = value;
              });
            },
          ),
          Text(
            '我已阅读并同意',
            style: TextStyle(color: ColorConstant.hintColor, fontSize: 13),
          ),
          Expanded(
              child: InkWell(
            child: Text(
              '《注册协议条款》',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  color: ColorConstant.selectedWidgetColor, fontSize: 13),
            ),
            onTap: () {
              List<String> assetPaths = [];
              assetPaths.add('images/register_protocal1.webp');
              assetPaths.add('images/register_protocal2.webp');
              //AppUtils.push(context, new ProductDetailPage('注册协议', assetPaths));
            },
          ))
        ],
      ),
      margin: EdgeInsets.only(left: pageMargin - 10, right: pageMargin),
    );
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

  Widget getActionWidget() {
    return Container(
      width: 90,
      height: 26,
      child: Row(
        children: <Widget>[
          Align(
            child: SizedBox(
              width: 0.8,
              height: inputItemHeight / 3,
              child: Container(
                color: ColorConstant.hintColor,
              ),
            ),
            alignment: Alignment.center,
          ),
          Expanded(
              child: Align(
            child: Text(
              verifyHint,
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
            alignment: Alignment.center,
          ))
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _getVerifyCode({String assetIcon, String hintText}) {
    return InputWidget(
        underLine: true,
        formatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        height: inputItemHeight,
        assetLeadIcon: assetIcon,
        actionWidget: getActionWidget(),
        deleteIconMarginRight: 104,
        hintText: hintText,
        inputType: TextInputType.phone,
        margin: pageMargin,
        maxLength: 6,
        defaultText: verifyCode ?? "",
        onTextChanged: (label) {
          bool update = WidgetFactory.checkNeedUpdateDelete(verifyCode, label);
          verifyCode = label;
          if (update) {
            setState(() {});
          }
        },
        onActionWidgetTap: () {
          print("onActionWidgetTap");
          bool phoneNumberCheck = phoneNumber != null &&
              phoneNumber.startsWith('1') &&
              phoneNumber?.length == 11;
          if (phoneNumberCheck == true) {
            getVerifyCode();
          } else {
            Toast.toast(context, '手机号格式不正确 ');
          }
        });
  }

  //倒计时

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: CustomAppBar.getAppBar(context, '注册'),
      body: WidgetFactory.getPageBody(_getRegisterWidget(), context, '注册'),
      backgroundColor: Colors.white,
//      resizeToAvoidBottomPadding: false,
    );
  }
}
