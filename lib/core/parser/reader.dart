part of hetimacore;

abstract class TetReader {
  bool _immutable = false;
  Completer<bool> _completerFin = new Completer();

  Future<int> getIndex(int index, int length);
  Future<List<int>> getBytes(int index, int length, {List<int> out: null});
  Future<int> getLength();
  int get currentSize;
  int operator [](int index);

  Completer<bool> get rawcompleterFin => _completerFin;
  Future<bool> getStockedSignal() {
    return _completerFin.future;
  }

  Future<List<int>> getAllBytes({bool allowMalformed: true}) async {
    await getStockedSignal();
    int length = await getLength();
    return await getBytes(0, length);
  }

  Future<String> getString({bool allowMalformed: true}) async {
    return convert.UTF8.decode(await getAllBytes(), allowMalformed: allowMalformed);
  }

  void fin() {
    immutable = true;
  }

  bool get immutable => _immutable;
  void set immutable(bool v) {
    bool prev = _immutable;
    _immutable = v;
    if (prev == false && v == true) {
      _completerFin.complete(v);
    }
  }

  void clearInnerBuffer(int len) {
    ;
  }
}

class TetReaderAdapter extends TetReader {
  TetReader _base = null;
  int _startIndex = 0;
  int operator [](int index) {
    return _base[index + _startIndex];
  }

  TetReaderAdapter(TetReader builder, int startIndex) {
    _base = builder;
    _startIndex = startIndex;
  }

  Future<int> getLength() {
    Completer<int> completer = new Completer();
    _base.getLength().then((int v) {
      completer.complete(v - _startIndex);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  int get currentSize {
    return _base.currentSize;
  }

  Completer<bool> get rawcompleterFin => _base.rawcompleterFin;
  //
  Future<bool> getStockedSignal() => _base.getStockedSignal();

  Future<List<int>> getBytes(int index, int length, {List<int> out: null}) async {
    return await _base.getBytes(index + _startIndex, length);
  }

  Future<int> getIndex(int index, int length) async {
    return await _base.getIndex(index + _startIndex, length);
  }

  void fin() {
    _base.fin();
  }

  bool get immutable => _base.immutable;

  void set immutable(bool v) {
    _base.immutable = v;
  }
}
