part of hetimanet_http;

class HttpClientResponse {
  HttpClientHead info;
  ParserReader body;
}


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

  Future<HttpClient> connect(String _host, int _port ,{bool useSecure:false, SocketOnBadCertificate onBadCertificate:null}) async {
    host = _host;
    port = _port;
    socket = (useSecure?_socketBuilder.createSecureClient(buffer:new ParserListBuffer()):_socketBuilder.createClient(buffer:new ParserListBuffer()));
    if (socket == null) {
      throw {};
    }
    log("<hetihttpclient f=connect> ${socket}");
    Socket s = await socket.connect(host, port, onBadCertificate:onBadCertificate);
    if (s == null) {
      throw {};
    }
    return this;
  }

  Future<HttpClientResponse> requestAndResponse(String action, String path, List<int> body, {Map<String, String> header, isLoadBody:true}) async {
    await request(action, path, body, header:header);
    HttpClientHead head = await getHead();
    HttpClientResponse result = new HttpClientResponse();
    if(isLoadBody) {
      result.info = head;
      result.body = await getBodyAsReader(head);
    } else {
      result.info = head;
      result.body = new ParserByteBuffer();
      result.body.loadCompleted = true;
    }
    return result;
  }

  Future<HttpClient> request(String action, String path, List<int> body, {Map<String, String> header}) async {
    Map<String, String> headerTmp = {};
    headerTmp["Host"] = host;// + ":" + port.toString();
    //headerTmp["Connection"] = "Close";
    //Host: www.google.com
    //headerTmp["User-Agent"] = "eurl/test";
    //headerTmp["Accept"] = "*/*";
    if (header != null) {
      for (String key in header.keys) {
        headerTmp[key] = header[key];
      }
    }
    if(body != null && body.length > 0) {
      headerTmp[RfcTable.HEADER_FIELD_CONTENT_LENGTH] = body.length.toString();
    }
    ParserByteBuffer builder = new ParserByteBuffer();
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
    return this;
  }

  Future<HttpClientHead> getHead() async {
    EasyParser parser = new EasyParser(socket.buffer);
    return HetiHttpResponse.decodeHttpMessage(parser);
  }

  Future<ParserReader> getBodyAsReader(HttpClientHead message, {isLoadBody:true}) async {
    HttpResponseHeaderField transferEncodingField = message.find("Transfer-Encoding");
    ParserReader reader = new ParserReaderWithIndex(socket.buffer, message.index);
//    ParserBuffer ret = new ParserByteBuffer();
    ParserBuffer ret = new ParserListBuffer();
    if (transferEncodingField == null || transferEncodingField.fieldValue != "chunked" ) {
      // content-length
      new Future(()async {
        int contentLength = message.contentLength;
        int length = 2*1024;
        int index = 0;
        while(contentLength > 0) {
          if(length > contentLength) {
            length = contentLength;
          }
          ret.addBytes(await reader.getBytes(index, length));
          contentLength-=length;
          index +=length;
        }
        ret.loadCompleted = true;
      });
      return ret;
    } else {
      // chunk
      EasyParser parser = new EasyParser(reader);
      new Future(()async {
        try {
          while (true) {
            int size = await HetiHttpResponse.decodeChunkedSize(parser);
            List<int> v = await parser.buffer.getBytes(parser.index, size);
            parser.index += v.length;
            reader.unusedBuffer(parser.index - 1);
            ret.addBytes(v, index: 0, length: v.length);
            if (v.length == 0) {
              break;
            }
            await HetiHttpResponse.decodeCrlf(parser);
          }
        } catch(e) {
        } finally {
          ret.loadCompleted = true;
        }
      });
      return ret;
    }
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
