part of hetimanet_stun;

class StunErrorCodeAttribute extends StunAttribute {
  static const int code400BadRequest = 400;
  static const int code401Unauthorized = 401;
  static const int code420UnknownAttribute = 420;
  static const int code430StaleCredentials = 430;
  static const int code431IntegrityCheckFailure = 431;
  static const int code432MissingUsername = 432;
  static const int code433UseTLS = 433;
  static const int code500ServerError = 500;
  static const int code600GlobalFailure = 600;

  int type; //2byte
  int get length => 4+conv.UTF8.encode(pharse).length; //2byte

  int code;
  String pharse;
  StunErrorCodeAttribute(this.code, this.pharse) {
    type = StunAttribute.errorCode;
  }

  @override
  String toString() {
    Map t = {};
    t["type"] = StunAttribute.toStringFromType(type);
    t["length"] = length;
    t["code"] = code;
    t["pharse"] = pharse;
    return "${t}";
  }

  Uint8List encode() {
    List<int> buffer = [];
    List<int> pharseBytes = conv.UTF8.encode(pharse);
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrderType.BigEndian));
    buffer.addAll(core.ByteOrder.parseShortByte(4 + pharseBytes.length, core.ByteOrderType.BigEndian));
    int v = 0;
    v |= (code ~/ 100) << 8;
    v |= (code % 100);
    buffer.addAll(core.ByteOrder.parseIntByte(v, core.ByteOrderType.BigEndian));
    buffer.addAll(pharseBytes);
    return new Uint8List.fromList(buffer);
  }

  static StunErrorCodeAttribute decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrderType.BigEndian);
    if (type != StunAttribute.errorCode) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrderType.BigEndian);
    int v = core.ByteOrder.parseInt(buffer, start + 4, core.ByteOrderType.BigEndian);
    int clazz = (v >> 8) & 0x07;
    int nzzber = v & 0xff;
    String pharse = conv.UTF8.decode(buffer.sublist(start + 8, start + 8 + tlength - 4), allowMalformed: true);

    return new StunErrorCodeAttribute(clazz * 100 + nzzber, pharse);
  }

  int get hashCode {
    int result = type.hashCode;
    result = 37 * result + code.hashCode;
    result = 37 * result + pharse.hashCode;
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunErrorCodeAttribute)) {
      return false;
    }
    StunErrorCodeAttribute p = o;
    return (type == p.type && code == p.code && pharse == p.pharse);
  }
}
