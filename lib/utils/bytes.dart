import 'dart:typed_data';

Uint8List int32Bytes(int value, [Endian endian = Endian.big]) =>
    Uint8List(4)..buffer.asByteData().setInt32(0, value, endian);

Uint8List int16Bytes(int value, [Endian endian = Endian.big]) =>
    Uint8List(2)..buffer.asByteData().setInt16(0, value, endian);

Uint8List int8Bytes(int value) =>
    Uint8List(1)..buffer.asByteData().setInt8(0, value);

class Hex {
  /// hex encode
  static String encode(List<int> bytes) {
    var str = '';
    for (var i = 0; i < bytes.length; i++) {
      var s = bytes[i].toRadixString(16);
      str += s.padLeft(2, '0');
    }
    return str;
  }

  /// hex decode
  static List<int> decode(String hex) {
    if (hex.contains("0x", 0)) {
      hex = hex.replaceFirst("0x", "", 0);
    }
    var bytes = <int>[];
    var len = hex.length ~/ 2;
    for (var i = 0; i < len; i++) {
      bytes.add(int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
    }
    return bytes;
  }
}
