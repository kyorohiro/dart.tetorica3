part of hetimanet;

typedef bool SocketOnBadCertificate(X509Certificate node);

class X509Certificate {
  String _subject;
  String _issuer;
  int _startValidity;//millisecondsSinceEpoch
  int _endValidity;//millisecondsSinceEpoch

  String get subject => _subject;
  String get issuer => _issuer;
  int get startValidity => _startValidity;
  int get endValidity => _endValidity;

  X509Certificate(String subject, String issuer, int startValidity, int endValidity) {
    this._subject = subject;
    this._issuer = issuer;
    this._startValidity = startValidity;
    this._endValidity = endValidity;
  }
}

abstract class TetServerSocket {
  Stream<TetSocket> onAccept();
  void close();
}

abstract class TetSocket {
 // int lastUpdateTime = 0;
  heti.ParserBuffer _buffer = new heti.ParserBuffer();
  heti.ParserBuffer get buffer => _buffer;
  Future<TetSocket> connect(String peerAddress, int peerPort, {SocketOnBadCertificate onBadCertificate:null}) ;
  Future<TetSendInfo> send(List<int> data);
  Future<TetSocketInfo> getSocketInfo();
  Stream<TetReceiveInfo> onReceive;
  Stream<TetCloseInfo> onClose;
  bool isClosed = false;
  void close() {
    _buffer.loadCompleted = true;
    isClosed = true;
  }
//
//  void updateTime() {
//    lastUpdateTime = (new DateTime.now()).millisecondsSinceEpoch;
//  }
//
  Future clearBuffer() async {
    _buffer.unusedBuffer(_buffer.currentSize,reuse:false);
    _buffer.clear();
  }
}


class TetSocketInfo {
  String peerAddress = "";
  int peerPort = 0;
  String localAddress = "";
  int localPort = 0;
}

class TetSendInfo {
  int resultCode = 0;
  TetSendInfo(int _resultCode) {
    resultCode = _resultCode;
  }
}

class TetReceiveInfo {
  List<int> data;
  TetReceiveInfo(List<int> _data) {
    data = _data;
  }
}

class TetCloseInfo {

}

