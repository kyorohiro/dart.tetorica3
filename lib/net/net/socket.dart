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

abstract class ServerSocket {
  Stream<Socket> onAccept();
  void close();
}

abstract class Socket {
 // int lastUpdateTime = 0;
  Future<Socket> connect(String peerAddress, int peerPort, {SocketOnBadCertificate onBadCertificate:null}) ;
  void send(List<int> data);
  Future<SocketInfo> getSocketInfo();
  bool isClosed = false;

  Future<Socket> close() async {
    _buffer.loadCompleted = true;
    isClosed = true;
    return this;
  }

  Future clearBuffer() async {
    _buffer.unusedBuffer(_buffer.currentSize,reuse:false);
    _buffer.clear();
  }
  heti.ParserBuffer _buffer = new heti.ParserBuffer();
  heti.ParserBuffer get buffer => _buffer;

  StreamController<Socket> _closeStreamController = new StreamController.broadcast();
  StreamController<TetReceiveInfo> _receiveStreamController = new StreamController.broadcast();
  StreamController<Socket> get closeStreamController => _closeStreamController;
  StreamController<TetReceiveInfo> get receiveStreamController => _receiveStreamController;
  Stream<TetReceiveInfo> get onReceive => receiveStreamController.stream;
  Stream<Socket> get onClose  => closeStreamController.stream;

}


class SocketInfo {
  String peerAddress = "";
  int peerPort = 0;
  String localAddress = "";
  int localPort = 0;
}


class TetReceiveInfo {
  List<int> data;
  TetReceiveInfo(List<int> _data) {
    data = _data;
  }
}

