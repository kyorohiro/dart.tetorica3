part of hetimadata;

abstract class DataBuilder {
  Future<Data> createHetimaData(String path);
}

abstract class Data implements DataReader, DataWriter {
  bool get writable => false;
  bool get readable => false;
  Future<int> getLength();
  Future<WriteResult> write(Object buffer, int start,[int length=null]);
  Future<ReadResult> read(int offset, int length, {List<int> tmp: null});
  void beToReadOnly();
}

abstract class DataWriter {
  Future<int> getLength();
  Future<WriteResult> write(Object o, int start,[int length=null]);
}

abstract class DataReader {
  Future<int> getLength();
  Future<ReadResult> read(int offset, int length);
}

class WriteResult {}

class ReadResult {
  List<int> buffer;
  int index = 0;
  int length = 0;
  ReadResult(List<int> _buffer, {int index = 0, int length = -1}) {
    buffer = _buffer;
    this.index = index;
    if (length < 0) {
      this.length = _buffer.length;
    } else {
      this.length = length;
    }
  }
}
