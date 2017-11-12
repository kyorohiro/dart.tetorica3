part of hetimacore;

abstract class HetimaDataBuilder {
  Future<HetimaData> createHetimaData(String path);
}

abstract class HetimaData implements HetimaFileReader, HetimaFileWriter {
  bool get writable => false;
  bool get readable => false;
  Future<int> getLength();
  Future<WriteResult> write(Object buffer, int start,[int length=null]);
  Future<ReadResult> read(int offset, int length, {List<int> tmp: null});
  void beToReadOnly();
}

abstract class HetimaFileWriter {
  Future<int> getLength();
  Future<WriteResult> write(Object o, int start,[int length=null]);
}

abstract class HetimaFileReader {
  Future<int> getLength();
  Future<ReadResult> read(int offset, int length);
}

class WriteResult {}

class ReadResult {
  List<int> buffer;
  int length = 0;
  ReadResult(List<int> _buffer, [int length = -1]) {
    buffer = _buffer;
    if (length < 0) {
      this.length = _buffer.length;
    } else {
      this.length = length;
    }
  }
}
