/*
import 'dart:convert' as convert;
import 'package:tetorica/data.dart';
import 'package:tetorica/parser.dart';
import 'dart:typed_data' as data;
import 'package:tetorica/net/tmp/rfctable.dart';
*/

import 'dart:async';
import 'package:tetorica/net.dart' as tet;
import 'package:tetorica/http.dart' as tet;

class HttpClient {
  tet.TetSocketBuilder _socketBuilder;

  List<int> _redirectStatusCode;
  tet.SocketOnBadCertificate _onBadCertificate;
  bool _reuseQuery;
  bool _verbose = false;

  HttpClient(this._socketBuilder,{
    bool verbose: false,
    List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
    tet.SocketOnBadCertificate onBadCertificate:null,
    bool reuseQuery: true,
  }){
    _reuseQuery = reuseQuery;
    _onBadCertificate = onBadCertificate;
    _redirectStatusCode = new List<int>.from(redirectStatusCode);
    _verbose = verbose;
  }

  Future<tet.HttpClientResponse> doAction(String address, int port, String action, String pathAndOption,
     List<int> data, {
        Map<String, String> header,

        bool useSecure:false,
        bool isLoadBody:true,
        int redirect: 5,
        }) async {
    _log("address:${address}, port:${port}, actopn:${action}, path:${pathAndOption}");

    tet.HttpClient client = new tet.HttpClient(_socketBuilder,verbose: _verbose);

    await client.connect(address, port, useSecure:useSecure, onBadCertificate: _onBadCertificate);

    tet.HttpClientResponse res = await client.base(action,pathAndOption, data, header:header, isLoadBody:isLoadBody);

    client.close();
    
    //
    if (_redirectStatusCode.contains(res.info.line.statusCode) && redirect > 0) {
      //
      //
      for(tet.HttpResponseHeaderField head in res.info.headerField) {
        print("HEAD = ${head.fieldName} : ${head.fieldValue}");
      }
      //
      //
      tet.HttpResponseHeaderField locationField = res.info.find("Location");
      String scheme;
      if(useSecure) {
        scheme = "https";
      } else {
        scheme = "http";
      }
      tet.HttpUrl hurl = tet.HttpUrlDecoder.decodeUrl(locationField.fieldValue, "${scheme}://${address}:${port}");
      int optionIndex = pathAndOption.indexOf("?");
      String option = "";
      if(optionIndex > 0) {
        option = pathAndOption.substring(optionIndex);
      }
      pathAndOption = "${hurl.path}${option}";
      _log("status code:${res.info.line.statusCode}");
      _log("Location:${locationField.fieldValue}");
      _log("scheme:${hurl.scheme}, address:${hurl.host}, port:${hurl.port}, actopn:${action}, path:${pathAndOption}");
      useSecure = (hurl.scheme == "https"?true:false);
      return doAction(hurl.host, hurl.port, action, pathAndOption, data,
          header: header,
          redirect: (redirect - 1),
          useSecure:useSecure);
    } else {
      return res;
    }
  }

  void _log(String message) {
    if (_verbose) {
      print("++${message}");
    }
  }
}
