part of hetimacore_dartio;

class HetimaDataDartIO extends Data {
  io.RandomAccessFile _randomFile = null;
  bool _readOnly = false;
  HetimaDataDartIO(String path,{erace: false}) {
    io.File _f = new io.File(path);
    if(erace == true) {
      _randomFile = _f.openSync(mode: io.FileMode.WRITE);
    } else {
      _randomFile = _f.openSync(mode: io.FileMode.APPEND);
    }
  }

  @override
  Future<int> getLength() => _randomFile.length();

  @override
  Future<List<int>> getBytes(int offset, int length) async {
    data.Uint8List tmp = new data.Uint8List(length);
    await _randomFile.setPosition(offset);
    int l = await _randomFile.readInto(tmp, 0, length);
    if(l == length) {
      return tmp;
    }
    return tmp.buffer.asUint8List(offset, l);
  }

  Future<int> read(int offset, int length, data.Uint8List out, {int outOffset:0}) async {
    await _randomFile.setPosition(offset);
    return await _randomFile.readInto(out, outOffset, outOffset+length);
  }

  @override
  Future<DataWriter> write(Object buffer, int start, {int length=null}) async {
    if (_readOnly == false) {
      if(length == null) {
        length = (buffer as List).length;
      }
      await _randomFile.setPosition(start);
      await _randomFile.writeFrom(buffer, 0, length);
    }
    return this;
  }

  Future<int> truncate(int fileSize) async {
    await _randomFile.truncate(fileSize);
    return 0;
  }

  Future<DataWriter> flush() async {
    _randomFile.flush();
    return this;
  }

  Future<DataReader> close() async {
    await _randomFile.close();
    return this;
  }

  static Future<List<String>> getFiles(String path) async {
    io.Directory d = new io.Directory(path);
    List<io.FileSystemEntity> l = await d.list().toList();
    List<String> ret = [];
    for (io.FileSystemEntity e in l) {
      ret.add(e.path);
    }
    return ret;
  }

  static Future removeFile(String filename, {persistent: false}) async {
    if (await io.FileSystemEntity.isDirectory(filename)) {
      io.Directory d = new io.Directory(filename);
      return d.delete(recursive: true);
    } else if (await io.FileSystemEntity.isFile(filename)) {
      io.File f = new io.File(filename);
      return f.delete();
    }
  }
}

class HetimaDataDartIOBuilder extends DataBuilder {
  Future<Data> createData(String path) async {
    return new HetimaDataDartIO(path);
  }
}
