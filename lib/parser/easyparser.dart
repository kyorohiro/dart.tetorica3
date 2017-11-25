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
    if(cacheSize < 256) {
      cacheSize = 256;
    }
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

  FutureOr<List<int>> getPeek(int length) {
    return _buffer.getBytes(index, length);
  }

  FutureOr<int> jumpBuffer(int length) async {
    int i = await _buffer.waitByBuffered(index, length);
    if (i + length > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += length;
    return i;
  }


  //
  // NEXT return length
  //
  FutureOr<String> nextString(String value) async {
    await nextBytes(convert.UTF8.encode(value));
    return value;
  }

  FutureOr<List<int>> nextBytes(List<int> encoded) async {
    if(0 == await checkBytes(encoded)){
      throw (logon == false ? _myException : new Exception());
    }
    _index +=encoded.length;
    return encoded;
  }

  FutureOr<String> nextStringWithUpperLowerCase(String value) async {
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

  FutureOr<int> nextByteFromBytes(List<int> encoded) async {
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
  // CHECK return length
  //
  FutureOr<int> checkString(String value) async {
    return checkBytes(convert.UTF8.encode(value));
  }

  FutureOr<int> checkBytes(List<int> encoded) async {
    int i = await _buffer.waitByBuffered(index, encoded.length);
    if (i + encoded.length > _buffer.currentSize) {
      return 0;
    }
    for(int j=0;j<encoded.length;j++) {
      if(_buffer[j+i] != encoded[j]){
        return 0;
      }
    }
    return encoded.length;
  }

  FutureOr<int> checkBytesFromBytes(List<int> encoded,{bool expectedMatcherResult:true}) async {
    return checkBytesFromMatcher((int target){
      for (int i = 0; i < encoded.length; i++) {
        if (target == encoded[i]) {
          return true;
        }
      }
      return false;
    },expectedMatcherResult:expectedMatcherResult);
  }

  FutureOr<int> checkBytesFromMatchBytes(List<int> encoded) async {
    return checkBytesFromBytes(encoded, expectedMatcherResult:true);
  }

  FutureOr<int> checkBytesFromUnmatchBytes(List<int> encoded) async {
    return checkBytesFromBytes(encoded, expectedMatcherResult:false);
  }

  FutureOr<int> checkBytesFromMatcher(EasyParserMatchFunc matcher, {bool expectedMatcherResult:true}) async {
    int nextByte = 0;
    int length = 0;
    while(true) ROOT:{
      if (_buffer.currentSize > index) {
        nextByte = _buffer[index+length];
      } else {
        List<int> tmp = (await _buffer.getBytes(index+length, 1));
        if(tmp.length == 0) {
          return 0;
        }
        nextByte = tmp[0];
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
  // MATCH
  //
  FutureOr<List<int>> matchBytesFromBytes(List<int> encoded, {bool expectedMatcherResult:true}) async {
    int len = await checkBytesFromBytes(encoded, expectedMatcherResult:expectedMatcherResult);
    data.Uint8List ret = new data.Uint8List(len);
    for(int i=0;i<len;i++) {
      ret[i] = _buffer[i+index];
    }
    _index += len;
    return ret;
  }

  FutureOr<List<int>> matchBytesFromMatche(EasyParserMatchFunc func, {bool expectedMatcherResult:true}) async {
    int len = await checkBytesFromMatcher(func, expectedMatcherResult:expectedMatcherResult);
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
  FutureOr<List<int>> getBytes(int length) {
    FutureOr<List<int>> v = _buffer.getBytes(index, length);
    if(v is FutureOr<List<int>>) {
      return _getBytes_00(v);
    } else {
      _index += (v as List<int>).length;
      return v;
    }
  }

  FutureOr<List<int>> _getBytes_00(FutureOr<List<int>> vf) async {
    List<int> v = await vf;
    _index += v.length;
    return v;
  }
  //

  FutureOr<String> getStringWithByteLength(int length) async {
    int i = index;
    List<int> va = await getBytes(length);
    if (i + length > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += length;
    return _utfDecoder.convert(va, 0, length);
  }


  //
  FutureOr<int> readLong(ByteOrderType byteorder) async {
    if(_buffer.currentSize < index+8) {
       return _readLongF(byteorder);
    }
    _index += 8;
    return ByteOrder.parseLong(_buffer, 0, byteorder);
  }

  FutureOr<int> _readLongF(ByteOrderType byteorder) async {
    int i = await _buffer.waitByBuffered(index, 8);
    if (i + 8 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += 8;
    return ByteOrder.parseLong(_buffer, 0, byteorder);
  }

  //
  //
  FutureOr<int> readInt(ByteOrderType byteorder) {
    if(_buffer.currentSize < index+4) {
      return readIntAsync(byteorder);
    } else {
      return readIntSync(byteorder);
    }
  }

  int readIntSync(ByteOrderType byteorder) {
    _index += 4;
    return ByteOrder.parseInt(_buffer, 0, byteorder);
  }

  Future<int> readIntAsync(ByteOrderType byteorder) async {
    int i = await _buffer.waitByBuffered(index, 4);
    if (i + 4 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    return readIntSync(byteorder);
  }

  //
  //
  FutureOr<int> readShort(ByteOrderType byteorder) {
    if(_buffer.currentSize < index+2) {
      return readShortAsync(byteorder);
    } else {
      return readShortSync(byteorder);
    }
  }

  int readShortSync(ByteOrderType byteorder) {
    _index += 2;
    return ByteOrder.parseShort(_buffer, 0, byteorder);
  }

  Future<int> readShortAsync(ByteOrderType byteorder) async {
    int i = await _buffer.waitByBuffered(index, 2);
    if (i + 2 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    _index += 2;
    return readShortSync(byteorder);
  }

  //
  //
  FutureOr<int> readByte() {
    if(_buffer.currentSize < index+1) {
      return readByteAsync();
    } else {
      return readByteSync();
    }
  }

  int readByteSync() {
    return _buffer[_index++];
  }

  Future<int> readByteAsync() async {
    int i = await _buffer.waitByBuffered(index, 1);
    if (i + 1 > _buffer.currentSize) {
      throw (logon == false ? _myException : new Exception());
    }
    return  readByteSync();
  }
}


class EasyParseError extends Error {
  EasyParseError();
}
