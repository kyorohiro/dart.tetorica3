part of hetimaparsr;

abstract class ParserReader implements DataReader {
  //
  // async
  FutureOr<int> waitByBuffered(int index, int length);
  FutureOr<List<int>> getBytes(int index, int length);
  FutureOr<int> readBytes(int index, int length, List<int> buffer);
  Future<int> getLength();

  // buffer
  int get currentSize;
  int operator [](int index);
  void unusedBuffer(int len);
  List<int> getAndUnusedBuffer();
  //
  // complete check
  Completer<bool> get loadCompletedCompleter;
  bool get loadCompleted;
  void set loadCompleted(bool v);
  Future<ParserReader> waitByLoadCompleted();

  //
  // helper
  Future<List<int>> getAllBytes({bool allowMalformed: true});
  Future<String> getAllString({bool allowMalformed: true});
}

abstract class ParserBuffer implements ParserReader, ParserAppender {}

abstract class ParserAppender {
  void updatedBytes();
  void addByte(int v, {bool autoUpdate = true});
  void addBytes(List<int> buffer, {int index = 0, int length = -1, bool autoUpdate = true});
}

abstract class ParserReaderBase extends ParserReader {
  //
  // need override
  FutureOr<int> waitByBuffered(int index, int length);
  FutureOr<List<int>> getBytes(int index, int length);
  Future<int> getLength();

  // buffer
  int get currentSize;
  int operator [](int index);
  void unusedBuffer(int len) {}

  //
  //
  Completer<bool> get loadCompletedCompleter => _loadCompletedCompleter;
  bool get loadCompleted => _loadCompleted;
  void set loadCompleted(bool v) {
    if (_loadCompleted == false && v == true) {
      _loadCompletedCompleter.complete(true);
      _loadCompleted = true;
    } else {
      // not define
    }
  }

  Future<ParserReader> waitByLoadCompleted() async {
    await loadCompletedCompleter.future;
    return this;
  }

  //
  //
  Future<List<int>> getAllBytes({bool allowMalformed: true}) async {
    if (_loadCompleted == false) {
      await loadCompletedCompleter.future;
    }
    int length = await getLength();
    return await getBytes(0, length);
  }

  Future<String> getAllString({bool allowMalformed: true}) async {
    return convert.UTF8
        .decode(await getAllBytes(), allowMalformed: allowMalformed);
  }

  bool _loadCompleted = false;
  Completer<bool> _loadCompletedCompleter = new Completer();
  //
  //
  //
  List<WaitByBufferedItem> mWaitByBufferedItemList = new List();
}

abstract class ParserReaderBaseBase extends ParserReaderBase {
  //
  List<WaitByBufferedItem> mWaitByBufferedItemList = new List();
  bool cached(int index, int length) => (this.loadCompleted == true || index + length <= currentSize);

  FutureOr<int> waitByBuffered(int index, int length) {
    if (true == cached(index, length)) {
      return length;
    } else {
      WaitByBufferedItem info = new WaitByBufferedItem();
      info.completerResultLength = length;
      info.index = index;
      info.completer = new Completer();
      mWaitByBufferedItemList.add(info);
      return info.completer.future;
    }
  }

  void updatedBytes() {
    var removeList = null;
    for (WaitByBufferedItem f in mWaitByBufferedItemList) {
      if (true == cached(f.index, f.completerResultLength)) {
        int len = f.completerResultLength;
        if(this.loadCompleted==true && currentSize < f.index+f.completerResultLength){
          len = currentSize -f.index;
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
}