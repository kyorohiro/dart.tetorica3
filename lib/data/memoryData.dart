part of hetimadata;

//
// todo test
//
class MemoryData extends Data {
  bool get writable => true;
  bool get readable => true;
  int _length = 0;
  int _expandSize = 1024;

  MemoryData({data.Uint8List buffer=null, int cacheSize:1024, int expandSize:1024}) {
    if(buffer != null) {
      _dataBuffer = buffer;
    } else {
      _dataBuffer = new data.Uint8List(cacheSize);
    }
    _expandSize = expandSize;
  }

  String toDebug() {
    return "${_dataBuffer}";
  }

  Future<int> getLength() async {
    return _dataBuffer.length;
  }

  void _expand(int length) {
    if(_dataBuffer.length > length) {
      return;
    }
    data.Uint8List next = new data.Uint8List(length);
    for(int i=0,len=_dataBuffer.length;i<len;i++) {
      next[i] = _dataBuffer[i];
    }
    _dataBuffer = next;
  }

  void _tryExpand(int length) {
    if(_dataBuffer.length > length) {
      return;
    } else if(_dataBuffer.length + _expandSize >length){
      _expand(_dataBuffer.length + _expandSize);
    } else {
      _expand(length + _expandSize);
    }
  }

  Future<DataWriter> write(Object buffer, int start, [int length=null]) async {
    if (!(buffer is List<int>)) {
      throw new UnsupportedError("");
    }
    List<int> buff = (buffer as List<int>);
    if (length == null) {
      length = buff.length;
    }
    _tryExpand(start+length);
    for (int i = 0; i < length; i++) {
        _dataBuffer[start + i] = buff[i];
    }
    _length += length;
    return this;
  }

  Future<List<int>> read(int offset, int length, {data.Uint8List tmp: null, int tmpStart:0}) async {
    int end = offset + length;
    if (end > _dataBuffer.length) {
      end = _dataBuffer.length;
    }
    if (offset >= end) {
      return [];
    }
    if(tmp == null) {
      return _dataBuffer.buffer.asUint8List(offset, end-offset);
    } else {
      for (int i = 0; i < length; i++) {
        tmp[i] = _dataBuffer[offset+i+tmpStart];
      }
    }

  }

  data.Uint8List _dataBuffer = null;
}
