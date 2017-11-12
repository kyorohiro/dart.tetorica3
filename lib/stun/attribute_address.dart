part of hetimanet_stun;

class StunAddressAttribute extends StunAttribute {
  static const int familyIPv4 = 0x0001;
  static const int familyIPv6 = 0x0002;
  static int _length(family) => (family == familyIPv4 ? (2 + 2 + 4) : (2 + 2 + 16));

  int type;
  int get length => _length(family);
  int family;
  int port;
  String address;

  StunAddressAttribute(this.type, this.family, this.port, this.address) {}
  StunAddressAttribute.XAddressFromAddress(StunTransactionID transactionID, this.type, this.family, this.port, this.address) {
    this.address = convXAddress(transactionID, address);
    this.port = convXPort(transactionID, port);
  }

  @override
  String toString() {
    Map t = {};
    t["type"] = StunAttribute.toStringFromType(type);
    t["length"] = length;
    t["family"] = family;
    t["port"] = port;
    t["address"] = address;
    return "${t}";
  }

  static StunAddressAttribute decode(List<int> buffer, int start,
    {List<int> expectType:
       const [
         StunAttribute.mappedAddress, StunAttribute.responseAddress, StunAttribute.changedAddress,
         StunAttribute.sourceAddress, StunAttribute.reflectedFrom, StunAttribute.xorMappedAddress,
         StunAttribute.xorMappedAddressOptional, StunAttribute.otherAddress,StunAttribute.responseOrigin]}) {
    int type = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrderType.BigEndian);
    if (false == expectType.contains(type)) {
      throw {"mes": ""};
    }
    int tlength = core.ByteOrder.parseShort(buffer, start + 2, core.ByteOrderType.BigEndian);
    int family = core.ByteOrder.parseShort(buffer, start + 4, core.ByteOrderType.BigEndian);
    if (tlength != _length(family)) {
      throw {"mes": ""};
    }
    int port = core.ByteOrder.parseShort(buffer, start + 6, core.ByteOrderType.BigEndian);
    String address = null;
    if (family == familyIPv4) {
      address = net.IPConv.toIPv4String(buffer, start: start + 8);
    } else {
      address = net.IPConv.toIPv6String(buffer, start: start + 8);
    }
    return new StunAddressAttribute(type, family, port, address);
  }

  Uint8List encode() {
    List<int> buffer = [];
    buffer.addAll(core.ByteOrder.parseShortByte(type, core.ByteOrderType.BigEndian));
    buffer.addAll(core.ByteOrder.parseShortByte(_length(family), core.ByteOrderType.BigEndian));
    buffer.addAll(core.ByteOrder.parseShortByte(family, core.ByteOrderType.BigEndian));
    buffer.addAll(core.ByteOrder.parseShortByte(port, core.ByteOrderType.BigEndian));
    buffer.addAll(net.IPConv.toRawIP(this.address));
    return new Uint8List.fromList(buffer);
  }

  int get hashCode {
    int result = type.hashCode;
    result = 37 * result + family.hashCode;
    result = 37 * result + port.hashCode;
    result = 37 * result + address.hashCode;
    return result;
  }

  bool operator ==(o) {
    if (o == null || false == (o is StunAddressAttribute)) {
      return false;
    }
    StunAddressAttribute p = o;
    return (type == p.type && family == p.family && port == p.port && address == p.address);
  }

  String xAddress(StunTransactionID id) {
    return StunAddressAttribute.convXAddress(id, address);
  }

  int xPort(StunTransactionID id) {
    return convXPort(id, port);
  }

  static String convXAddress(StunTransactionID id, String address) {
    List<int> a = net.IPConv.toRawIP(address);
    List<int> b = id.value;
    List<int> c = [];
    for(int i=0;i<a.length;i++) {
      c.add(0xff&(a[i]^b[i]));
    }
    return net.IPConv.toIPString(c);
  }

  static int convXPort(StunTransactionID id, int port) {
    List<int> a = core.ByteOrder.parseShortByte(port, core.ByteOrderType.BigEndian);
    List<int> b = id.magicCookie();
    List<int> c = [a[0] ^ b[0], a[1] ^ b[1]];
    return core.ByteOrder.parseShort(c, 0, core.ByteOrderType.BigEndian);
  }
}
