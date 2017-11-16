part of hetimanet_http;

class LengthParserReader extends ParserReaderBase {
  bool _started = false;
  ParserBuffer _buffer = new ParserBuffer();
  ParserReader _base = null;

  LengthParserReader(ParserReader builder) {
    _base = builder;
    start();
  }

  LengthParserReader start() {
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
      parser.index += v.length;
      if (v.length == 0) {
        break;
      }
      await HetiHttpResponse.decodeCrlf(parser);
    }
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
