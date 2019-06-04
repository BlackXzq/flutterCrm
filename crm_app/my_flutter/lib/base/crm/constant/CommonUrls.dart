//接口路径在这里
class CommonUrls {
  //测试
  static const String RootHost = "http://10.108.6.117:9021/";

  //登录
  static const String getLoginUrl = RootHost + "ftp/auth/user/login";

  //版本更新
  static const String getVersionUpdateUrl =
      RootHost + "ftp/auth/app/getNewAppVersion";

  //获取验证码
  static const String getVerifyCodeUrl =
      RootHost + "ftp/auth/user/public/getCode";

  //注册
  static const String getRegisterUrl =
      RootHost + "ftp/auth/user/public/register";
}
