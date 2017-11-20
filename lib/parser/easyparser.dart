part of hetimaparsr;

typedef bool EasyParserMatchFunc(int target);
class EasyParser {
  bool logon = false;

  int _index = 0;
  int get index => _index;
  void resetIndex(int __index) {_index = __index;} //[TODO]
  ParserReader _buffer = null;
  ParserReader get buffer => _buffer;

  List<int> _stack = new List();
  Exception _myException = new Exception();
  MemoryBuffer _cache;
  convert.Utf8Decoder _utfDecoder = new convert.Utf8Decoder(allowMalformed: true);

  EasyParser(ParserReader builder, {this.logon: false, int cacheSize: 256}) {
    _buffer = builder;
    _cache = new MemoryBuffer(cacheSize);
  }

  EasyParser toClone() {
    EasyParser parser = new EasyParser(new ParserReaderWithIndex(_buffer, 0), cacheSize: _cache.bufferSize);
    parser._index = index;
    parser._stack = new List.from(_stack);
    return parser;
  }

  void push() {_stack.add(index);}
  void back() {_index = _stack.last;}
  int pop() => _stack.removeLast();
  int last()=>_stack.last;


  Future<List<int>> getPeek(int length) {
    return _buffer.getBytes(index, length);
  }

  Future<int> jumpBuffer(int length) async {
    int i = await _buffer.waitByBuffered(index, length);
    if (i + length > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += length;
    return i;
  }

  Future<List<int>> readBuffer(int length) async {
    List<int> v = await _buffer.getBytes(index, length);
    _index += v.length;
    return v;
  }

  //
  // check todo write test
  //
  Future<bool> checkString(String value) async {
    return checkBytes(convert.UTF8.encode(value));
  }

  Future<bool> checkBytes(List<int> encoded) async {
    int i = await _buffer.waitByBuffered(index, encoded.length);
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

  //
  // next
  //
  Future<String> nextString(String value) async {
    await nextBytes(convert.UTF8.encode(value));
    return value;
  }

  Future<List<int>> nextBytes(List<int> encoded) async {
    if(false == await checkBytes(encoded)){
      throw (logon == false ? _myException : new Exception());
    }
    _index +=encoded.length;
    return encoded;
  }

  Future<String> nextStringWithUpperLowerCase(String value) async {
    List<int> encoded = convert.UTF8.encode(value);
    int i = await _buffer.waitByBuffered(index, encoded.length);
    if (i + encoded.length > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    for (int j = 0; j < encoded.length; j++) {
      var v = encoded[j];
      if (65 <= v && v <= 90) {
        if (_buffer[j + i] != encoded[j] && _buffer[j + i] != encoded[j]+32) {
          throw (logon == false ? _myException : new Exception());
        }
      }
      else if (97 <= v && v <= 122) {
        if (_buffer[j + i] != encoded[j] && _buffer[j + i] != encoded[j]-32) {
          throw (logon == false ? _myException : new Exception());
        }
      }
      else {
        if(_buffer[j+i] != encoded[j]){
          throw (logon == false ? _myException : new Exception());
        }
      }
    }
    _index +=encoded.length;
    return value;
  }

  Future<int> nextByteFromBytes(List<int> encoded) async {
    int nextByte = 0;
    if(_buffer.currentSize > index) {
      nextByte = _buffer[index];
    } else {
      nextByte = (await _buffer.getBytes(index, 1))[0];
    }

    for(int i=0;i<encoded.length;i++) {
      if(nextByte == encoded[i]) {
        _index += 1;
        return nextByte;
      }
    }
    throw (logon == false ? _myException : new Exception());
  }

  //
  // return length
  //
  Future<int> checkBytesFromBytes(List<int> encoded,{bool expectedMatcherResult:true}) async {
    return checkBytesFromMatcher((int target){
      for (int i = 0; i < encoded.length; i++) {
        if (target == encoded[i]) {
          return true;
        }
      }
      return false;
    },expectedMatcherResult:expectedMatcherResult);
  }

  Future<int> checkBytesFromMatchBytes(List<int> encoded) async {
    return checkBytesFromBytes(encoded, expectedMatcherResult:true);
  }

  Future<int> checkBytesFromUnmatchBytes(List<int> encoded) async {
    return checkBytesFromBytes(encoded, expectedMatcherResult:false);
  }

  Future<int> checkBytesFromMatcher(EasyParserMatchFunc matcher, {bool expectedMatcherResult:true}) async {
    int nextByte = 0;
    int length = 0;
    while(true) ROOT:{
      if (_buffer.currentSize > index) {
        nextByte = _buffer[index+length];
      } else {
        nextByte = (await _buffer.getBytes(index+length, 1))[0];
      }
      if(expectedMatcherResult != matcher(nextByte)) {
        break;
      } else {
        length += 1;
      }
    }
    return length;
  }

  //
  Future<List<int>> matchBytesFromBytes(List<int> encoded, {bool expectedMatcherResult:true}) async {
    int len = await checkBytesFromBytes(encoded, expectedMatcherResult:expectedMatcherResult);
    data.Uint8List ret = new data.Uint8List(len);
    for(int i=0;i<len;i++) {
      ret[i] = _buffer[i+index];
    }
    _index += len;
    return ret;
  }

  //
  // READ
  //
  Future<String> readStringWithByteLength(int length) async {
    List<int> va = null;
    int i = index;
    if (_cache.rawbuffer8.length > length) {
      va = await _buffer.getBytes(index, length, out: _cache.rawbuffer8);
    } else {
      va = await _buffer.getBytes(index, length);
    }
    if (i + length > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += length;
    return _utfDecoder.convert(va, 0, length);
  }


  Future<int> readLong(ByteOrderType byteorder) async {
    int i = await _buffer.waitByBuffered(index, 8);
    if (i + 8 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += 8;
    return ByteOrder.parseLong(_buffer, 0, byteorder);
  }

  Future<int> readInt(ByteOrderType byteorder) async {
    int i = await _buffer.waitByBuffered(index, 4);
    if (i + 4 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += 4;
    return ByteOrder.parseInt(_buffer, 0, byteorder);
  }

  Future<int> readShort(ByteOrderType byteorder) async {
    int i = await _buffer.waitByBuffered(index, 2);
    if (i + 2 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += 2;
    return ByteOrder.parseShort(_buffer, 0, byteorder);
  }

  Future<int> readByte() async {
    int i = await _buffer.waitByBuffered(index, 1);
    if (i + 1 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += 1;
    return _buffer[i];
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
          _index++;
          return p();
        } else if (_buffer.loadCompleted) {
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
