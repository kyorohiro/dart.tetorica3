part of hetimanet_http;


class HttpServer {

  StreamController _controllerOnNewRequest = new StreamController.broadcast();
  String _bindIP;
  int _port;
  String get bindIP => _bindIP;
  int get port => _port;
  ServerSocket _serverSocket = null;
  HttpServer._internal(ServerSocket s) {
    _serverSocket = s;
  }

  void close() {
    if(_serverSocket == null) {
      return;
    }
    _serverSocket.close();
    _serverSocket = null;
    _controllerOnNewRequest.close();
    _controllerOnNewRequest = null;
  }

  static Future<HttpServer> bind(SocketBuilder builder, String bindIP, int port) async {
    ServerSocket serverSocket = await builder.startServer(bindIP, port);
    if (serverSocket == null) {
      throw "failed binding ${bindIP}:${port}";
    }
    HttpServer server = new HttpServer._internal(serverSocket);
    server._bindIP = bindIP;
    server._port = port;
    serverSocket.onAccept().listen((Socket socket) async {
      EasyParser parser = new EasyParser(socket.buffer);
      HetiHttpRequestMessageWithoutBody body = await HetiHttpResponse.decodeRequestMessage(parser);
      HttpServerRequest request = new HttpServerRequest();
      request.socket = socket;
      request.info = body;
      server._controllerOnNewRequest.add(request);
    });
    return server;
  }

  Stream<HttpServerRequest> onNewRequest() {
    return _controllerOnNewRequest.stream;
  }
}

class HttpServerRequest
{
  Socket socket;
  HetiHttpRequestMessageWithoutBody info;
}
