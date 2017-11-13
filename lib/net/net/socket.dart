part of hetimanet;

abstract class TetServerSocket {
  Stream<TetSocket> onAccept();
  void close();
}

abstract class TetSocket {
 // int lastUpdateTime = 0;
  heti.ParserBuffer _buffer = new heti.ParserBuffer();
  heti.ParserBuffer get buffer => _buffer;
  Future<TetSocket> connect(String peerAddress, int peerPort) ;
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

