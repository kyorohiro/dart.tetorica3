part of hetimacore;

class EasyParser {
  int index = 0;
  List<int> stack = new List();
  TetReader _buffer = null;
  TetReader get buffer => _buffer;
  bool logon = false;
  Exception myException = new Exception();
  TetBufferPlus _cache;
  convert.Utf8Decoder _utfDecoder = new convert.Utf8Decoder(allowMalformed: true);

  EasyParser(TetReader builder, {this.logon: false, int cacheSize: 256}) {
    _buffer = builder;
    _cache = new TetBufferPlus(cacheSize);
  }

  EasyParser toClone() {
    EasyParser parser = new EasyParser(new TetReaderAdapter(_buffer, 0), cacheSize: _cache.cacheSize);
    parser.index = index;
    parser.stack = new List.from(stack);
    return parser;
  }

  void push() {
    stack.add(index);
  }

  void back() {
    index = stack.last;
  }

  int pop() {
    int ret = stack.last;
    stack.remove(ret);
    return ret;
  }

  int last() {
    return stack.last;
  }

  //
  // [TODO]
  void resetIndex(int _index) {
    index = _index;
  }

  //
  // [TODO]
  int getInedx() {
    return index;
  }

  Future<List<int>> getPeek(int length) {
    return _buffer.getBytes(index, length);
  }

  Future<int> jumpBuffer(int length) async {
    int i = await _buffer.getIndex(index, length);
    if (i + length > _buffer.currentSize) {
      throw (logon == false ? myException : new Exception());
    }
    index += length;
    return i;
  }

  Future<List<int>> nextBuffer(int length) async {
    List<int> v = await _buffer.getBytes(index, length);
    index += v.length;
    return v;
  }

//
// todo write test
  Future<bool> checkString(String value) async {
    List<int> encoded = convert.UTF8.encode(value);
    int i = await _buffer.getIndex(index, encoded.length);
    if (i + encoded.length > _buffer.currentSize) {
      return false;
    }
    for(int j=0;j<encoded.length;j++) {
      if(_buffer[j+i] != encoded[j]){
        return false;
      }
    }
    return true;
  }

  Future<String> nextString(String value,{bool checkUpperLowerCase:false}) async {
    List<int> encoded = convert.UTF8.encode(value);
//    print("${encoded}");
    int i = await _buffer.getIndex(index, encoded.length);
    if (i + encoded.length > _buffer.currentSize) {
      throw (logon == false ? myException : new Exception());
    }
    if(!checkUpperLowerCase) {
      for(int j=0;j<encoded.length;j++) {
        if(_buffer[j+i] != encoded[j]){
          throw (logon == false ? myException : new Exception());
        }
      }
    } else {
      for (int j = 0; j < encoded.length; j++) {
        var v = encoded[j];
        if (65 <= v && v <= 90) {
          if (_buffer[j + i] != encoded[j] && _buffer[j + i] != encoded[j]+32) {
            throw (logon == false ? myException : new Exception());
          }
        }
        else if (97 <= v && v <= 122) {
          if (_buffer[j + i] != encoded[j] && _buffer[j + i] != encoded[j]-32) {
            throw (logon == false ? myException : new Exception());
          }
        }
        else {
          if(_buffer[j+i] != encoded[j]){
            throw (logon == false ? myException : new Exception());
          }
        }
      }
    }
    index +=encoded.length;
    return value;
  }

  Future<String> readSignWithLength(int length) async {
    List<int> va = null;
    int i = index;
    if (_cache.rawbuffer8.length > length) {
      va = await _buffer.getBytes(index, length, out: _cache.rawbuffer8);
    } else {
      va = await _buffer.getBytes(index, length);
    }
    if (i + length > _buffer.currentSize) {
      throw (logon == false ? myException : new Exception());
    }
    index += length;
    return _utfDecoder.convert(va, 0, length);
  }

  Future<int> readLong(ByteOrderType byteorder) async {
    int i = await _buffer.getIndex(index, 8);
    if (i + 8 > _buffer.currentSize) {
      throw (logon == false ? myException : new Exception());
    }
    index += 8;
    return ByteOrder.parseLong(_buffer, 0, byteorder);
  }

  Future<int> readInt(ByteOrderType byteorder) async {
    int i = await _buffer.getIndex(index, 4);
    if (i + 4 > _buffer.currentSize) {
      throw (logon == false ? myException : new Exception());
    }
    index += 4;
    return ByteOrder.parseInt(_buffer, 0, byteorder);
  }

  Future<int> readShort(ByteOrderType byteorder) async {
    int i = await _buffer.getIndex(index, 2);
    if (i + 2 > _buffer.currentSize) {
      throw (logon == false ? myException : new Exception());
    }
    index += 2;
    return ByteOrder.parseShort(_buffer, 0, byteorder);
  }

  Future<int> readByte() async {
    int i = await _buffer.getIndex(index, 1);
    if (i + 1 > _buffer.currentSize) {
      throw (logon == false ? myException : new Exception());
    }
    index += 1;
    return _buffer[i];
  }

  Future<int> nextBytePattern(EasyParserMatcher matcher) {
    Completer completer = new Completer();
    matcher.init();
    _buffer.getBytes(index, 1).then((List<int> v) {
      if (v.length < 1) {
        throw new EasyParseError();
      }
      if (matcher.match(v[0])) {
        index++;
        completer.complete(v[0]);
      } else {
        throw new EasyParseError();
      }
    });
    return completer.future;
  }

  Future<List<int>> nextBytePatternWithLength(EasyParserMatcher matcher, int length) {
    Completer completer = new Completer();
    matcher.init();
    _buffer.getBytes(index, length).then((List<int> va) {
      if (va.length < length) {
        completer.completeError(new EasyParseError());
      }
      for (int v in va) {
        bool find = false;
        find = matcher.match(v);
        if (find == false) {
          completer.completeError(new EasyParseError());
        }
        index++;
      }
      completer.complete(va);
    });
    return completer.future;
  }

  Future<List<int>> nextBytePatternByUnmatch(EasyParserMatcher matcher, [bool keepWhenMatchIsTrue = true]) {
    Completer completer = new Completer();
    matcher.init();
    List<int> ret = new List<int>();
    Future<Object> p() {
      return _buffer.getBytes(index, 1).then((List<int> va) {
        if (va.length < 1) {
          completer.complete(ret);
        } else if (keepWhenMatchIsTrue == matcher.match(va[0])) {
          ret.add(va[0]);
          index++;
          return p();
        } else if (_buffer.immutable) {
          completer.complete(ret);
        } else {
          completer.complete(ret);
        }
      });
    }
    p();
    return completer.future;
  }
}

abstract class EasyParserMatcher {
  void init() {
    ;
  }

  bool match(int target);
  bool matchAll() {
    return true;
  }
}

//
// http response
//
class EasyParserIncludeMatcher extends EasyParserMatcher {
  List<int> include = null;
  EasyParserIncludeMatcher(List<int> i) {
    include = i;
  }

  bool match(int target) {
    return include.contains(target);
  }
}
class EasyParserStringMatcher extends EasyParserMatcher {
  List<int> include = null;
  int index = 0;
  EasyParserStringMatcher(String v) {
    include = convert.UTF8.encode(v);
  }

  void init() {
    index = 0;
  }

  bool match(int target) {
    return include.contains(target);
  }
}

class EasyParseError extends Error {
  EasyParseError();
}
