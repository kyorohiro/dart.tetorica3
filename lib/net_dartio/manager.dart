part of hetimanet_dartio;

class TetSocketBuilderDartIO extends TetSocketBuilder {
  bool _verbose = false;
  bool get verbose => _verbose;

  TetSocketBuilderDartIO({verbose: false}) {
    _verbose = verbose;
  }

  TetSocket createClient({TetSocketMode mode:TetSocketMode.bufferAndNotify, isSecure: false}) {
    return new TetSocketDartIo(verbose: _verbose,mode:mode);
  }

  TetSocket createSecureClient({TetSocketMode mode:TetSocketMode.bufferAndNotify}) {
    return new TetSocketDartIo(verbose: _verbose,mode:mode, isSecure: true);
  }

  Future<TetServerSocket> startServer(String address, int port, {TetSocketMode mode:TetSocketMode.bufferAndNotify}) async {
    return TetServerSocketDartIo.startServer(address, port, verbose: _verbose, mode:mode);
  }

  TetUdpSocket createUdpClient() {
    return new TetUdpSocketDartIo(verbose: _verbose);
  }

  Future<List<TetNetworkInterface>> getNetworkInterfaces() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(includeLoopback: true, includeLinkLocal: true);
    List<TetNetworkInterface> ret = [];
    for (NetworkInterface i in interfaces) {
      for (InternetAddress a in i.addresses) {
        int prefixLength = 24;
        if (a.rawAddress.length > 4) {
          prefixLength = 64;
        }
        //a.isLoopback;
        //a.isMulticast;
        //a.isLinkLocal;
        ret.add(new TetNetworkInterface()
          ..address = a.address
          ..name = i.name
          ..prefixLength = prefixLength);
      }
    }
    return ret;
  }
}
