part of hetimaparsr;

abstract class ParserReader {

  //
  // async
  Future<int> waitByBuffered(int index, int length);
  Future<List<int>> getBytes(int index, int length, {List<int> out: null});
  Future<int> getLength();

  // buffer
  int get currentSize;
  int operator [](int index);
  void unusedBuffer(int len);

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


abstract class ParserAppender {
  void updatedBytes();
  void addByte(int v,{bool autoUpdate = true});
  void addBytes(List<int> buffer, {int index = 0, int length = -1, bool autoUpdate = true});
}


abstract class ParserReaderBase extends ParserReader {

  //
  // need override
  Future<int> waitByBuffered(int index, int length);
  Future<List<int>> getBytes(int index, int length, {List<int> out: null});
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
    if(_loadCompleted == false) {
      await loadCompletedCompleter.future;
    }
    int length = await getLength();
    return await getBytes(0, length);
  }

  Future<String> getAllString({bool allowMalformed: true}) async {
    return convert.UTF8.decode(await getAllBytes(), allowMalformed: allowMalformed);
  }


  bool _loadCompleted = false;
  Completer<bool> _loadCompletedCompleter = new Completer();

}
