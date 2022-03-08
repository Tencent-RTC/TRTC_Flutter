import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class TitleUpdateEvent {
  String pageTitle;
  TitleUpdateEvent(this.pageTitle);
}
