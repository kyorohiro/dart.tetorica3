part of hetimacore;

enum ByteOrderType {
  BigEndian,
  LittleEndian
}

class ByteOrder {


  static List<int> parseLongByte(int value, ByteOrderType byteorder) {
    List<int> ret = new List(8);
    if (byteorder == ByteOrderType.BigEndian) {
      ret[0] = (value >> 56 & 0xff);
      ret[1] = (value >> 48 & 0xff);
      ret[2] = (value >> 40 & 0xff);
      ret[3] = (value >> 32 & 0xff);
      ret[4] = (value >> 24 & 0xff);
      ret[5] = (value >> 16 & 0xff);
      ret[6] = (value >> 8 & 0xff);
      ret[7] = (value >> 0 & 0xff);
    } else {
      ret[0] = (value >> 0 & 0xff);
      ret[1] = (value >> 8 & 0xff);
      ret[2] = (value >> 16 & 0xff);
      ret[3] = (value >> 24 & 0xff);
      ret[4] = (value >> 32 & 0xff);
      ret[5] = (value >> 40 & 0xff);
      ret[6] = (value >> 48 & 0xff);
      ret[7] = (value >> 56 & 0xff);
    }
    return ret;
  }

  static List<int> parseIntByte(int value, ByteOrderType byteorder) {
    List<int> ret = new List(4);
    if (byteorder == ByteOrderType.BigEndian) {
      ret[0] = (value >> 24 & 0xff);
      ret[1] = (value >> 16 & 0xff);
      ret[2] = (value >> 8 & 0xff);
      ret[3] = (value >> 0 & 0xff);
    } else {
      ret[0] = (value >> 0 & 0xff);
      ret[1] = (value >> 8 & 0xff);
      ret[2] = (value >> 16 & 0xff);
      ret[3] = (value >> 24 & 0xff);
    }
    return ret;
  }

  static List<int> parseShortByte(int value, ByteOrderType byteorder) {
    List<int> ret = new List(2);
    if (byteorder == ByteOrderType.BigEndian) {
      ret[0] = (value >> 8 & 0xff);
      ret[1] = (value >> 0 & 0xff);
    } else {
      ret[0] = (value >> 0 & 0xff);
      ret[1] = (value >> 8 & 0xff);
    }
    return ret;
  }

  static int parseShort(var value, int start, ByteOrderType byteorder) {
    int ret = 0;
    if (byteorder == ByteOrderType.BigEndian) {
      ret = ret | ((value[0 + start] & 0xff) << 8);
      ret = ret | ((value[1 + start] & 0xff) << 0);
    } else {
      ret = ret | ((value[1 + start] & 0xff) << 8);
      ret = ret | ((value[0 + start] & 0xff) << 0);
    }
    return ret;
  }

  static int parseInt(var value, int start, ByteOrderType byteorder) {
    int ret = 0;
    if (byteorder == ByteOrderType.BigEndian) {
      ret = ret | ((value[0 + start] & 0xff) << 24);
      ret = ret | ((value[1 + start] & 0xff) << 16);
      ret = ret | ((value[2 + start] & 0xff) << 8);
      ret = ret | ((value[3 + start] & 0xff) << 0);
    } else {
      ret = ret | ((value[3 + start] & 0xff) << 24);
      ret = ret | ((value[2 + start] & 0xff) << 16);
      ret = ret | ((value[1 + start] & 0xff) << 8);
      ret = ret | ((value[0 + start] & 0xff) << 0);
    }
    return ret;
  }
  static int parseLong(var value, int start, ByteOrderType byteorder) {
    int ret = 0;
    if (byteorder == ByteOrderType.BigEndian) {
      ret = ret | ((value[0 + start] & 0xff) << 56);
      ret = ret | ((value[1 + start] & 0xff) << 48);
      ret = ret | ((value[2 + start] & 0xff) << 40);
      ret = ret | ((value[3 + start] & 0xff) << 32);
      ret = ret | ((value[4 + start] & 0xff) << 24);
      ret = ret | ((value[5 + start] & 0xff) << 16);
      ret = ret | ((value[6 + start] & 0xff) << 8);
      ret = ret | ((value[7 + start] & 0xff) << 0);
    } else {
      ret = ret | ((value[7 + start] & 0xff) << 56);
      ret = ret | ((value[6 + start] & 0xff) << 48);
      ret = ret | ((value[5 + start] & 0xff) << 40);
      ret = ret | ((value[4 + start] & 0xff) << 32);
      ret = ret | ((value[3 + start] & 0xff) << 24);
      ret = ret | ((value[2 + start] & 0xff) << 16);
      ret = ret | ((value[1 + start] & 0xff) << 8);
      ret = ret | ((value[0 + start] & 0xff) << 0);
    }
    return ret;
  }

}
