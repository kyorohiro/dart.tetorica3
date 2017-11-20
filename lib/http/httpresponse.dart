part of hetimanet_http;

//rfc2616 rfc7230
class HetiHttpResponse {
  static List<int> PATH = convert.UTF8.encode(RfcTable.RFC3986_PCHAR_AS_STRING + "/");
  static List<int> QUERY = convert.UTF8.encode(RfcTable.RFC3986_RESERVED_AS_STRING + RfcTable.RFC3986_UNRESERVED_AS_STRING);

  static Future<HttpClientHead> decodeHttpMessage(EasyParser parser) async {
    HttpClientHead result = new HttpClientHead();
    HetiHttpResponseStatusLine line = await decodeStatusline(parser);
    List<HttpResponseHeaderField> httpfields = await decodeHeaderFields(parser);
    result.line = line;
    result.headerField = httpfields;
    result.index = parser.index;
    return result;
  }

  static Future<List<HttpResponseHeaderField>> decodeHeaderFields(EasyParser parser) async {
    List<HttpResponseHeaderField> result = new List();
    while (true) {
      try {
        HttpResponseHeaderField v = await decodeHeaderField(parser);
        result.add(v);
      } catch (e) {
        break;
      }
    }
    await decodeCrlf(parser);
    return result;
  }

  static Future<HttpResponseHeaderField> decodeHeaderField(EasyParser parser) async {
    HttpResponseHeaderField result = new HttpResponseHeaderField();
    result.fieldName = await decodeFieldName(parser);
    await parser.nextString(":");
    await decodeOWS(parser);
    result.fieldValue = await decodeFieldValue(parser);
    await decodeCrlf(parser);
    return result;
  }

  static Future<String> decodeFieldName(EasyParser parser) async {
    List<int> v = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.TCHAR));
    return convert.UTF8.decode(v);
  }

  static Future<String> decodeFieldValue(EasyParser parser) async {
    List<int> v = await parser.nextBytePatternByUnmatch(new FieldValueMatcher());
    return convert.UTF8.decode(v);
  }

  //
  // Http-version
  static Future<String> decodeHttpVersion(EasyParser parser) async {
    int major = 0;
    int minor = 0;
    await parser.nextString("HTTP" + "/");
    int v1 = await parser.nextByteFromBytes(RfcTable.DIGIT);
    major = v1 - 48;
    await parser.nextString(".");
    int v2 = await parser.nextByteFromBytes(RfcTable.DIGIT);
    minor = v2 - 48;
    return ("HTTP/${major}.${minor}");
  }

  //
  // Status Code
  // DIGIT DIGIT DIGIT
  static Future<String> decodeStatusCode(EasyParser parser) async {
    List<int> v = await parser.matchBytesFromBytes(RfcTable.DIGIT);
    int ret = 100 * (v[0] - 48) + 10 * (v[1] - 48) + (v[2] - 48);
    return "${ret}";
  }

  static Future<String> decodeReasonPhrase(EasyParser parser) async {
      // List<int> vv = await parser.nextBytePatternByUnmatch(new TextMatcher());
      // reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
      List<int> vv = await parser.matchBytesFromMatche((int target) {
          //  VCHAR = 0x21-0x7E
          //  obs-text = %x80-FF
          //  SP = 0x30
          //  HTAB = 0x09
          if (0x21 <= target && target <= 0x7E) {
            return true;
          }
          if (0x80 <= target && target <= 0xFF) {
            return true;
          }
          if (target == 0x20 || target == 0x09) {
            return true;
          }
          return false;
        },expectedMatcherResult: true);
    return convert.UTF8.decode(vv);
  }

  //Status-Line = HTTP-Version SP Status-Code SP Reason-Phrase CRLF
  static Future<HetiHttpResponseStatusLine> decodeStatusline(EasyParser parser) async {
    HetiHttpResponseStatusLine result = new HetiHttpResponseStatusLine();
    result.version = await decodeHttpVersion(parser);
    await decodeSP(parser);
    result.statusCode = int.parse(await decodeStatusCode(parser));
    await decodeSP(parser);
    result.statusPhrase = await decodeReasonPhrase(parser);
    await decodeCrlf(parser);
    return result;
  }

  static Future<String> decodeOWS(EasyParser parser) async {
    List<int> v = await parser.matchBytesFromBytes(RfcTable.OWS,expectedMatcherResult: true);
    return convert.UTF8.decode(v);
  }

  static Future<String> decodeSP(EasyParser parser) async {
//    List<int> v = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.OWS));
    List<int> v = await parser.matchBytesFromBytes(RfcTable.OWS,expectedMatcherResult: true);
    return convert.UTF8.decode(v);
  }

  //
  static Future<String> decodeCrlf(EasyParser parser) async {
    bool crlf = true;
    parser.push();
    try {
      await parser.nextString("\r\n");
    } catch (e) {
      parser.back();
      parser.pop();
      parser.push();
      crlf = false;
      await parser.nextString("\n");
    } finally {
      parser.pop();
    }
    if (crlf == true) {
      return "\r\n";
    } else {
      return "\n";
    }
  }

  //
  static Future<int> decodeChunkedSize(EasyParser parser) async {
    //List<int> n = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.HEXDIG));
    List<int> n = await parser.matchBytesFromBytes(RfcTable.HEXDIG,expectedMatcherResult: true);
    if (n.length == 0) {
      throw new EasyParseError();
    }
    String nn = convert.UTF8.decode(n);
    int v = int.parse(nn, radix: 16);
    await HetiHttpResponse.decodeChunkExtension(parser);
    await HetiHttpResponse.decodeCrlf(parser);
    return v;
  }

  static decodeChunkExtension(EasyParser parser) async {
     if (await parser.checkString(";")) {
      while (false == await parser.checkString("\r\n")) {
        parser.jumpBuffer(1);
      }
    }
  }

  //  request-line   = method SP request-target SP HTTP-version CRLF
  static Future<HetiRequestLine> decodeRequestLine(EasyParser parser) async {
    HetiRequestLine result = new HetiRequestLine();
    result.method = await decodeMethod(parser);
    await decodeSP(parser);
    result.requestTarget = await decodeRequestTarget(parser);
    await decodeSP(parser);
    result.httpVersion = await decodeHttpVersion(parser);
    await decodeCrlf(parser);
    return result;
  }

  static Future<HetiHttpRequestMessageWithoutBody> decodeRequestMessage(EasyParser parser) async {
    HetiHttpRequestMessageWithoutBody result = new HetiHttpRequestMessageWithoutBody();
    result.line = await decodeRequestLine(parser);
    result.headerField = await decodeHeaderFields(parser);
    result.index = parser.index;
    return result;
  }

  // metod = token = 1*tchar
  static Future<String> decodeMethod(EasyParser parser) async {
    //List<int> v = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.TCHAR));
    List<int> v = await parser.matchBytesFromBytes(RfcTable.TCHAR,expectedMatcherResult: true);
    return convert.UTF8.decode(v);
  }

  // CHAR_STRING
  static Future<String> decodeRequestTarget(EasyParser parser) async {
   // List<int> v = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.VCHAR));
    List<int> v = await parser.matchBytesFromBytes(RfcTable.VCHAR,expectedMatcherResult: true);
    return convert.UTF8.decode(v);
  }

  // request-target = origin-form / absolute-form / authority-form / asterisk-form
  // absolute-URI  = scheme ":" hier-part [ "?" query ]

  //rfc2616
  static Future<HetiHttpRequestRange> decodeRequestRangeValue(EasyParser parser) async {
    HetiHttpRequestRange ret = new HetiHttpRequestRange();
    await parser.nextString("bytes=");
//    List<int> startAsList = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.DIGIT));
    List<int> startAsList =  await parser.matchBytesFromBytes(RfcTable.DIGIT,expectedMatcherResult: true);

    ret.start = 0;
    for (int d in startAsList) {
      ret.start = (d - 48) + ret.start * 10;
    }
    await parser.nextString("-");
    //List<int> endAsList = await parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.DIGIT));
    List<int> endAsList = await parser.matchBytesFromBytes(RfcTable.DIGIT,expectedMatcherResult: true);
    if (endAsList.length == 0) {
      ret.end = -1;
    } else {
      ret.end = 0;
      for (int d in endAsList) {
        ret.end = (d - 48) + ret.end * 10;
      }
    }
    return ret;
  }
}

// Range: bytes=0-499
class HetiHttpRequestRange {
  int start = 0;
  int end = 0;
}
/*
// reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
class TextMatcher extends EasyParserMatcher {
  @override
  bool match(int target) {
    //  VCHAR = 0x21-0x7E
    //  obs-text = %x80-FF
    //  SP = 0x30
    //  HTAB = 0x09
    if (0x21 <= target && target <= 0x7E) {
      return true;
    }
    if (0x80 <= target && target <= 0xFF) {
      return true;
    }
    if (target == 0x20 || target == 0x09) {
      return true;
    }
    return false;
  }
}
*/

class FieldValueMatcher extends EasyParserMatcher {
  @override
  bool match(int target) {
    if (target == 0x0D || target == 0x0A) {
      return false;
    } else {
      return true;
    }
  }
}

// reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
class HetiHttpResponseStatusLine {
  String version = "";
  int statusCode = -1;
  String statusPhrase = "";
}

class HttpResponseHeaderField {
  String fieldName = "";
  String fieldValue = "";
}

class HetiRequestLine {
  String method = "";
  String requestTarget = "";
  String httpVersion = "";
}

class HetiHttpRequestMessageWithoutBody {
  int index = 0;
  HetiRequestLine line = new HetiRequestLine();
  List<HttpResponseHeaderField> headerField = new List();

  HttpResponseHeaderField find(String fieldName) {
    for (HttpResponseHeaderField field in headerField) {
      //  print(""+field.fieldName.toLowerCase() +"== "+fieldName.toLowerCase());
      if (field != null && field.fieldName.toLowerCase() == fieldName.toLowerCase()) {
        return field;
      }
    }
    return null;
  }
}

// HTTP-message   = start-line
// *( header-field CRLF )
// CRLF
// [ message-body ]
class HttpClientHead {
  int index = 0;
  HetiHttpResponseStatusLine line = new HetiHttpResponseStatusLine();
  List<HttpResponseHeaderField> headerField = new List();

  HttpResponseHeaderField find(String fieldName) {
    for (HttpResponseHeaderField field in headerField) {
      //  print(""+field.fieldName.toLowerCase() +"== "+fieldName.toLowerCase());
      if (field != null && field.fieldName.toLowerCase() == fieldName.toLowerCase()) {
        return field;
      }
    }
    return null;
  }

  int get contentLength {
    HttpResponseHeaderField field = find(RfcTable.HEADER_FIELD_CONTENT_LENGTH);
    if (field == null) {
      return -1;
    }
    try {
      return int.parse(field.fieldValue.replaceAll(" |\r|\n|\t", ""));
    } catch (e) {
      return -1;
    }
  }
}
