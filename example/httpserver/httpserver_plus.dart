import 'dart:convert' as convert;
import 'dart:async';
import 'package:tetorica/data.dart' as tet;
import 'package:tetorica/parser.dart' as tet;
import 'package:tetorica/net.dart' as tet;
import 'dart:typed_data' as data;
import 'package:tetorica/net/tmp/rfctable.dart' as tet;
import 'package:tetorica/http.dart' as tet;

class HetiHttpServerPlus {
  String _bindIP = "0.0.0.0";
  String get bindIP => _bindIP;
  int _basePort = 18085;
  int get basePort => _basePort;
  int _localPort = 18085;
  int get localPort => _localPort;
  int _numOfRetry = 5;
  int get numOfRetry => _numOfRetry;

  tet.HttpServer _server = null;
  tet.SocketBuilder _socketBuilder = null;

  StreamController<String> _controllerUpdateLocalServer = new StreamController.broadcast();
  Stream<String> get onUpdateLocalServer => _controllerUpdateLocalServer.stream;
  StreamController<HetiHttpServerPlusResponseItem> _onResponse = new StreamController();
  Stream<HetiHttpServerPlusResponseItem> get onResponse => _onResponse.stream;

  HetiHttpServerPlus(tet.SocketBuilder socketBuilder, {int basePort:18085, String bindIP:"0.0.0.0", int numOfRetry:1}) {
    this._numOfRetry = numOfRetry;
    this._basePort = basePort;
    this._bindIP = bindIP;
    this._socketBuilder = socketBuilder;
  }

  void stopServer() {
    if (_server == null) {
      return;
    }
    _server.close();
    _server = null;
  }

  Future<HetiHttpServerPlus> startServer({int basePort:null, String bindIP:null, int numOfRetry:null}) async {
    this._basePort  = (basePort == null? this._basePort :basePort);
    this._bindIP = (bindIP == null?this._bindIP:bindIP);
    this._numOfRetry = (numOfRetry == null?this._numOfRetry:numOfRetry);
    _localPort =  this._basePort;
    if (_server != null) {
      throw("server null");//completer.completeError({});
    }

    tet.HttpServer server = await _retryBind();
    _controllerUpdateLocalServer.add("${_localPort}");
    _server = server;
    server.onNewRequest().listen(_hundleRequest);
    return this;
  }

  void _hundleRequest(tet.HttpServerRequest req) {
   // print("${req.info.line.requestTarget}");
    if (req.info.line.requestTarget.length < 0) {
      req.socket.close();
      return;
    }
    _onResponse.add(new HetiHttpServerPlusResponseItem(req));
  }


  void response(tet.HttpServerRequest req, tet.Data file, {String contentType:"application/octet-stream", Map<String,String> headerList:null, int statusCode:null}) {
    if(headerList == null) {headerList = {};}
    headerList["Content-Type"] = contentType;
    tet.HttpResponseHeaderField fieldRangeHeader = req.info.find(tet.RfcTable.HEADER_FIELD_RANGE);
    if (fieldRangeHeader != null && statusCode == null) {
      data.Uint8List buff = new data.Uint8List.fromList(convert.UTF8.encode(fieldRangeHeader.fieldValue));
      tet.ParserByteBuffer builder = new tet.ParserByteBuffer.fromList(buff);
      builder.loadCompleted = true;
      tet.HetiHttpResponse.decodeRequestRangeValue(new tet.EasyParser(builder)).then((tet.HetiHttpRequestRange range) {
        _startResponseRangeFile(req.socket, file, headerList, range.start, range.end);
      });
    } else {
      _startResponseFile(req.socket, statusCode, headerList, file);
    }
  }


  Future<HetiHttpServerPlus> _startResponseRangeFile(tet.Socket socket, tet.Data file, Map<String,String> header, int start, int end) async {
    tet.ParserByteBuffer response = new tet.ParserByteBuffer();
    int length = await file.getLength();
    if (end == -1 || end > length - 1) {
      end = length - 1;
    }
    int contentLength = end - start + 1;
    response.appendString("HTTP/1.1 206 Partial Content\r\n");
    response.appendString("Connection: close\r\n");
    response.appendString("Content-Length: ${contentLength}\r\n");
    response.appendString("Content-Range: bytes ${start}-${end}/${length}\r\n");
    for(String key in header.keys) {
      response.appendString("${key}: ${header[key]}\r\n");
    }
    response.appendString("\r\n");
    //print(response.toText());
    socket.send(response.toList());
    await _startResponseBuffer(socket, file, start, contentLength);
  }

  Future<HetiHttpServerPlus> _startResponseFile(tet.Socket socket, int statuCode, Map<String,String> header, tet.Data file) async {
    tet.ParserByteBuffer response = new tet.ParserByteBuffer();
    if(statuCode == null) {
      statuCode = 200;
    }
    int length = await file.getLength();
    response.appendString("HTTP/1.1 ${statuCode} OK\r\n");
    response.appendString("Connection: close\r\n");
    response.appendString("Content-Length: ${length}\r\n");
    for(String key in header.keys) {
      response.appendString("${key}: ${header[key]}\r\n");
    }
    response.appendString("\r\n");
    socket.send(response.toList());
    await _startResponseBuffer(socket, file, 0, length);
    socket.close();

    return this;
  }

  Future<HetiHttpServerPlus> _startResponseBuffer(tet.Socket socket, tet.Data file, int index, int length) async {
    int start = index;
    try {
      do {
        int end = start + 256 * 1024;
        if (end > (index + length)) {
          end = (index + length);
        }
        //
        //
        List<int> buffer = await file.getBytes(start, end - start);
        socket.send(buffer);
        if (end >= (index + length)) {
          socket.close();
          break;
        } else {
          start = end;
          continue;
        }
      } while (true);
    } catch (e) {
      try {
        socket.close();
      } catch (e) {}
    }
    return this;
  }


  Future<tet.HttpServer> _retryBind() async {
    int portMax = _localPort + _numOfRetry;
    do {
      try {
        tet.HttpServer server = await tet.HttpServer.bind(_socketBuilder, bindIP, _localPort);
        return server;
      } catch(e) {
        _localPort++;
        if (_localPort < portMax) {
          continue;
        } else {
          throw e;
        }
      }
    } while(true);
  }

}

class HetiHttpServerPlusResponseItem {
  tet.HttpServerRequest req;

  HetiHttpServerPlusResponseItem(tet.HttpServerRequest req) {
    this.req = req;
  }

  tet.Socket get socket => req.socket;
  String get targetLine => req.info.line.requestTarget;
  String get path {
    int index = targetLine.indexOf("?");
    if (index == -1) {
      index = targetLine.length;
    }
    return targetLine.substring(0, index);
  }

  String get option {
    int index = targetLine.indexOf("?");
    if (index == -1) {
      index = targetLine.length;
    }
    return targetLine.substring(index);
  }
}
