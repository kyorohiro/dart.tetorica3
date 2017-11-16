part of hetimaparsr;

class ParserBuffer extends ParserReaderBase implements ParserAppender, ParserReader {
  int _max = 1024;
  MemoryBuffer _buffer8;
  int _length = 0;

  MemoryBuffer get rawbuffer8 => _buffer8;
  List<GetByteFutureInfo> mGetByteFutreList = new List();

  int get clearedBuffer => _buffer8.bufferIndex;

  bool logon = false;
  ParserBuffer({bufferSize: 1024}) {
    this.logon = logon;
    _max = bufferSize;
    _buffer8 = new MemoryBuffer(_max); //new data.Uint8List(_max);
  }

  ParserBuffer.fromList(List<int> buffer, [isFin = false]) {
    _buffer8 = new MemoryBuffer.fromList(buffer);
    _length = buffer.length;
    if (isFin == true) {
      loadCompleted = true;
//      fin();
    }
  }

  bool cached(int index, int length) => (this.loadCompleted == true || index + length - 1 < _length);


  Future<int> getIndex(int index, int length) async {
    if (false == cached(index, length)) {
      GetByteFutureInfo info = new GetByteFutureInfo();
      info.completerResultLength = length;
      info.index = index;
      info.completer = new Completer();
      mGetByteFutreList.add(info);
      return info.completer.future;
    } else {
      return index;
    }

  }

  Future<List<int>> getBytes(int index, int length, {List<int> out:null}) async {
    if(out != null && out.length < length) {
      throw new Exception();
    }
    if(length == 0) {
      return [];
    }
    await getIndex(index, length);
    int len = currentSize - index;
    len = (len > length ? length : len);
    if(out == null) {
      out = new data.Uint8List(len >= 0 ? len : 0);
    }
    for (int i = 0; i < len; i++) {
      out[i] = _buffer8[index + i];
    }
    return out;
  }

  int operator [](int index) => 0xFF & _buffer8[index];

  int get(int index) => 0xFF & _buffer8[index];

  void clear() {
    _length = 0;
  }

  void unusedBuffer(int len, {reuse: true}) {
    _buffer8.unusedBuffer(len, reuse: reuse);
  }

  int get currentSize => _length;

  Future<int> getLength() async => _length;

  @override
  void set loadCompleted(bool v) {
    super.loadCompleted = true;
    updatedBytes();
    mGetByteFutreList.clear();
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
    for (GetByteFutureInfo f in mGetByteFutreList) {
      if (true == cached(f.index, f.completerResultLength)) {
        f.completer.complete(f.index);
        if (removeList == null) {
          removeList = [];
        }
        removeList.add(f);
      }
    }
    if (removeList != null) {
      for (GetByteFutureInfo f in removeList) {
        mGetByteFutreList.remove(f);
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

class GetByteFutureInfo {
  int completerResultLength = 0;
  int index = 0;
  Completer<int> completer = null;
}
