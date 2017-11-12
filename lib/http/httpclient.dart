part of hetimanet_http;

class HttpClientResponse {
  HttpClientResponseInfo info;
  TetReader body;
}

//class HttpClientConnectResult {}

class HttpClient {
  TetSocketBuilder _socketBuilder;
  TetSocket socket = null;
  String host;
  int port;

  bool _verbose = false;

  HttpClient(TetSocketBuilder socketBuilder, {DataBuilder dataBuilder: null, bool verbose: false}) {
    _socketBuilder = socketBuilder;
    _verbose = verbose;
  }

//  Future<HttpClientConnectResult>
  Future connect(String _host, int _port ,{bool useSecure:false}) async {
    host = _host;
    port = _port;
    socket = (useSecure?_socketBuilder.createSecureClient():_socketBuilder.createClient());
    if (socket == null) {
      throw {};
    }
    log("<hetihttpclient f=connect> ${socket}");
    TetSocket s = await socket.connect(host, port);
    if (s == null) {
      throw {};
    }
    //return new HttpClientConnectResult();
  }

  Future<HttpClientResponse> get(String path, {Map<String, String> header}) async {
     return base("GET", path, null, header:header);
  }

  Future<HttpClientResponse> post(String path, List<int> body, {Map<String, String> header}) async {
    return base("POST", path, body, header:header);
  }

  Future<HttpClientResponse> put(String path, List<int> body, {Map<String, String> header}) async {
     return base("PUT", path, body, header:header);
  }

  Future<HttpClientResponse> patch(String path, List<int> body, {Map<String, String> header}) async {
     return base("PATCH", path, body, header:header);
  }

  Future<HttpClientResponse> delete(String path, {Map<String, String> header}) async {
     return base("DELETE", path, null, header:header);
  }

  Future<HttpClientResponse> head(String path, {Map<String, String> header}) async {
     return base("HEAD", path, null, header:header, isLoadBody:false);
  }

  Future<HttpClientResponse> mpost(String path, List<int> body, {Map<String, String> header}) async {
    return base("M-POST", path, body, header:header);
  }

  Future<HttpClientResponse> base(String action, String path, List<int> body, {Map<String, String> header, isLoadBody:true}) async {
    Map<String, String> headerTmp = {};
    headerTmp["Host"] = host + ":" + port.toString();
    headerTmp["Connection"] = "Close";
    if (header != null) {
      for (String key in header.keys) {
        headerTmp[key] = header[key];
      }
    }
    if(body != null) {
      headerTmp[RfcTable.HEADER_FIELD_CONTENT_LENGTH] = body.length.toString();
    }
    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString(action + " " + path + " " + "HTTP/1.1" + "\r\n");
    for (String key in headerTmp.keys) {
      builder.appendString("" + key + ": " + headerTmp[key] + "\r\n");
    }

    builder.appendString("\r\n");
    if(body != null) {
      builder.appendIntList(body, 0, body.length);
    }
    //
    socket.onReceive.listen((TetReceiveInfo info) {});
    socket.send(builder.toList()).then((TetSendInfo info) {});

    return handleResponse(isLoadBody:isLoadBody);
  }


  Future<HttpClientResponse> handleResponse({isLoadBody:true}) async {
    EasyParser parser = new EasyParser(socket.buffer);
    HttpClientResponseInfo message = await HetiHttpResponse.decodeHttpMessage(parser);
    HttpClientResponse result = new HttpClientResponse();
    result.info = message;
    if(isLoadBody == false) {
      result.body = new TetReaderWithIndex(socket.buffer, message.index);
      result.body.loadCompleted = true;
      return result;
    }

    HttpResponseHeaderField transferEncodingField = message.find("Transfer-Encoding");

    if (transferEncodingField == null || transferEncodingField.fieldValue != "chunked") {
      result.body = new TetReaderWithIndex(socket.buffer, message.index);
      if (result.info.contentLength > 0) {
        await result.body.getBytes(0, result.info.contentLength);
        result.body.loadCompleted = true;
      } else {
        result.body.loadCompleted = true;
      }
    } else {
      result.body = new ChunkedBuilderAdapter(new TetReaderWithIndex(socket.buffer, message.index)).start();
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
