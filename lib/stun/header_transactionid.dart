part of hetimanet_stun;

class StunTransactionID {
  static const List<int> rfc5389MagicCookie = const [0x21, 0x12, 0xA4, 0x42];
  List<int> value;
  static math.Random _random = new math.Random();

  StunRfcVersion rfcVersion() {
    for (int i = 0; i < 4; i++) {
      if (value[i] != rfc5389MagicCookie[i]) {
        return StunRfcVersion.ref3489;
      }
    }
    return StunRfcVersion.ref5389;
  }

  StunTransactionID.random() {
    value = [];
    for (int i = 0; i < 16; i++) {
      value.add(_random.nextInt(0xFF));
    }
  }

  StunTransactionID.randomRFC5389() {
    value = [];
    int i = 0;
    for (; i < 4; i++) {
      value.add(rfc5389MagicCookie[i]);
    }

    for (; i < 16; i++) {
      value.add(_random.nextInt(0xFF));
    }
  }

  StunTransactionID._empty() {}

  static StunTransactionID decode(List<int> buffer, int start) {
    StunTransactionID ret = new StunTransactionID._empty();
    ret.value = [];
    for (int i = 0; i < 16; i++) {
      ret.value.add(buffer[start + i]);
    }
    return ret;
  }

  @override
  String toString() {
    StringBuffer b = new StringBuffer();
    for (int i in value) {
      String t = i.toRadixString(16);
      b.write(t);
      if (t.length == 1) {
        b.write("0");
      }
    }
    return b.toString();
  }

  int get hashCode {
    int result = 0;
    for (int i in value) {
      result = 37 * result + i.hashCode;
    }
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunTransactionID)) {
      return false;
    }
    StunTransactionID p = o;
    for (int i = 0; i < value.length; i++) {
      if (value[i] != p.value[i]) {
        return false;
      }
    }
    return true;
  }

  List<int> magicCookie() {
    List<int> ret = [];
    for (int i = 0; i < 4; i++) {
      ret.add(value[i]);
    }
    return ret;
  }

}
