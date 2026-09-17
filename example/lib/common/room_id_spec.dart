/// Encapsulates the two mutually-related room-id fields used by TRTC:
/// - [roomId]: numeric room ID (`TRTCParams.roomId`). Digits only.
/// - [strRoomId]: string room ID (`TRTCParams.strRoomId`). Letters/digits/symbols.
///
/// At least one of the two must be non-empty/non-zero. When both are
/// provided, [roomId] takes priority, matching the SDK's own behavior
/// (see [TRTCParams.roomId] docs: "If both are entered, roomId will be used").
class RoomIdSpec {
  /// Numeric room ID. `0` means "not set".
  final int roomId;

  /// String room ID. Empty string means "not set".
  final String strRoomId;

  const RoomIdSpec({this.roomId = 0, this.strRoomId = ''});

  /// Whether at least one of [roomId] / [strRoomId] has a usable value.
  bool get isValid => roomId > 0 || strRoomId.isNotEmpty;

  /// The room ID value to send as `TRTCParams.roomId`.
  /// Following the "roomId takes priority" rule, this simply returns [roomId].
  int get effectiveRoomId => roomId;

  /// The room ID value to send as `TRTCParams.strRoomId`.
  /// Cleared out whenever [roomId] is set, since the two must not be mixed.
  String get effectiveStrRoomId => roomId > 0 ? '' : strRoomId;

  /// A human-readable room id, preferring the numeric one, used for display.
  String get display => roomId > 0 ? roomId.toString() : strRoomId;

  @override
  String toString() => 'RoomIdSpec(roomId: $roomId, strRoomId: $strRoomId)';
}
