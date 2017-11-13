part of hetimanet_dartio;

class TetSocketDartIo extends TetSocket {
  static Random _random = new Random(new DateTime.now().millisecond);
  bool _verbose = false;
  bool get verbose => _verbose;
  io.Socket _socket = null;
  TetSocketMode _mode = TetSocketMode.bufferAndNotify;
  bool _isSecure = false;
  bool get isSecure => _isSecure;

  TetSocketDartIo({verbose: false, TetSocketMode mode:TetSocketMode.bufferAndNotify, bool isSecure: false}) {
    _verbose = verbose;
    _mode = mode;
    _isSecure = isSecure;
  }

  TetSocketDartIo.fromSocket(io.Socket socket, {verbose: true, TetSocketMode mode:TetSocketMode.bufferAndNotify}) {
    _verbose = verbose;
    _socket = socket;
    _mode = mode;
    _listen();
  }

  bool _nowConnecting = false;
  StreamController<TetCloseInfo> _closeStream = new StreamController.broadcast();
  StreamController<TetReceiveInfo> _receiveStream = new StreamController.broadcast();

  @override
  Future<TetSocket> connect(String peerAddress, int peerPort) async {
    if (_nowConnecting == true || _socket != null) {
      throw "connecting now";
    }

    try {
      IPConv.toRawIP(peerAddress);
    } catch (e) {
      List<io.InternetAddress> hosts = await io.InternetAddress.lookup(peerAddress);
      if (hosts == null || hosts.length == 0) {
        throw {"error": "not found ip from host ${peerAddress}"};
      }
      int n = 0;
      if (hosts.length > 1) {
        n = _random.nextInt(hosts.length - 1);
      }
      peerAddress = hosts[n].address;
    }
    try {
      _nowConnecting = true;
      if (isSecure == true) {
        _socket = await io.SecureSocket.connect(peerAddress, peerPort, onBadCertificate: (io.X509Certificate c) {
          print("Certificate WARNING: ${c.issuer}:${c.subject}");
          return true;
        });
      } else {
        _socket = await io.Socket.connect(peerAddress, peerPort);
      }

      _listen();
      return this;
    } finally {
      _nowConnecting = false;
    }
  }

  void _listen(){
    _socket.listen((List<int> data) {
      log('<<<lis>>> ');
      if(_mode != TetSocketMode.notifyOnly) {
        this.buffer.appendIntList(data, 0, data.length);
      }
      if (_mode != TetSocketMode.bufferOnly) {
        _receiveStream.add(new TetReceiveInfo(data));
      }
    }, onDone: () {
      log('<<<Done>>>');
      _socket.close();
      _closeStream.add(new TetCloseInfo());
    }, onError: (e) {
      log('<<<Got error>>> $e');
      _socket.close();
      _closeStream.add(new TetCloseInfo());
    });
  }
  @override
  Future<TetSocketInfo> getSocketInfo() async {
    TetSocketInfo info = new TetSocketInfo();
    info.localAddress = _socket.address.address;
    info.localPort = _socket.port;
    info.peerAddress = _socket.remoteAddress.address;
    info.peerPort = _socket.remotePort;
    return info;
  }

  void close() {
    if (isClosed == false) {
      _socket.close();
    }
    super.close();
  }

  @override
  Stream<TetCloseInfo> get onClose => _closeStream.stream;

  @override
  Stream<TetReceiveInfo> get onReceive => _receiveStream.stream;

  @override
  Future<TetSendInfo> send(List<int> data) async {
    await _socket.add(data);
    return new TetSendInfo(0);
  }

  log(String message) {
    if (_verbose) {
      print("d..${message}");
    }
  }
}
