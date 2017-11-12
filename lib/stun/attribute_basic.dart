part of hetimanet_stun;

class StunBasicAttribute extends StunAttribute {
  static const int fingerPrintXorValue = 0x5354554e;

  int type; //2byte
  int get length => value.length; //32bit 4byte
  List<int> value = [];

  StunBasicAttribute(this.type, List<int> v) {
    value.addAll(v);
  }


  @override
  String toString() {
    Map t = {};
    t["type"] = StunAttribute.toStringFromType(type);
    t["length"] = length;
    t["value"] = value.toString();
    return "${t}";
  }

  String toUTF8() {
    return conv.UTF8.decode(value, allowMalformed: true);
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrderType.BigEndian));
    buffer.addAll(core.ByteOrder.parseShortByte(value.length, core.ByteOrderType.BigEndian));
    buffer.addAll(value);
    return new Uint8List.fromList(buffer);
  }

  static StunBasicAttribute decode(List<int> buffer, int start) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrderType.BigEndian);
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrderType.BigEndian);

    if (type == StunAttribute.userName || type == StunAttribute.password) {
      if ((tlength % 4) != 0) {
        throw {"mes": ""};
      }
    }
    if (type == StunAttribute.messageIntegrity) {
      if (tlength != 64) {
        throw {"mes": ""};
      }
    }

    return new StunBasicAttribute(type, buffer.sublist(start + 4, start + 4 + tlength));
  }

  int get hashCode {
    int result = type.hashCode;
    for (int i in value) {
      result = 37 * result + i.hashCode;
    }
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunBasicAttribute)) {
      return false;
    }
    StunBasicAttribute p = o;
    if (type != p.type || value.length != p.value.length) {
      return false;
    }

    for (int i = 0; i < value.length; i++) {
      if (value[i] != p.value[i]) {
        return false;
      }
    }
    return true;
  }
}
