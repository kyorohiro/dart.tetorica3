part of hetimaparsr;

class ParserListBuffer extends ParserReaderBase implements ParserAppender, ParserReader, ParserBuffer {
  int _length = 0;
  int _clearedBuffer = 0;
  int get clearedBuffer =>  _clearedBuffer;
  List<List<int>> buffers = [];

  ParserListBuffer() {}

  bool cached(int index, int length) => (this.loadCompleted == true || index + length <= _length);



  //
  //
  FutureOr<int> readBytes(int index, int length, List<int> buffer) {
    if(length == 0) {
      return 0;
    }
    if(!cached(index, length)) {
      return _readBytes_00(index, length, buffer);
    }
    return _readBytes_01(index, length, buffer);
  }

  Future<int> _readBytes_00(int index, int length, List<int> buffer) async {
    if(!cached(index, length)) {
      await waitByBuffered(index, length);
    }
    return _readBytes_01(index, length, buffer);
  }

  int _readBytes_01(int index, int length, List<int> buffer) {
    int len = currentSize - index;
    len = (len > length ? length : len);

    for (int i = 0; i < len; i++) {
      buffer[i] = this[index + i];
    }
    return len;
  }

  //
  //
  FutureOr<List<int>> getBytes(int index, int length) {
    if(length == 0) {
      return [];
    }
    if(!cached(index, length)) {
      return _getBytes_00(index, length);
    }
    return _getBytes_01(index, length);
  }

  FutureOr<List<int>> _getBytes_00(int index, int length) async {
    if(!cached(index, length)) {
      await waitByBuffered(index, length);
    }
    return _getBytes_01(index, length);
  }

  List<int> _getBytes_01(int index, int length) {
    int len = currentSize - index;
    len = (len > length ? length : len);
    List<int> out = new data.Uint8List(len >= 0 ? len : 0);
    for (int i = 0; i < len; i++) {
      out[i] = this[index + i];
    }
    return out;
  }

  //
  //
  int operator [](int index) {
    if(index < _clearedBuffer) {
      return 0;
    }
    int s = _clearedBuffer;
    for(List<int> buffer in buffers) {
      if(index >=s  && s+buffer.length >index) {
        return buffer[index-s];
      }
      s += buffer.length;
    }
    throw "invalid";
  }

  void clear() {
    _length = 0;
    _clearedBuffer = 0;
    buffers.clear();
  }

  void unusedBuffer(int len, {reuse: true}) {
    if(len <_clearedBuffer) {
      return;
    }
    int tmpLen = len -_clearedBuffer;
    while(buffers.length > 0) {
      List<int> buffer = buffers.first;
      if(buffer.length <= tmpLen) {
        buffers.removeAt(0);
        tmpLen -= buffer.length;
        _clearedBuffer += buffer.length;
      } else {
        break;
      }
    }
  }

  List<int> getAndUnusedBuffer() {
    if(buffers.length <=0) {
      return [];
    }
    List<int> ret = buffers.removeAt(0);;
    _clearedBuffer += ret.length;
    return ret;
  }

  int get currentSize => _length;

  Future<int> getLength() async => _length;

  @override
  void set loadCompleted(bool v) {
    super.loadCompleted = true;
    updatedBytes();
    mWaitByBufferedItemList.clear();
  }
  

  void addByte(int v, {bool autoUpdate = true}) {
    addBytes([v], autoUpdate: autoUpdate);
  }

  void addBytes(List<int> buffer, {int index = 0, int length = -1, bool autoUpdate = true}) {
    if (loadCompleted) {
      return;
    }
    if (index > 0 && length < 0) {
      buffer = buffer.sublist(index);
    } else if(length > 0){
      buffer = buffer.sublist(index, length);
    }
    buffers.add(buffer);
    _length += buffer.length;
    if(autoUpdate) {
      updatedBytes();
    }
  }

  void appendString(String text) => addBytes(convert.UTF8.encode(text));

  List toList() {
    return toUint8List();
  }

  data.Uint8List toUint8List() {
    data.Uint8List ret = new data.Uint8List(_length);
    for (int j = 0; j < ret.lengthInBytes; j++) {
      ret[j] = this[j];
    }
    return ret;
  }

  String toText() => convert.UTF8.decode(toList());
}

