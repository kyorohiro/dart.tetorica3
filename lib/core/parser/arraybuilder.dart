part of hetimacore;

class ArrayBuilder extends TetReader {
  int _max = 1024;
  TetBufferPlus _buffer8;
  int _length = 0;

  TetBufferPlus get rawbuffer8 => _buffer8;
  List<GetByteFutureInfo> mGetByteFutreList = new List();

  int get clearedBuffer => _buffer8.bufferIndex;

  bool logon = false;
  ArrayBuilder({bufferSize: 1024}) {
    this.logon = logon;
    _max = bufferSize;
    _buffer8 = new TetBufferPlus(_max); //new data.Uint8List(_max);
  }

  ArrayBuilder.fromList(List<int> buffer, [isFin = false]) {
    _buffer8 = new TetBufferPlus.fromList(buffer);
    _length = buffer.length;
    if (isFin == true) {
      fin();
    }
  }

  bool _updateGetInfo(GetByteFutureInfo info) {
    if (this.immutable == true || info.index + info.completerResultLength - 1 < _length) {
      info.completer.complete(info.index);
      return true;
    } else {
      return false;
    }
  }

  void _updateGetInfos() {
    var removeList = null;
    for (GetByteFutureInfo f in mGetByteFutreList) {
      if (true == _updateGetInfo(f)) {
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

  Future<int> getIndex(int index, int length) {
    GetByteFutureInfo info = new GetByteFutureInfo();

    info.completerResultLength = length;
    info.index = index;
    info.completer = new Completer();

    if (false == _updateGetInfo(info)) {
      mGetByteFutreList.add(info);
    }

    return info.completer.future;
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

  void clearInnerBuffer(int len, {reuse: true}) {
    _buffer8.clearBuffer(len, reuse: reuse);
  }

  int get currentSize => _length;

  Future<int> getLength() async => _length;

  void fin() {
    immutable = true;
    _updateGetInfos();
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

  void appendByte(int v) {
    if (immutable) {
      return;
    }
    update(1);
    _buffer8[_length] = v;
    _length += 1;

    _updateGetInfos();
  }

  void appendIntList(List<int> buffer, [int index = 0, int length = -1]) {
    if (immutable) {
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
    _updateGetInfos();
  }

  void appendString(String text) => appendIntList(convert.UTF8.encode(text));

  List toList() => _buffer8.sublist(0, _length);

  data.Uint8List toUint8List() => new data.Uint8List.fromList(toList());

  String toText() => convert.UTF8.decode(toList());
}

class GetByteFutureInfo {
  int completerResultLength = 0;
  int index = 0;
  Completer<int> completer = null;
}
