part of hetimadata;


class MemoryData extends Data {
  bool get writable => true;
  bool get readable => true;

  MemoryData([List<int> buffer=null]) {
    if(buffer != null) {
      _dataBuffer = new List.from(buffer);
    } else {
      _dataBuffer = [];
    }
  }

  String toDebug() {
    return "${_dataBuffer}";
  }

  List<int> getBuffer(int start, int length) {
    int end = start + length;
    if (end > _dataBuffer.length) {
      end = _dataBuffer.length;
    }
    return _dataBuffer.sublist(start, end);
  }

  Future<int> getLength() {
    Completer<int> comp = new Completer();
    comp.complete(_dataBuffer.length);
    return comp.future;
  }

  Future<DataWriter> write(Object buffer, int start, [int length=null]) {
    Completer<DataWriter> comp = new Completer();
    if (buffer is List<int>) {
      if (_dataBuffer.length < start) {
        _dataBuffer.addAll(new List.filled(start - _dataBuffer.length, 0));
      }

      if (length == null) {
        length = buffer.length;
      }
      for (int i = 0; i < length; i++) {
        if (start + i < _dataBuffer.length) {
          _dataBuffer[start + i] = buffer[i];
        } else {
          _dataBuffer.add(buffer[i]);
        }
      }
      comp.complete(this);
    } else {
      // TODO
      throw new UnsupportedError("");
    }
    return comp.future;
  }

  Future<List<int>> read(int offset, int length, {data.Uint8List tmp: null}) async {
    int end = offset + length;
    if (end > _dataBuffer.length) {
      end = _dataBuffer.length;
    }
    if (offset >= end) {
      return [];
    } else {
      return _dataBuffer.sublist(offset, end);
    }
  }

  void beToReadOnly() {
    //
  }

  List<int> _dataBuffer = null;
}
