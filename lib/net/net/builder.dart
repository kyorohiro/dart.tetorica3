part of hetimanet;


enum TetSocketMode {
  bufferAndNotify,
  bufferOnly,
  notifyOnly
}

abstract class TetSocketBuilder {
  Socket createClient({TetSocketMode mode:TetSocketMode.bufferAndNotify, heti.ParserBuffer buffer:null});
  Socket createSecureClient({TetSocketMode mode:TetSocketMode.bufferAndNotify, heti.ParserBuffer buffer:null});
  TetUdpSocket createUdpClient();
  Future<ServerSocket> startServer(String address, int port, {TetSocketMode mode:TetSocketMode.bufferAndNotify}) ;
  Future<List<NetworkInterface>> getNetworkInterfaces();
}