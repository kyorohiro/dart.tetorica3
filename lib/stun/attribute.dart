part of hetimanet_stun;

abstract class StunAttribute {
  static const int mappedAddress = 0x0001; //

  // rfc3489 only
  static const int responseAddress = 0x0002; //

  // rfc3489 only
  static const int changeRequest = 0x0003; ////

  // rfc3489 only
  static const int sourceAddress = 0x0004; //

  // rfc3489 only
  static const int changedAddress = 0x0005; //

  static const int userName = 0x0006; ////
  static const int password = 0x0007; //// rfc 3489

  static const int messageIntegrity = 0x0008;
  static const int errorCode = 0x0009;
  static const int unknownAttribute = 0x000a;

  // rfc3489 only
  static const int reflectedFrom = 0x000b; //
  static const int realm = 0x0014; //
  static const int nonce = 0x0015; //
  static const int xorMappedAddress =0x0020;
  static const int xorMappedAddressOptional =0x8020;
  static const int software =0x8022;
  static const int alternateServer =0x8023;
  static const int fingerprint =0x8028;

  static const int responseOrigin =0x802b;
  static const int otherAddress =0x802c;



  int get type; //2byte
  int get length; //2byte
  Uint8List encode();
  static String toStringFromType(int type) {
    switch (type) {
      case mappedAddress:
        return "mappedAddress (${type})";
      case responseAddress:
        return "responseAddress (${type})";
      case changeRequest:
        return "changeRequest (${type})";
      case sourceAddress:
        return "sourceAddress (${type})";
      case changedAddress:
        return "changedAddress (${type})";
      case userName:
        return "userName (${type})";
      case password:
        return "password (${type})";
      case messageIntegrity:
        return "messageIntegrity (${type})";
      case errorCode:
        return "errorCode (${type})";
      case unknownAttribute:
        return "unknownAttribute (${type})";
      case reflectedFrom:
        return "reflectedFrom (${type})";
      case realm:
        return "realm (${type})";
      case nonce:
        return "nonce (${type})";
      case xorMappedAddress:
        return "xorMappedAddress (${type})";
      case xorMappedAddressOptional:
        return "xorMappedAddressOptional (${type})";
      case software:
        return "#software (${type})";
      case alternateServer:
        return "#alternateServer(${type})";
      case fingerprint:
        return "#fingerprint (${type})";
      case responseOrigin:
        return "#responseOrigin (${type})";
      case otherAddress:
        return "#otherAddress (${type})";
      default:
        return "none (${type})";
    }
  }

  static List<StunAttribute> decode(List<int> buffer, {int start: 0, int end: null}) {
    if (end == null) {
      end = buffer.length;
    }
    List<StunAttribute> ret = [];

    while (start < buffer.length) {
      StunAttribute a = null;
      int t = core.ByteOrder.parseShort(buffer, start + 0, core.ByteOrderType.BigEndian);
      switch (t) {
        case StunAttribute.mappedAddress:
        case StunAttribute.responseAddress:
        case StunAttribute.changedAddress:
        case StunAttribute.sourceAddress:
        case StunAttribute.reflectedFrom:
        case StunAttribute.xorMappedAddress:
        case StunAttribute.xorMappedAddressOptional:
        case StunAttribute.otherAddress:
        case StunAttribute.responseOrigin:
          a = StunAddressAttribute.decode(buffer, start);
          break;
        case StunAttribute.changeRequest:
          a = StunChangeRequestAttribute.decode(buffer, start);
          break;
        case StunAttribute.errorCode:
          a = StunErrorCodeAttribute.decode(buffer, start);
          break;
        case StunAttribute.userName:
        case StunAttribute.password:
        case StunAttribute.userName:
        case StunAttribute.messageIntegrity:
        default:
          a = StunBasicAttribute.decode(buffer, start);
          break;
      }
      start += a.length + 4;
      ret.add(a);
    }
    return ret;
  }

}
