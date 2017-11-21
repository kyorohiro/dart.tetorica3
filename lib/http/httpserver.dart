part of hetimanet_http;


class HttpServer {

  StreamController _controllerOnNewRequest = new StreamController.broadcast();
//  HetimaSocketBuilder _builder;
  String host;
  int port;
  ServerSocket _serverSocket = null;
  HttpServer._internal(ServerSocket s) {
    _serverSocket = s;
  }

  void close() {
    if(_serverSocket != null) {
      _serverSocket.close();
      _serverSocket = null;
      _controllerOnNewRequest.close();
      _controllerOnNewRequest = null;
    }
  }

  static Future<HttpServer> bind(SocketBuilder builder, String address, int port) {
    Completer<HttpServer> completer = new Completer();
    builder.startServer(address, port).then((ServerSocket serverSocket){
      if(serverSocket == null) {
        completer.completeError({});
        return;
      }
      HttpServer server = new HttpServer._internal(serverSocket);
      completer.complete(server);
      serverSocket.onAccept().listen((Socket socket){
        EasyParser parser = new EasyParser(socket.buffer);
        HetiHttpResponse.decodeRequestMessage(parser).then((HetiHttpRequestMessageWithoutBody body){
          HetiHttpServerRequest request = new HetiHttpServerRequest();
          request.socket = socket;
          request.info = body;
          server._controllerOnNewRequest.add(request);
          parser.buffer.getBytes(0, body.index).then((List v) {
            //print(convert.UTF8.decode(v));
          }).catchError((e){
            ;
          });
        });
      });
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }

  Stream<HetiHttpServerRequest> onNewRequest() {
    return _controllerOnNewRequest.stream;
  }
}

class HetiHttpServerRequest
{
  Socket socket;
  HetiHttpRequestMessageWithoutBody info;
}
