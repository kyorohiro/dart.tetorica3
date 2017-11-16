part of hetimanet_dartio;

class TetServerSocketDartIo extends ServerSocket {
  bool _verbose = false;
  bool get verbose => _verbose;

  io.ServerSocket _server = null;
  StreamController<Socket> _acceptStream = new StreamController.broadcast();
  TetSocketMode _mode = TetSocketMode.bufferAndNotify;

  TetServerSocketDartIo(io.ServerSocket server, {verbose: false, TetSocketMode mode:TetSocketMode.bufferAndNotify}) {
    _verbose = verbose;
    _server = server;
    _mode = mode;
    _server.listen((io.Socket socket) {
      _acceptStream.add(new TetSocketDartIo.fromSocket(socket, verbose: _verbose, mode:mode));
    });
  }

  static Future<ServerSocket> startServer(String address, int port,
      {verbose: false,TetSocketMode mode:TetSocketMode.bufferAndNotify}) async {
    io.ServerSocket server = await io.ServerSocket.bind(address, port);
    return new TetServerSocketDartIo(server, verbose: verbose, mode:mode);
  }

  @override
  Future<ServerSocket> close() async {
    _server.close();
    return this;
  }

  @override
  Stream<Socket> onAccept() {
    return _acceptStream.stream;
  }
}
