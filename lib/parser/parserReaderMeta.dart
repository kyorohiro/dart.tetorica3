part of hetimaparsr;


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
    _base.unusedBuffer(len + _start);
  }

  Completer<bool> get loadCompletedCompleter => _base.loadCompletedCompleter;


  List<int> getAndUnusedBuffer() {
    throw "unsupported";
  }

  FutureOr<List<int>> getBytes(int index, int length, {List<int> out: null}){
    return _base.getBytes(index + _start, length);
  }

  FutureOr<int> readBytes(int index, int length, List<int> buffer) {
    return _base.readBytes(index + _start, length, buffer);
  }

  FutureOr<int> waitByBuffered(int index, int length) {
    return (_base.waitByBuffered(index + _start, length) - _start);
  }

  bool get loadCompleted => _base.loadCompleted;

  void set loadCompleted(bool v) {
    _base.loadCompleted = v;
  }

}
