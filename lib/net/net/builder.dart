part of hetimanet;


enum TetSocketMode {
  bufferAndNotify,
  bufferOnly,
  notifyOnly
}

abstract class TetSocketBuilder {
  TetSocket createClient({TetSocketMode mode:TetSocketMode.bufferAndNotify});
  TetSocket createSecureClient({TetSocketMode mode:TetSocketMode.bufferAndNotify});
  TetUdpSocket createUdpClient();
  Future<TetServerSocket> startServer(String address, int port, {TetSocketMode mode:TetSocketMode.bufferAndNotify}) ;
  Future<List<NetworkInterface>> getNetworkInterfaces();
}