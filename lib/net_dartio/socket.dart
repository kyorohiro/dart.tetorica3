part of hetimanet_dartio;


class TetSocketDartIo extends SocketBase {
  static Random _random = new Random(new DateTime.now().millisecond);
  bool _verbose = false;
  bool get verbose => _verbose;
  io.Socket _socket = null;
  TetSocketMode _mode = TetSocketMode.bufferAndNotify;
  bool _isSecure = false;
  bool get isSecure => _isSecure;

  TetSocketDartIo({verbose: false, TetSocketMode mode:TetSocketMode.bufferAndNotify, bool isSecureSocket: false}) {
    _verbose = verbose;
    _mode = mode;
    _isSecure = isSecureSocket;
  }

  TetSocketDartIo.fromSocket(io.Socket socket, {verbose: true, TetSocketMode mode:TetSocketMode.bufferAndNotify}) {
    _verbose = verbose;
    _socket = socket;
    _mode = mode;
    _listen();
  }

  bool _nowConnecting = false;

  @override
  Future<Socket> connect(String peerAddress, int peerPort, {SocketOnBadCertificate onBadCertificate:null})async {
    if (_nowConnecting == true || _socket != null) {
      throw "connecting now";
    }
    String host = peerAddress;
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
        _socket = await io.SecureSocket.connect(host, peerPort, onBadCertificate: (io.X509Certificate c) {
          log("<<bad certificate>>");
          if(onBadCertificate != null) {
            return onBadCertificate(new X509Certificate(c.subject, c.issuer, c.startValidity.millisecondsSinceEpoch, c.endValidity.millisecondsSinceEpoch));
          }
          return false;
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
    _socket.listen((List<int> data)  {
      log('<<<lis>>> ');
      if(_mode != TetSocketMode.notifyOnly) {
        this.buffer.addBytes(data, index:0, length:data.length);
      }
      if (_mode != TetSocketMode.bufferOnly) {
        receiveStreamController.add(data);
      }
    }, onDone: () {
      log('<<<done>>>');
      _socket.close();
    }, onError: (e) {
      log('<<<error>>> $e');
      _socket.close();
    });
  }
  @override
  Future<SocketInfo> getSocketInfo() async {
    SocketInfo info = new SocketInfo();
    info.localAddress = _socket.address.address;
    info.localPort = _socket.port;
    info.peerAddress = _socket.remoteAddress.address;
    info.peerPort = _socket.remotePort;
    return info;
  }

  Future<Socket> close() {
    if (isClosed == false) {
      _socket.close();
    }
    return super.close();
  }


  @override
  void send(List<int> data) {
    _socket.add(data);
  }

  log(String message) {
    if (_verbose)
    {
      print("d..${message}");
    }
  }
}
