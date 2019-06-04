import 'package:event_bus/event_bus.dart';

EventBus loadingShowEventBus = new EventBus();

class LoadingShowEvent {
  //是否展示loading
  bool show;

  LoadingShowEvent(this.show);
}
