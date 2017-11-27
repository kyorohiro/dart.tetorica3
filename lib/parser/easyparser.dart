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


  FutureOr<List<int>> peekBytes(int length) => _buffer.getBytes(index, length);

  //
  //
  FutureOr<int> moveOffset(int moveBytes) async {
    if(_buffer.currentSize < index+moveBytes) {
      return moveOffsetAsync(moveBytes);
    } else {
      return moveOffsetSync(moveBytes);
    }
  }

  Future<int> moveOffsetAsync(int moveBytes) async {
    await waitByBuffered(index, moveBytes,checkLength: true);
    _index += moveBytes;
    return index;
  }

  int moveOffsetSync(int moveBytes) {
    _index += moveBytes;
    return index;
  }


  //
  //
  Future<int> waitByBuffered(int index, int length, {bool checkLength:false}) async {
    int ret = await _buffer.waitByBuffered(index, length);
    if(checkLength) {
      if (index + length > _buffer.currentSize) {
        throw (logon == false ? _myException : new Exception());
      }
    }
    return ret;
  }

  //
  // NEXT return length
  //
  FutureOr<List<int>> nextBytes(List<int> encoded) {
    if(_buffer.currentSize >= index+encoded.length) {
      return nextBytesSync(encoded);
    } else {
      return nextBytesAsync(encoded);
    }
  }

  FutureOr<List<int>> nextBytesAsync(List<int> encoded) async {
    if(0 == await checkBytesAsync(encoded)){
      throw (logon == false ? _myException : new Exception());
    }
    _index +=encoded.length;
    return encoded;
  }

  List<int> nextBytesSync(List<int> encoded) {
    if(0 == checkBytesSync(encoded)){
      throw (logon == false ? _myException : new Exception());
    }
    _index +=encoded.length;
    return encoded;
  }

  FutureOr<String> nextString(String value) {
    FutureOr<List<int>> retFOr = nextBytes(convert.UTF8.encode(value));
    if(retFOr is Future<List<int>>) {
      return (retFOr as Future<List<int>>).then((List<int> v) {return value;});
    } else {
      return value;
    }
  }

  //
  //
  FutureOr<List<int>> nextStringWithUpperLowerCase(List<int> encoded ) {
    if(_buffer.currentSize >= index+encoded.length) {
      return nextStringWithUpperLowerCaseSync(encoded);
    } else {
      return nextStringWithUpperLowerCaseAsync(encoded);
    }
  }

  FutureOr<List<int>> nextStringWithUpperLowerCaseAsync(List<int> encoded ) async {
    await waitByBuffered(index, encoded.length, checkLength: true);
    return nextStringWithUpperLowerCaseSync(encoded);
  }

  List<int> nextStringWithUpperLowerCaseSync(List<int> encoded ) {
    for (int j = 0; j < encoded.length; j++) {
      var v = encoded[j];
      if (65 <= v && v <= 90) {
        if (_buffer[j + index] != encoded[j] && _buffer[j + index] != encoded[j]+32) {
          throw (logon == false ? _myException : new Exception());
        }
      }
      else if (97 <= v && v <= 122) {
        if (_buffer[j + index] != encoded[j] && _buffer[j + index] != encoded[j]-32) {
          throw (logon == false ? _myException : new Exception());
        }
      }
      else {
        if(_buffer[j+index] != encoded[j]){
          throw (logon == false ? _myException : new Exception());
        }
      }
    }
    _index +=encoded.length;
    return encoded;
  }

  //
  //
  FutureOr<int> nextByteFromBytes(List<int> encoded) {
    if(_buffer.currentSize >= index+encoded.length) {
      return nextByteFromBytesSync(encoded);
    } else {
      return nextByteFromBytesAsync(encoded);
    }
  }

  Future<int> nextByteFromBytesAsync(List<int> encoded) async {
    List<int> nextBytes = (await _buffer.getBytes(index, 1));
    if(nextBytes.length == 0) {
      throw (logon == false ? _myException : new Exception());
    }
    int nextByte = nextBytes[0];
    for(int i=0;i<encoded.length;i++) {
      if(nextByte == encoded[i]) {
        _index += 1;
        return nextByte;
      }
    }
  }

  int nextByteFromBytesSync(List<int> encoded) {
    int nextByte = _buffer[index];
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
  FutureOr<int> checkBytes(List<int> encoded) {
    if(_buffer.currentSize >= index+encoded.length) {
      return checkBytesSync(encoded);
    } else {
      return checkBytesAsync(encoded);
    }
  }

  Future<int> checkBytesAsync(List<int> encoded) async {
    await waitByBuffered(index, encoded.length);
    return checkBytesSync(encoded);
  }

  int checkBytesSync(List<int> encoded) {
    if (index + encoded.length > _buffer.currentSize) {
      return 0;
    }
    for(int j=0;j<encoded.length;j++) {
      if(_buffer[j+index] != encoded[j]){
        return 0;
      }
    }
    return encoded.length;
  }

  //
  //
  FutureOr<int> checkBytesFromMatcher(EasyParserMatchFunc matcher, {bool expectedMatcherResult:true}) {
    int r = checkBytesFromMatcherSync(matcher, expectedMatcherResult:expectedMatcherResult);
    if (r == 0 && _buffer.currentSize > index) {
      return r;
    }
    else if(r > 0) {
      return r;
    } else {
      return checkBytesFromMatcherAsync(matcher, expectedMatcherResult:expectedMatcherResult, length: -1*r);
    }
  }

  Future<int> checkBytesFromMatcherAsync(EasyParserMatchFunc matcher, {bool expectedMatcherResult:true, int length:0}) async {
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

  int checkBytesFromMatcherSync(EasyParserMatchFunc matcher, {bool expectedMatcherResult:true, int length:0}) {
    int nextByte = 0;
    while(true) ROOT:{
      if (_buffer.currentSize > index) {
        nextByte = _buffer[index+length];
      } else {
        return -1*length;
      }
      if(expectedMatcherResult != matcher(nextByte)) {
        break;
      } else {
        length += 1;
      }
    }
    return length;
  }

  FutureOr<int> checkString(String value) => checkBytes(convert.UTF8.encode(value));

  FutureOr<int> checkBytesFromMatchBytes(List<int> encoded) => checkBytesFromBytes(encoded, expectedMatcherResult:true);

  FutureOr<int> checkBytesFromUnmatchBytes(List<int> encoded) => checkBytesFromBytes(encoded, expectedMatcherResult:false);

  FutureOr<int> checkBytesFromBytes(List<int> encoded,{bool expectedMatcherResult:true}) {
    return checkBytesFromMatcher((int target){
      for (int i = 0; i < encoded.length; i++) {
        if (target == encoded[i]) {
          return true;
        }
      }
      return false;
    }, expectedMatcherResult:expectedMatcherResult);
  }

  //
  // MATCH
  //
  FutureOr<List<int>> matchBytesFromBytes(List<int> encoded, {bool expectedMatcherResult:true}) {
    FutureOr<int> lenFOr = checkBytesFromBytes(encoded, expectedMatcherResult:expectedMatcherResult);
    if(lenFOr is Future<int>) {
      return lenFOr.then((int len) {
        data.Uint8List ret = new data.Uint8List(len);
        for(int i=0;i<len;i++) {
          ret[i] = _buffer[i+index];
        }
        _index += len;
        return ret;
      });
    } else {
      int len = lenFOr as int;
      data.Uint8List ret = new data.Uint8List(len);
      for(int i=0;i<len;i++) {
        ret[i] = _buffer[i+index];
      }
      _index += len;
      return ret;
    }
  }

  FutureOr<List<int>> matchBytesFromMatche(EasyParserMatchFunc func, {bool expectedMatcherResult:true}) {
    FutureOr<int> lenFOr = checkBytesFromMatcher(func, expectedMatcherResult:expectedMatcherResult);
    if(lenFOr is Future<int>) {
      return lenFOr.then((int len) {
        data.Uint8List ret = new data.Uint8List(len);
        for(int i=0;i<len;i++) {
          ret[i] = _buffer[i+index];
        }
        _index += len;
        return ret;
      });
    } else {
      int len = lenFOr as int;
      data.Uint8List ret = new data.Uint8List(len);
      for(int i=0;i<len;i++) {
        ret[i] = _buffer[i+index];
      }
      _index += len;
      return ret;
    }
  }

  //
  // GET
  //
  FutureOr<List<int>> getBytes(int length, {moveOffset:true}) {
    if(_buffer.currentSize >= index+length) {
      return getBytesSync(length, moveOffset:moveOffset);
    } else {
      return getBytesAsync(length, moveOffset:moveOffset);
    }
  }

  List<int> getBytesSync(int length, {moveOffset:true}) {
    List<int> out = new data.Uint8List(length >= 0 ? length : 0);
    for (int i = 0; i < length; i++) {
      print("${i} ${out.length} ${_buffer.currentSize} ${index} ${length}");
      out[i] = _buffer[index + i];
    }
    if(moveOffset) {
      _index += out.length;
    }
    return out;
  }

  Future<List<int>> getBytesAsync(int length, {bool checkLength:false, moveOffset:true}) async {
    int newLength = await waitByBuffered(index, length, checkLength:checkLength);
    return getBytesSync(newLength, moveOffset:moveOffset);
  }

  //
  // READ
  //
  FutureOr<int> readBytes(int length, List<int> out, {int offset:0, bool checkLength:false, moveOffset:true}) {
    if(_buffer.currentSize >= index+length) {
      return readBytesSync(length, out, offset:offset, moveOffset: moveOffset);
    } else {
      return readBytesAsync(length,out, offset:offset, checkLength: checkLength, moveOffset: moveOffset);
    }
  }

  int readBytesSync(int length, List<int> out, {int offset:0, moveOffset:true}) {
    for (int i = 0; i < length; i++) {
      out[offset+i] = _buffer[index + i];
    }
    if(moveOffset) {
      _index += length;
    }
    return length;
  }

  Future<int> readBytesAsync(int length, List<int> out,{int offset:0, bool checkLength:false, moveOffset:true}) async {
    int newLength = await waitByBuffered(index, length, checkLength:checkLength);
    return readBytesSync(newLength, out, offset: offset, moveOffset: moveOffset);
  }

  //
  //
  FutureOr<String> readSign(int byteLength, {moveOffset:true}) {
    if(_buffer.currentSize >= index+byteLength) {
      return readSignSync(byteLength, moveOffset: moveOffset);
    } else {
      return readSignAsync(byteLength, moveOffset: moveOffset);
    }
  }

  Future<String> readSignAsync(int byteLength, {moveOffset:true}) async {
    await waitByBuffered(index, byteLength, checkLength: true);
    return readSignSync(byteLength, moveOffset: moveOffset);
  }

  String readSignSync(int byteLength, {moveOffset:true}) {
    List<int> va = getBytesSync(byteLength);
    String ret = _utfDecoder.convert(va, 0, byteLength);
    if(moveOffset) {
      _index += byteLength;
    }
    return ret;
  }

  //
  FutureOr<int> readLong(ByteOrderType byteorder, {moveOffset:true}) async {
    if(_buffer.currentSize >= index+8) {
      return readLongSync(byteorder, moveOffset: moveOffset);
    } else {
      return readLongAsync(byteorder, moveOffset: moveOffset);
    }
  }

  int readLongSync(ByteOrderType byteorder, {moveOffset:true}) {
    int ret = ByteOrder.parseLong(_buffer, 0, byteorder);
    if(moveOffset) {
      _index += 8;
    }
    return ret;
  }

  Future<int> readLongAsync(ByteOrderType byteorder, {moveOffset:true}) async {
    await waitByBuffered(index, 8, checkLength: true);
    return readLongSync(byteorder, moveOffset: moveOffset);
  }

  //
  //
  FutureOr<int> readInt(ByteOrderType byteorder, {moveOffset:true}) {
    if(_buffer.currentSize >= index+4) {
      return readIntSync(byteorder, moveOffset: moveOffset);
    } else {
      return readIntAsync(byteorder, moveOffset: moveOffset);
    }
  }

  int readIntSync(ByteOrderType byteorder, {moveOffset:true}) {
    int ret = ByteOrder.parseInt(_buffer, 0, byteorder);
    if(moveOffset) {
      _index += 4;
    }
    return ret;
  }

  Future<int> readIntAsync(ByteOrderType byteorder, {moveOffset:true}) async {
    await waitByBuffered(index, 4, checkLength: true);
    return readIntSync(byteorder, moveOffset: moveOffset);
  }

  //
  //
  FutureOr<int> readShort(ByteOrderType byteorder, {moveOffset:true}) {
    if(_buffer.currentSize >= index+2) {
      return readShortSync(byteorder, moveOffset: moveOffset);
    } else {
      return readShortAsync(byteorder, moveOffset: moveOffset);
    }
  }

  int readShortSync(ByteOrderType byteorder, {moveOffset:true}) {
    int ret = ByteOrder.parseShort(_buffer, 0, byteorder);
    if(moveOffset) {
      _index += 2;
    }
    return ret;
  }

  Future<int> readShortAsync(ByteOrderType byteorder, {moveOffset:true}) async {
    await waitByBuffered(index, 2, checkLength: true);
    return readShortSync(byteorder, moveOffset: moveOffset);
  }

  //
  //
  FutureOr<int> readByte({moveOffset:true}) {
    if(_buffer.currentSize >= index+1) {
      return readByteSync(moveOffset: moveOffset);
    } else {
      return readByteAsync(moveOffset: moveOffset);
    }
  }

  int readByteSync({moveOffset:true}) {
    int ret = _buffer[_index];
    if(moveOffset) {
      _index++;
    }
    return ret;
  }

  Future<int> readByteAsync({moveOffset:true}) async {
    await waitByBuffered(index, 1,checkLength: true);
    return  readByteSync(moveOffset: moveOffset);
  }
}


class EasyParseError extends Error {
  EasyParseError();
}
