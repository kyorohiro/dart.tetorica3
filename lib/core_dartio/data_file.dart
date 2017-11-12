part of hetimacore_dartio;

class HetimaDataDartIO extends HetimaData {
  RandomAccessFile _randomFile = null;
  bool _readOnly = false;
  HetimaDataDartIO(String path,{erace: false}) {
    File _f = new File(path);
    if(erace == true) {
      _randomFile = _f.openSync(mode: FileMode.WRITE);
    } else {
      _randomFile = _f.openSync(mode: FileMode.APPEND);
    }
  }

  @override
  void beToReadOnly() {
    _readOnly = true;
  }

  @override
  Future<int> getLength() => _randomFile.length();

  @override
  Future<ReadResult> read(int offset, int length, {List<int> tmp: null}) async {
    if (tmp == null) {
      tmp = new data.Uint8List(length);
    }
    await _randomFile.setPosition(offset);
    int l = await _randomFile.readInto(tmp, 0, length);
    return new ReadResult(tmp, l);
  }

  @override
  Future<WriteResult> write(Object buffer, int start, [int length=null]) async {
    if (_readOnly == false) {
      if(length == null) {
        length = (buffer as List).length;
      }
      await _randomFile.setPosition(start);
      await _randomFile.writeFrom(buffer, 0, length);
    }
    return new WriteResult();
  }

  Future<int> truncate(int fileSize) async {
    await _randomFile.truncate(fileSize);
    return 0;
  }

  Future close() async {
    await _randomFile.close();
  }

  static Future<List<String>> getFiles(String path) async {
    Directory d = new Directory(path);
    List<FileSystemEntity> l = await d.list().toList();
    List<String> ret = [];
    for (FileSystemEntity e in l) {
      ret.add(e.path);
    }
    return ret;
  }

  static Future removeFile(String filename, {persistent: false}) async {
    if (await FileSystemEntity.isDirectory(filename)) {
      Directory d = new Directory(filename);
      return d.delete(recursive: true);
    } else if (await FileSystemEntity.isFile(filename)) {
      File f = new File(filename);
      return f.delete();
    }
  }
}

class HetimaDataDartIOBuilder extends HetimaDataBuilder {
  Future<HetimaData> createHetimaData(String path) async {
    return new HetimaDataDartIO(path);
  }
}
