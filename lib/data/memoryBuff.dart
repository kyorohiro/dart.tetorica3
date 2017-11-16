part of hetimadata;

class MemoryBuffer implements Buffer {
  //
  bool logon = false;

  //
  int _bufferIndex = 0;
  int _length = 0;
  List<int> _buffer8 = null;

  //
  List<int> get rawbuffer8 => _buffer8;

  @override
  int get bufferSize => _buffer8.length;

  @override
  int get bufferIndex => _bufferIndex;

  @override
  int get length => _length + _bufferIndex;

  MemoryBuffer(int max) {
    _length = max;
    _buffer8 = new data.Uint8List(max);
  }

  MemoryBuffer.fromList(List<int> buffer) {
    _length = buffer.length;
    _buffer8 = new data.Uint8List.fromList(buffer);
  }

  @override
  int operator [](int index) {
    return ((index - _bufferIndex >= 0) ? _buffer8[index - _bufferIndex] : 0);
  }

  @override
  void operator []=(int index, int value) {
    if (index >= _bufferIndex) {
      _buffer8[index - _bufferIndex] = value;
    }
  }

  @override
  List<int> sublist(int start, int end) {
    data.Uint8List ret = new data.Uint8List(end - start);
    for (int j = 0; j < end - start; j++) {
      ret[j] = this[j + start];
    }
    return ret;
  }

  @override
  void unusedBuffer(int len, {bool reuse: true}) {
    if (_bufferIndex >= len) {
      _length = len;
      _bufferIndex = len;
      return;
    } else if (length < len) {
      len = length;
    }
    int erace = len - _bufferIndex;

    if (reuse == false) {
      _buffer8 = _buffer8.sublist(erace);
      _length = _buffer8.length;
    } else {
      for (int i = 0; i + erace < _length; i++) {
        _buffer8[i] = _buffer8[i + erace];
      }
      _length = _length - erace;
    }
    _bufferIndex = len;
  }

  @override
  void expandBuffer(int nextMax) {
    nextMax = nextMax - _bufferIndex;
    if (_buffer8.length >= nextMax) {
      _length = nextMax;
      return;
    }
    data.Uint8List next = new data.Uint8List(nextMax);
    for (int i = 0; i < _buffer8.length; i++) {
      next[i] = _buffer8[i];
    }
    _buffer8 = null;
    _buffer8 = next;
    _length = _buffer8.length;
  }
}
