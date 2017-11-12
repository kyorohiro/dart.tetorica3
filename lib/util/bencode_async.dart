part of hetimacore;


class BencodeAsync {
  static BdecoderAsync _decoder = new BdecoderAsync();

  static Future<Object> decode(EasyParser parser) {
    return _decoder.decode(parser);
  }
}

class BdecoderAsync {
  HetiBencodeParseError tmpError = new HetiBencodeParseError.empty();
  static String DIGIT_AS_STRING = "0123456789";
  static List<int> DIGIT = convert.UTF8.encode(DIGIT_AS_STRING);

  Future<Object> decode(EasyParser parser) {
    return decodeBenObject(parser);
  }

  Future<Object> decodeBenObject(EasyParser parser) async {
    List<int> v = await parser.getPeek(1);
    if (0x69 == v[0]) {
      // i
      return decodeNumber(parser);
    } else if (0x30 <= v[0] && v[0] <= 0x39) {
      //0-9
      List<int> vv = await decodeBytes(parser);
      return (vv is data.Uint8List ? vv : new data.Uint8List.fromList(vv));
    } else if (0x6c == v[0]) {
      // l
      return decodeList(parser);
    } else if (0x64 == v[0]) {
      // d
      return decodeDiction(parser);
    }
    throw tmpError.update("benobject");
  }

  Future<Map> decodeDiction(EasyParser parser) async {
    await parser.nextString("d");
    Map ret = await decodeDictionElements(parser);
    await parser.nextString("e");
    return ret;
  }

  Future<Map> decodeDictionElements(EasyParser parser) async {
    Map ret = new Map();
    while (true) {
      String key = await decodeString(parser);
      ret[key] = await decodeBenObject(parser);
      List<int> v = await parser.getPeek(1);
      if (v[0] == 0x65) {
        //e
        return ret;
      }
    }
  }

  Future<List<Object>> decodeList(EasyParser parser) async {
    await parser.nextString("l");
    List<Object> ret = await decodeListElement(parser);
    await parser.nextString("e");
    return ret;
  }

  Future<List<Object>> decodeListElement(EasyParser parser) async {
    List<Object> ret = new List();
    while (true) {
      Object v1 = await decodeBenObject(parser);
      ret.add(v1);
      List<int> v = await parser.getPeek(1);
      if (v.length == 0) {
        throw tmpError.update("list elm");
      } else if (v[0] == 0x65) {
        //e
        return ret;
      }
    }
  }

  Future<int> decodeNumber(EasyParser parser) async {
    await parser.nextString("i");
    List<int> numList = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(DIGIT));
    int num = intList2int(numList);
    await parser.nextString("e");
    return num;
  }

  Future<String> decodeString(EasyParser parser) async {
    List<int> v = await decodeBytes(parser);
    return convert.UTF8.decode(v, allowMalformed: true);
  }

  Future<List<int>> decodeBytes(EasyParser parser) async {
    List<int> lengthList = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(DIGIT));
    if (lengthList.length == 0) {
      throw tmpError.update("byte:length=0");
    }
    int length = intList2int(lengthList);
    await parser.nextString(":");
    List<int> value = await parser.nextBuffer(length);
    if (value.length == length) {
      return value;
    } else {
      throw tmpError.update("byte:length:" + value.length.toString() + "==" + length.toString());
    }
  }

  static int intList2int(List<int> numList) {
    int num = 0;
    for (int n in numList) {
      num *= 10;
      num += (n - 48);
    }
    return num;
  }
}

class HetiBencodeParseError implements Exception {
  String log = "";
  HetiBencodeParseError.empty() {}

  HetiBencodeParseError(String s) {
    update(s);
  }

  update(String s) {
    log = s + "#" + super.toString();
    return this;
  }

  String toString() {
    return log;
  }
}
