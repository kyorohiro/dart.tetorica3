part of hetimadata;

abstract class TetBuffer {
  int get bufferSize;
  int get bufferIndex;
  int get length;
  int operator [](int index);
  void operator []=(int index, int value);
  List<int> sublist(int start, int end);
  void clearBuffer(int len, {bool reuse: true});
  void expandBuffer(int nextMax);
}
