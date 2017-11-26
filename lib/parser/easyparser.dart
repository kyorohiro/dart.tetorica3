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
  FutureOr<List<int>> nextBytes(List<int> encoded) async {
    if(0 == await checkBytes(encoded)){
      throw (logon == false ? _myException : new Exception());
    }
    _index +=encoded.length;
    return encoded;
  }

  FutureOr<String> nextString(String value) async {
    await nextBytes(convert.UTF8.encode(value));
    return value;
  }

  FutureOr<String> nextStringWithUpperLowerCase(String value) async {
    List<int> encoded = convert.UTF8.encode(value);
    await waitByBuffered(index, encoded.length, checkLength: true);

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
  FutureOr<int> checkBytes(List<int> encoded) {
    if(_buffer.currentSize < index+encoded.length) {
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

  FutureOr<int> checkString(String value) => checkBytes(convert.UTF8.encode(value));

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

  FutureOr<int> checkBytesFromMatchBytes(List<int> encoded) => checkBytesFromBytes(encoded, expectedMatcherResult:true);

  FutureOr<int> checkBytesFromUnmatchBytes(List<int> encoded) async => checkBytesFromBytes(encoded, expectedMatcherResult:false);


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
  // GET
  //
  FutureOr<List<int>> getBytes(int length, {moveOffset:true}) {
    if(_buffer.currentSize < index+length) {
      return getBytesSync(length, moveOffset:moveOffset);
    } else {
      return getBytesAsync(length, moveOffset:moveOffset);
    }
  }

  List<int> getBytesSync(int length, {moveOffset:true}) {
    List<int> out = new data.Uint8List(length >= 0 ? length : 0);
    for (int i = 0; i < length; i++) {
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
    if(_buffer.currentSize < index+length) {
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
    if(_buffer.currentSize < index+byteLength) {
      return readSignAsync(byteLength, moveOffset: moveOffset);
    } else {
      return readSignSync(byteLength, moveOffset: moveOffset);
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
    if(_buffer.currentSize < index+8) {
      return readLongAsync(byteorder, moveOffset: moveOffset);
    } else {
      return readLongSync(byteorder, moveOffset: moveOffset);
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
    if(_buffer.currentSize < index+4) {
      return readIntAsync(byteorder, moveOffset: moveOffset);
    } else {
      return readIntSync(byteorder, moveOffset: moveOffset);
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
    if(_buffer.currentSize < index+2) {
      return readShortAsync(byteorder, moveOffset: moveOffset);
    } else {
      return readShortSync(byteorder, moveOffset: moveOffset);
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
    if(_buffer.currentSize < index+1) {
      return readByteAsync(moveOffset: moveOffset);
    } else {
      return readByteSync(moveOffset: moveOffset);
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
