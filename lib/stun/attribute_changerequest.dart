part of hetimanet_stun;

class StunChangeRequestAttribute extends StunAttribute {
  int type; //2byte
  int get length => 4; //32bit 4byte
  bool changeIP;
  bool changePort;

  @override
  String toString() {
    Map t = {};
    t["type"] = StunAttribute.toStringFromType(type);
    t["length"] = length;
    t["changeIP"] = changeIP;
    t["changePort"] = changePort;
    return "${t}";
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrderType.BigEndian));
    buffer.addAll(core.ByteOrder.parseShortByte(length, core.ByteOrderType.BigEndian));
    int v = 0;
    v |= (changePort == true ? (0x01 << 1) : 0);
    v |= (changeIP == true ? (0x01 << 2) : 0);
    buffer.addAll(core.ByteOrder.parseIntByte(v, core.ByteOrderType.BigEndian));
    return new Uint8List.fromList(buffer);
  }

  static StunChangeRequestAttribute decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrderType.BigEndian);
    if (StunAttribute.changeRequest != type) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrderType.BigEndian);
    if (tlength != 4) {
      throw {"mes": ""};
    }
    int v = core.ByteOrder.parseInt(buffer, start + 4, core.ByteOrderType.BigEndian);
    bool changePort = (v & (0x01 << 1) != 0);
    bool changeIP = (v & (0x01 << 2) != 0);

    return new StunChangeRequestAttribute(changeIP, changePort);
  }

  StunChangeRequestAttribute(this.changeIP, this.changePort) {
    type = StunAttribute.changeRequest;
  }

  int get hashCode {
    int result = type.hashCode;
    result = 37 * result + changeIP.hashCode;
    result = 37 * result + changePort.hashCode;
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunChangeRequestAttribute)) {
      return false;
    }
    StunChangeRequestAttribute p = o;
    return (type == p.type && changeIP == p.changeIP && changePort == p.changePort);
  }
}
