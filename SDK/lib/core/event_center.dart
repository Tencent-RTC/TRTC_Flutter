typedef EventCenterCallback = void Function(dynamic arg);

class EventCenter {
  EventCenter._newObject();
  static final EventCenter _singleton = EventCenter._newObject();
  factory EventCenter() => _singleton;
  final _messageQueue = <Object, List<EventCenterCallback>>{};

  void register(String eventName, EventCenterCallback? callback) {
    if (callback != null) {
      if (_messageQueue[eventName] == null) {
        _messageQueue[eventName] = <EventCenterCallback>[];
      }
      _messageQueue[eventName]?.add(callback);
    }
  }

  void unregister(String eventName, EventCenterCallback? callback) {
    if (callback != null) {
      var list = _messageQueue[eventName];
      if (list != null) {
        list.remove(callback);
      }
    }
  }

  void notify(String eventName, [Map<String, dynamic>? arg]) {
    var list = _messageQueue[eventName];
    if (list != null && list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        list[i](arg);
      }
    }
  }
}

const updateTextureRenderEvent = 'Update_Texture_Render_Event';
const onEnterRoomEvent = 'On_Enter_Room_Event';