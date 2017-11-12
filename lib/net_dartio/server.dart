part of hetimanet_dartio;

class TetServerSocketDartIo extends TetServerSocket {
  bool _verbose = false;
  bool get verbose => _verbose;

  ServerSocket _server = null;
  StreamController<TetSocket> _acceptStream = new StreamController.broadcast();
  TetSocketMode _mode = TetSocketMode.bufferAndNotify;

  TetServerSocketDartIo(ServerSocket server, {verbose: false, TetSocketMode mode:TetSocketMode.bufferAndNotify}) {
    _verbose = verbose;
    _server = server;
    _mode = mode;
    _server.listen((Socket socket) {
      _acceptStream.add(new TetSocketDartIo.fromSocket(socket, verbose: _verbose, mode:mode));
    });
  }

  static Future<TetServerSocket> startServer(String address, int port,
      {verbose: false,TetSocketMode mode:TetSocketMode.bufferAndNotify}) async {
    ServerSocket server = await ServerSocket.bind(address, port);
    return new TetServerSocketDartIo(server, verbose: verbose, mode:mode);
  }

  @override
  void close() {
    _server.close();
  }

  @override
  Stream<TetSocket> onAccept() {
    return _acceptStream.stream;
  }
}
