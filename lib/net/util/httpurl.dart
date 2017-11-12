part of hetimanet;

class HttpUrl {
  String scheme = "http";
  String host = "127.0.0.1";
  String path = "";
  String query = "";
  int port = 80;

  static HttpUrl decode() {
    return null;
  }

}

class HttpUrlDecoder {
  int index = 0;
  List<int> url = null;
  static List<int> SCHEME_HTTP = convert.UTF8.encode("http://");
  static List<int> SCHEME_HTTPS = convert.UTF8.encode("https://");
  static List<int> PATH = convert.UTF8.encode(RfcTable.RFC3986_PCHAR_AS_STRING + "/");
  static List<int> QUERY = convert.UTF8.encode(RfcTable.RFC3986_RESERVED_AS_STRING + RfcTable.RFC3986_UNRESERVED_AS_STRING);

  static HttpUrlDecoder _sDecoder = new HttpUrlDecoder();

  static HttpUrl decodeUrl(String _url, [String baseAddr = null]) {
    _sDecoder.clear();
    return _sDecoder.innerDecodeUrl(_url, baseAddr);
  }

  static Map<String, String> queryMap(String query) {
    Map<String, String> ret = new Map();
    if (query.length == 0 || !query.contains("=")) {
      return {};
    }

    List<String> pats = query.split("&");
    for (String pat in pats) {
      List<String> pa = pat.split("=");
      String key = pa[0];
      String value = pat.substring(key.length + 1);
      ret[key] = value;
    }
    return ret;
  }

  void clear() {
    index = 0;
    url = null;
  }

  HttpUrl innerDecodeUrl(String _url, [String baseAddr = null]) {
    url = convert.UTF8.encode(_url);
    index = 0;
    HttpUrl ret = new HttpUrl();
    try {
      try {
        ret.scheme = scheme();
        ret.host = host();
        ret.port = port();
      } catch (e) {
        if (baseAddr == null) {
          throw e;
        }
        HttpUrlDecoder dec = new HttpUrlDecoder();
        HttpUrl base = dec.innerDecodeUrl(baseAddr);
        ret.scheme = base.scheme;
        ret.host = base.host;
        ret.port = base.port;
      }
      ret.path = path();
      ret.query = query();
    } catch (e) {
      return null;
    }
    return ret;
  }

  String scheme() {
    try {
      push();
      if (matchGroup(SCHEME_HTTP)) {
        return "http";
      }
      back();
      if (matchGroup(SCHEME_HTTPS)) {
        return "https";
      } else {
        back();
        throw new ParseError();
      }
    } finally {
      pop();
    }
  }

  String host() {
    try {
      push();
      while (matchChar(RfcTable.RFC3986_UNRESERVED)) {
        ;
      }
      return convert.UTF8.decode(last());
    } finally {
      pop();
    }
  }

  String path() {
    try {
      push();
      if (url.length <= index) {
        return "";
      }
      if (!(url[index] == 0x2f)) {
        return "";
      }
      index++;

      while (matchChar(PATH)) {
        ;
      }
      List<int> pathAsList = last();
      String pathAsString = convert.UTF8.decode(pathAsList);
      return pathAsString;
    } finally {
      pop();
    }
  }

  String query() {
    if (url.length <= index) {
      return "";
    }
    if (!(url[index] == 0x3f)) {
      return "";
    }
    index++;
    try {
      push();
      while (matchChar(QUERY)) {
        ;
      }
      List<int> pathAsList = last();
      String pathAsString = convert.UTF8.decode(pathAsList);
      return pathAsString;
    } finally {
      pop();
    }
  }

  int port() {
    try {
      push();
      if (url.length <= index) {
        return 80;
      }
      //:
      if (!(url[index] == 0x3a)) {
        return 80;
      }
      index++;
      while (matchChar(RfcTable.DIGIT)) {
        ;
      }
      List<int> portAsList = last();
      if (portAsList.length <= 1) {
        return 80;
      }
      String portAsString = convert.UTF8.decode(portAsList);
      return int.parse(portAsString.substring(1));
    } finally {
      pop();
    }
  }

  List<int> stack = new List();
  void push() {
    stack.add(index);
  }

  void pop() {
    stack.removeLast();
  }

  void back() {
    index = stack.last;
  }

  List<int> last() {
    int end = index;
    int start = stack.last;
    int len = end - start;
    List<int> ret = new List(len);
    for (int i = 0; i < len; i++) {
      ret[i] = url[start + i];
    }
    return ret;
  }

  bool matchGroup(List<int> v) {
    for (int i = 0; i < v.length; i++) {
      if (url.length <= index) {
        return false;
      }
      if (v[i] != url[index]) {
        return false;
      } else {
        index++;
      }
    }
    return true;
  }

  bool matchChar(List<int> v) {
    if (url.length <= index) {
      return false;
    }
    for (int i = 0; i < v.length; i++) {
      if (v[i] == url[index]) {
        index++;
        return true;
      }
    }
    return false;
  }
}
