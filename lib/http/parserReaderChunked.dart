part of hetimanet_http;

class ChunkParserReader extends ParserReaderBase {
  bool _started = false;
  ParserBuffer _buffer = new ParserBuffer();
  ParserReader _base = null;

  ChunkParserReader(ParserReader builder) {
    _base = builder;
    start();
  }

  ChunkParserReader start() {
    if (_started == true) {
      return this;
    }
    _started = true;
    _decodeChunked(new EasyParser(_base)).catchError((e) {}).then((e) {
      _buffer.loadCompleted = true;
    });
    return this;
  }

  Future _decodeChunked(EasyParser parser) async {
    while (true) {
      int size = await HetiHttpResponse.decodeChunkedSize(parser);
      List<int> v = await parser.buffer.getBytes(parser.index, size);
      _buffer.addBytes(v, index:0, length:v.length);
      //_base.unusedBuffer(_buffer.currentSize);
      parser.index += v.length;
      if (v.length == 0) {
        break;
      }
      await HetiHttpResponse.decodeCrlf(parser);
    }
  }

  void unusedBuffer(int len) {
    _base.unusedBuffer(len);
    _buffer.unusedBuffer(len);
  }

  int get currentSize {
    return _buffer.currentSize;
  }

  Future<int> getLength() {
    return _buffer.getLength();
  }

  Completer<bool> get loadCompletedCompleter => _buffer.loadCompletedCompleter;

  Future<List<int>> getBytes(int index, int length, {List<int> out: null}) {
    return _buffer.getBytes(index, length, out: out);
  }

  Future<int> waitByBuffered(int index, int length) {
    return _buffer.waitByBuffered(index, length);
  }

  int operator [](int index) {
    return _base[index];
  }
}
