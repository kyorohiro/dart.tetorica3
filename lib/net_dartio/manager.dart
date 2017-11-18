part of hetimanet_dartio;

class TetSocketBuilderDartIO extends TetSocketBuilder {
  bool _verbose = false;
  bool get verbose => _verbose;

  TetSocketBuilderDartIO({verbose: false}) {
    _verbose = verbose;
  }

  Socket createClient({TetSocketMode mode:TetSocketMode.bufferAndNotify, ParserBuffer buffer:null}) {
    return new TetSocketDartIo(verbose: _verbose,mode:mode, buffer:buffer);
  }

  Socket createSecureClient({TetSocketMode mode:TetSocketMode.bufferAndNotify, ParserBuffer buffer:null}) {
    return new TetSocketDartIo(verbose: _verbose,mode:mode, isSecureSocket: true, buffer:buffer);
  }

  Future<ServerSocket> startServer(String address, int port, {TetSocketMode mode:TetSocketMode.bufferAndNotify}) async {
    return TetServerSocketDartIo.startServer(address, port, verbose: _verbose, mode:mode);
  }

  TetUdpSocket createUdpClient() {
    return new TetUdpSocketDartIo(verbose: _verbose);
  }

  Future<List<NetworkInterface>> getNetworkInterfaces() async {
    List<io.NetworkInterface> interfaces = await io.NetworkInterface.list(includeLoopback: true, includeLinkLocal: true);
    List<NetworkInterface> ret = [];
    for (io.NetworkInterface i in interfaces) {
      for (io.InternetAddress a in i.addresses) {
        int prefixLength = 24;
        if (a.rawAddress.length > 4) {
          prefixLength = 64;
        }
        //a.isLoopback;
        //a.isMulticast;
        //a.isLinkLocal;
        ret.add(new NetworkInterface()
          ..address = a.address
          ..name = i.name
          ..prefixLength = prefixLength);
      }
    }
    return ret;
  }
}
