part of hetimadata;

abstract class DataBuilder {
  Future<Data> createHetimaData(String path);
}

abstract class Data implements DataReader, DataWriter {
  bool get writable => false;
  bool get readable => false;
  Future<int> getLength();
  Future<DataWriter> write(Object buffer, int start, {int length=null});
  Future<List<int>> getBytes(int offset, int length);
  Future<int> read(int offset, int length, data.Uint8List out, {int outOffset:0});
}

abstract class DataWriter {
  Future<int> getLength();
  Future<DataWriter> write(Object o, int start, {int length=null});
}

abstract class DataReader {
  Future<int> getLength();
  Future<List<int>> getBytes(int offset, int length);
}

