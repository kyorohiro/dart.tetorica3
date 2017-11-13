part of hetimaparsr;

abstract class ParserReader {

  //
  // async
  Future<int> getIndex(int index, int length);
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

  //
  // helper
  Future<List<int>> getAllBytes({bool allowMalformed: true});
  Future<String> getAllString({bool allowMalformed: true});

}

abstract class ParserAppender {
  void appendByte(int v);
  void appendIntList(List<int> buffer, [int index = 0, int length = -1]);
}

abstract class ParserReaderBase extends ParserReader {

  //
  // need override
  Future<int> getIndex(int index, int length);
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

class ParserReaderWithIndex extends ParserReaderBase {
  ParserReader _base = null;
  int _start = 0;
  int operator [](int index) {
    return _base[index + _start];
  }

  ParserReaderWithIndex(ParserReader base, int start) {
    _base = base;
    _start = start;
  }

  Future<int> getLength() {
    Completer<int> completer = new Completer();
    _base.getLength().then((int v) {
      completer.complete(v - _start);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  int get currentSize {
    return _base.currentSize - _start;
  }

  void unusedBuffer(int len) {
    _base.unusedBuffer(len);
  }

  Completer<bool> get loadCompletedCompleter => _base.loadCompletedCompleter;


  Future<List<int>> getBytes(int index, int length, {List<int> out: null}) async {
    return await _base.getBytes(index + _start, length);
  }

  Future<int> getIndex(int index, int length) async {
    return await _base.getIndex(index + _start, length);
  }

  bool get loadCompleted => _base.loadCompleted;

  void set loadCompleted(bool v) {
    _base.loadCompleted = v;
  }

}
