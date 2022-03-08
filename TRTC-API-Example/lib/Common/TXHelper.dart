import 'dart:math';

class TXHelper {
  static String generateRandomUserId() {
    String line = "";
    var rng = new Random();
    for (var i = 0; i < 6; i++) {
      int num = rng.nextInt(10);
      if (num <= 0) num = rng.nextInt(10);
      line += num.toString();
    }
    return line;
  }

  static String generateRandomStrRoomId() {
    String line = "";
    var rng = new Random();
    for (var i = 0; i < 7; i++) {
      int num = rng.nextInt(10);
      if (num <= 0) num = rng.nextInt(10);
      line += num.toString();
    }
    return line;
  }
}
