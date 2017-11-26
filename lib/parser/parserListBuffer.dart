part of hetimaparsr;

class ParserListBuffer extends ParserReaderBaseBase implements ParserAppender, ParserReader, ParserBuffer {
  int _length = 0;
  int _clearedBuffer = 0;
  int get clearedBuffer =>  _clearedBuffer;
  List<List<int>> buffers = [];

  ParserListBuffer() {}

  bool cached(int index, int length) => (this.loadCompleted == true || index + length <= _length);


  //
  //
  int operator [](int index) {
    if(index < _clearedBuffer) {
      return 0;
    }
    int s = _clearedBuffer;
    for(List<int> buffer in buffers) {
      if(index >=s  && s+buffer.length >index) {
        return buffer[index-s];
      }
      s += buffer.length;
    }
    throw "invalid";
  }

  void clear() {
    _length = 0;
    _clearedBuffer = 0;
    buffers.clear();
  }

  void unusedBuffer(int len, {reuse: true}) {
    if(len <_clearedBuffer) {
      return;
    }
    int tmpLen = len -_clearedBuffer;
    while(buffers.length > 0) {
      List<int> buffer = buffers.first;
      if(buffer.length <= tmpLen) {
        buffers.removeAt(0);
        tmpLen -= buffer.length;
        _clearedBuffer += buffer.length;
      } else {
        break;
      }
    }
  }

  List<int> getAndUnusedBuffer() {
    if(buffers.length <=0) {
      return [];
    }
    List<int> ret = buffers.removeAt(0);;
    _clearedBuffer += ret.length;
    return ret;
  }

  int get currentSize => _length;

  Future<int> getLength() async => _length;

  void addByte(int v, {bool autoUpdate = true}) {
    addBytes([v], autoUpdate: autoUpdate);
  }

  void addBytes(List<int> buffer, {int index = 0, int length = -1, bool autoUpdate = true}) {
    if (loadCompleted) {
      return;
    }
    if (index > 0 && length < 0) {
      buffer = buffer.sublist(index);
    } else if(length > 0){
      buffer = buffer.sublist(index, length);
    }
    buffers.add(buffer);
    _length += buffer.length;
    if(autoUpdate) {
      updatedBytes();
    }
  }

  void appendString(String text) => addBytes(convert.UTF8.encode(text));

  List toList() => toUint8List();

  data.Uint8List toUint8List() {
    data.Uint8List ret = new data.Uint8List(_length);
    for (int j = 0; j < ret.lengthInBytes; j++) {
      ret[j] = this[j];
    }
    return ret;
  }

  String toText() => convert.UTF8.decode(toList());
}

