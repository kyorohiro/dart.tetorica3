part of hetimanet_dartio;

class TetUdpSocketDartIo extends TetUdpSocket {
  static Random _random = new Random(new DateTime.now().millisecond);
  bool _verbose = false;
  bool get verbose => _verbose;
  io.RawDatagramSocket _udpSocket = null;
  TetUdpSocketDartIo({verbose: false}) {
    _verbose = verbose;
  }

  bool _isBindingNow = false;
  StreamController<TetReceiveUdpInfo> _receiveStream = new StreamController.broadcast();

  @override
  Future<TetBindResult> bind(String address, int port, {bool multicast: false}) async {
    if (_isBindingNow != false) {
      throw "now binding";
    }
    _isBindingNow = true;
    try {
      io.RawDatagramSocket socket = await io.RawDatagramSocket.bind(address, port, reuseAddress: true);
      _udpSocket = socket;
      socket.multicastLoopback = multicast;
      socket.listen((io.RawSocketEvent event) {
        if (event == io.RawSocketEvent.READ) {
          io.Datagram dg = socket.receive();
          if (dg != null) {
            log("read ${dg.address}:${dg.port} ${dg.data.length}");
            _receiveStream.add(new TetReceiveUdpInfo(dg.data, dg.address.address, dg.port));
          }
        }
      });
    } finally {
      _isBindingNow = false;
    }
    return new TetBindResult();
  }

  @override
  Future close() async {
    _udpSocket.close();
    return 0;
  }

  @override
  Stream<TetReceiveUdpInfo> get onReceive => _receiveStream.stream;

  @override
  Future<TetUdpSendInfo> send(List<int> buffer, String address, int port) async {
    try {
      try {
        IPConv.toRawIP(address);
      } catch (e) {
        List<io.InternetAddress> hosts = await io.InternetAddress.lookup(address);
        if (hosts == null || hosts.length == 0) {
          throw {"error": "not found ip from host ${address}"};
        }
        int n = 0;
        if (hosts.length > 1) {
          n = _random.nextInt(hosts.length - 1);
        }
        address = hosts[n].address;
      }
      _udpSocket.send(buffer, new io.InternetAddress(address), port);
      return await new TetUdpSendInfo(0);
    } catch (e) {
      throw e;
    }
  }

  log(String message) {
    if (_verbose) {
      print("d..${message}");
    }
  }
}
