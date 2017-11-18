part of hetimaparsr;

class ParserListBuffer extends ParserReaderBase implements ParserAppender, ParserReader {
  int _length = 0;
  int _clearedBuffer = 0;
  List<GetByteFutureInfo> mGetByteFutreList = new List();
  int get clearedBuffer =>  _clearedBuffer;
  List<List<int>> buffers = [];

  ParserListBuffer() {}

  bool cached(int index, int length) => (this.loadCompleted == true || index + length - 1 < _length);


  Future<int> waitByBuffered(int index, int length) async {
    if (false == cached(index, length)) {
      GetByteFutureInfo info = new GetByteFutureInfo();
      info.completerResultLength = length;
      info.index = index;
      info.completer = new Completer();
      mGetByteFutreList.add(info);
      return info.completer.future;
    } else {
      return index;
    }

  }

  Future<List<int>> getBytes(int index, int length, {List<int> out:null}) async {
    if(out != null && out.length < length) {
      throw new Exception();
    }
    else if(length == 0) {
      return [];
    }
    if(!cached(index, length)) {
    }
    return out;
  }

  int operator [](int index) {
    int s = 0;
    int e = 0;
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
  }

  void unusedBuffer(int len, {reuse: true}) {}

  int get currentSize => _length;

  Future<int> getLength() async => _length;

  @override
  void set loadCompleted(bool v) {
    super.loadCompleted = true;
    updatedBytes();
    mGetByteFutreList.clear();
  }

  void updatedBytes() {
    var removeList = null;
    for (GetByteFutureInfo f in mGetByteFutreList) {
      if (true == cached(f.index, f.completerResultLength)) {
        f.completer.complete(f.index);
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

  List toList() {
    return toUint8List();
  }

  data.Uint8List toUint8List() {
    data.Uint8List ret = new data.Uint8List(_length);
    for (int j = 0; j < ret.lengthInBytes; j++) {
      ret[j] = this[j];
    }
    return ret;
  }

  String toText() => convert.UTF8.decode(toList());
}

/*
class GetByteFutureInfo {
  int completerResultLength = 0;
  int index = 0;
  Completer<int> completer = null;
}
*/
