part of hetimaparsr;

class ParserByteBuffer extends ParserReaderBase implements ParserAppender, ParserReader, ParserBuffer {
  int _max = 1024;
  MemoryBuffer _buffer8;
  int _length = 0;

  MemoryBuffer get rawbuffer8 => _buffer8;
  List<WaitByBufferedItem> mWaitByBufferedItemList = new List();

  int get clearedBuffer => _buffer8.bufferIndex;

  bool logon = false;
  ParserByteBuffer({bufferSize: 1024}) {
    this.logon = logon;
    _max = bufferSize;
    _buffer8 = new MemoryBuffer(_max); //new data.Uint8List(_max);
  }

  ParserByteBuffer.fromList(List<int> buffer, [isFin = false]) {
    _buffer8 = new MemoryBuffer.fromList(buffer);
    _length = buffer.length;
    if (isFin == true) {
      loadCompleted = true;
//      fin();
    }
  }

  bool cached(int index, int length) => (this.loadCompleted == true || index + length <= _length);

  FutureOr<int> waitByBuffered(int index, int length) {
    if (true == cached(index, length)) {
      return index;
    } else {
      WaitByBufferedItem info = new WaitByBufferedItem();
      info.completerResultLength = length;
      info.index = index;
      info.completer = new Completer();
      mWaitByBufferedItemList.add(info);
      return info.completer.future;
    }
  }

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

  int _readBytes_01(int index, int length, List<int> buffer)  {
    int len = currentSize - index;
    len = (len > length ? length : len);
    for (int i = 0; i < len; i++) {
      buffer[i] = _buffer8[index + i];
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
      out[i] = _buffer8[index + i];
    }
    return out;
  }
  //
  //
  int operator [](int index) => 0xFF & _buffer8[index];

  int get(int index) => 0xFF & _buffer8[index];

  void clear() {
    _length = 0;
  }

  void unusedBuffer(int len, {reuse: true}) {
    _buffer8.unusedBuffer(len, reuse: reuse);
  }

  List<int> getAndUnusedBuffer() {
    int size = currentSize - _buffer8.bufferIndex;
    if(size > 1024*2) {
      size = 1024*2;
    }
    print("${size} ${currentSize} ${_buffer8.bufferIndex}");
    List<int> ret = _buffer8.sublist(_buffer8.bufferIndex, _buffer8.bufferIndex+size);
    unusedBuffer(_buffer8.bufferIndex+size);
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


  void update(int plusLength) {
    if (_length + plusLength < _max) {
      return;
    } else {
      int nextMax = _length + plusLength + (_max - _buffer8.bufferIndex);
      _buffer8.expandBuffer(nextMax);
      _max = nextMax;
    }
  }

  void updatedBytes() {
    var removeList = null;
    for (WaitByBufferedItem f in mWaitByBufferedItemList) {
      if (true == cached(f.index, f.completerResultLength)) {
        int len = f.completerResultLength;
        if(this.loadCompleted==true && _length < f.index+f.completerResultLength){
          len = _length -f.index;
          f.completerResultLength;
        }
        f.completer.complete(len);
        if (removeList == null) {
          removeList = [];
        }
        removeList.add(f);
      }
    }
    if (removeList != null) {
      for (WaitByBufferedItem f in removeList) {
        mWaitByBufferedItemList.remove(f);
      }
    }
  }

  void addByte(int v, {bool autoUpdate = true}) {
    if (loadCompleted) {
      return;
    }
    update(1);
    _buffer8[_length] = v;
    _length += 1;
    if(autoUpdate) {
      updatedBytes();
    }
  }

  void addBytes(List<int> buffer, {int index = 0, int length = -1, bool autoUpdate = true}) {
    //print("length : ${buffer.length}");
    if (loadCompleted) {
      return;
    }

    if (length < 0) {
      length = buffer.length;
    }
    update(length);

    for (int i = 0; i < length; i++) {
      _buffer8[_length + i] = buffer[index + i];
    }
    _length += length;
    if(autoUpdate) {
      updatedBytes();
    }
  }

  void appendString(String text) => addBytes(convert.UTF8.encode(text));

  List toList() => _buffer8.sublist(0, _length);

  data.Uint8List toUint8List() => new data.Uint8List.fromList(toList());

  String toText() => convert.UTF8.decode(toList());
}

class WaitByBufferedItem {
  int completerResultLength = 0;
  int index = 0;
  Completer<int> completer = null;
}
