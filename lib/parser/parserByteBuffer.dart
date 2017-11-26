part of hetimaparsr;

class ParserByteBuffer extends ParserReaderBaseBase implements ParserAppender, ParserReader, ParserBuffer {
  int _max = 1024;
  MemoryBuffer _buffer8;
  int _length = 0;

  MemoryBuffer get rawbuffer8 => _buffer8;


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
    }
  }


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

  void update(int plusLength) {
    if (_length + plusLength < _max) {
      return;
    } else {
      int nextMax = _length + plusLength + (_max - _buffer8.bufferIndex);
      _buffer8.expandBuffer(nextMax);
      _max = nextMax;
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
