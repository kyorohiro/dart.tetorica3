part of hetimadata;

abstract class Buffer {
  int get bufferSize;
  int get bufferIndex;
  int get length;
  int operator [](int index);
  void operator []=(int index, int value);
  void unusedBuffer(int len, {bool reuse: true});
  void expandBuffer(int nextMax);
  //
  List<int> sublist(int start, int end);
}
