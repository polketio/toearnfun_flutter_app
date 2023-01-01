import 'package:hash/hash.dart';
import 'package:toearnfun_flutter_app/utils/bytes.dart';

class Hash {

  static String ripemd160(String msg) {
    var dec = Hex.decode(msg);
    final hash = RIPEMD160().update(dec).digest();
    return Hex.encode(hash);
  }

  static String sha256(String msg) {
    var dec = Hex.decode(msg);
    final hash = SHA256().update(dec).digest();
    return Hex.encode(hash);
  }
}
