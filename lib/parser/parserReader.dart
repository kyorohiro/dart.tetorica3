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
