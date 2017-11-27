part of hetimaparsr;

abstract class ParserReaderBaseBase extends ParserReaderBase {
  //
  List<WaitByBufferedItem> mWaitByBufferedItemList = new List();
  bool cached(int index, int length) => (this.loadCompleted == true || index + length <= currentSize);

  FutureOr<int> waitByBuffered(int index, int length) {
    if (true == cached(index, length)) {
      if(index + length <= currentSize) {
        return length;
      } else {
        return currentSize - index;
      }
    } else {
      WaitByBufferedItem info = new WaitByBufferedItem();
      info.length = length;
      info.index = index;
      info.completer = new Completer();
      mWaitByBufferedItemList.add(info);
      return info.completer.future;
    }
  }

  void updatedBytes() {
    var removeList = null;
    for (WaitByBufferedItem f in mWaitByBufferedItemList) {
      if (true == cached(f.index, f.length)) {
        int len = f.length;
        if(this.loadCompleted==true && currentSize < f.index+f.length){
          len = currentSize -f.index;
        }
        f.completer.complete(len);
        if (removeList == null) {
          removeList = [];
        }
        removeList.add(f);
      }
    }
    if (removeList != null) {
      for (WaitByBufferedItem f in removeList) {
        mWaitByBufferedItemList.remove(f);
      }
    }
  }

  @override
  void set loadCompleted(bool v) {
    super.loadCompleted = true;
    updatedBytes();
    mWaitByBufferedItemList.clear();
  }

  FutureOr<int> readBytes(int index, int length, List<int> buffer) {
    if(length == 0) {
      return 0;
    }
    if(!cached(index, length)) {
      return _readBytes_00(index, length, buffer);
    }
    return _readBytes_01(index, length, buffer);
  }

  Future<int> _readBytes_00(int index, int length, List<int> buffer) async {
    if(!cached(index, length)) {
      await waitByBuffered(index, length);
    }
    return _readBytes_01(index, length, buffer);
  }

  int _readBytes_01(int index, int length, List<int> buffer)  {
    int len = currentSize - index;
    len = (len > length ? length : len);
    for (int i = 0; i < len; i++) {
      buffer[i] = this[index + i];
    }
    return len;
  }

  //
  //
  FutureOr<List<int>> getBytes(int index, int length) {
    if(length == 0) {
      return [];
    }
    if(!cached(index, length)) {
      return _getBytes_00(index, length);
    }
    return _getBytes_01(index, length);
  }

  FutureOr<List<int>> _getBytes_00(int index, int length) async {
    if(!cached(index, length)) {
      await waitByBuffered(index, length);
    }
    return _getBytes_01(index, length);
  }

  List<int> _getBytes_01(int index, int length) {
    int len = currentSize - index;
    len = (len > length ? length : len);
    List<int> out = new data.Uint8List(len >= 0 ? len : 0);
    for (int i = 0; i < len; i++) {
      out[i] = this[index + i];
    }
    return out;
  }

}


class WaitByBufferedItem {
  int length = 0;
  int index = 0;
  Completer<int> completer = null;
}
