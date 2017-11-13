part of hetimanet;
abstract class TetUdpSocket {
  ///
  /// The result code returned from the underlying network call. A
  /// negative value indicates an error.
  ///
  Future<TetBindResult> bind(String address, int port, {bool multicast:false});
  Future<TetUdpSendInfo> send(List<int> buffer, String address, int port);
  Stream<TetReceiveUdpInfo> onReceive;
  Future<dynamic> close();
}

//
// print("a:"+s["remoteAddress"]);
// print("p:"+s["remotePort"]
//
class TetReceiveUdpInfo {
  List<int> data;
  String remoteAddress;
  int remotePort;
  TetReceiveUdpInfo(List<int> adata, String aremoteAddress, int aport) {
    data = adata;
    remoteAddress = aremoteAddress;
    remotePort = aport;
  }
}

class TetUdpSendInfo {
  int resultCode = 0;
  TetUdpSendInfo(int _resultCode) {
    resultCode = _resultCode;
  }
}

class TetBindResult {

}
