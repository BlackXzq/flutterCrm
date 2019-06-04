import 'package:event_bus/event_bus.dart';

EventBus logoutEvent = new EventBus();

class LogoutEvent {
  //是否登出
  bool logout;

  LogoutEvent(this.logout);
}

