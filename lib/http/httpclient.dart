part of hetimanet_http;

class HttpClientResponse {
  HttpClientResponseInfo info;
  ParserReader body;
}

//class HttpClientConnectResult {}

class HttpClient {
  TetSocketBuilder _socketBuilder;
  Socket socket = null;
  String host;
  int port;

  bool _verbose = false;

  HttpClient(TetSocketBuilder socketBuilder, {DataBuilder dataBuilder: null, bool verbose: false}) {
    _socketBuilder = socketBuilder;
    _verbose = verbose;
  }

  Future connect(String _host, int _port ,{bool useSecure:false, SocketOnBadCertificate onBadCertificate:null}) async {
    host = _host;
    port = _port;
    socket = (useSecure?_socketBuilder.createSecureClient():_socketBuilder.createClient());
    if (socket == null) {
      throw {};
    }
    log("<hetihttpclient f=connect> ${socket}");
    Socket s = await socket.connect(host, port, onBadCertificate:onBadCertificate);
    if (s == null) {
      throw {};
    }
    //return new HttpClientConnectResult();
  }

  Future<HttpClientResponse> base(String action, String path, List<int> body, {Map<String, String> header, isLoadBody:true}) async {
    Map<String, String> headerTmp = {};
    headerTmp["Host"] = host;// + ":" + port.toString();
    headerTmp["Connection"] = "Close";
    //headerTmp["User-Agent"] = "test/01";
    //headerTmp["Accept"] = "*/*";

    if (header != null) {
      for (String key in header.keys) {
        headerTmp[key] = header[key];
      }
    }
    if(body != null && body.length > 0) {
      headerTmp[RfcTable.HEADER_FIELD_CONTENT_LENGTH] = body.length.toString();
    }
    ParserBuffer builder = new ParserBuffer();
    builder.appendString(action + " " + path + " " + "HTTP/1.1" + "\r\n");
    for (String key in headerTmp.keys) {
      builder.appendString("" + key + ": " + headerTmp[key] + "\r\n");
    }

    builder.appendString("\r\n");
    if(body != null) {
      builder.addBytes(body, index:0, length:body.length);
    }
    //
    socket.onReceive.listen((List<int> data) {});
    builder.loadCompleted = true;
    //print(await builder.getAllString());
    socket.send(builder.toList());

    return handleResponse(isLoadBody:isLoadBody);
  }


  Future<HttpClientResponse> handleResponse({isLoadBody:true}) async {
    EasyParser parser = new EasyParser(socket.buffer);
    HttpClientResponseInfo message = await HetiHttpResponse.decodeHttpMessage(parser);
    HttpClientResponse result = new HttpClientResponse();
    result.info = message;
    if(isLoadBody == false) {
      result.body = new ParserReaderWithIndex(socket.buffer, message.index);
      result.body.loadCompleted = true;
      return result;
    }

    HttpResponseHeaderField transferEncodingField = message.find("Transfer-Encoding");

    if (transferEncodingField == null || transferEncodingField.fieldValue != "chunked") {
      result.body = new ParserReaderWithIndex(socket.buffer, message.index);
      if (result.info.contentLength > 0) {
        await result.body.getBytes(0, result.info.contentLength);
        result.body.loadCompleted = true;
      } else {
        result.body.loadCompleted = true;
      }
    } else {
      result.body = new ChunkParserReader(new ParserReaderWithIndex(socket.buffer, message.index)).start();
    }
    return result;
  }

  void close() {
    if (socket != null) {
      socket.close();
    }
  }

  void log(String message) {
    if (_verbose) {
      print("++${message}");
    }
  }
}
