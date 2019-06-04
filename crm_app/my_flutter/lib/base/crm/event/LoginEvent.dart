import 'package:event_bus/event_bus.dart';

EventBus loginEevnt = new EventBus();

class LoginEvent {
  //是否登录
  bool isLogin;

  LoginEvent(this.isLogin);
}

