import 'package:tetorica/data.dart' as tet;
import 'package:tetorica/parser.dart' as tet;
import 'package:tetorica/net.dart' as tet;
import 'package:tetorica/net_dartio.dart' as tet;
import 'package:tetorica/http.dart' as tet;

import 'package:args/args.dart' as arg;
import 'dart:convert' as conv;

main(List<String> args) async {
  //
  // args
  arg.ArgParser parser = new arg.ArgParser();
  parser.addFlag("retry", abbr: "r");
  parser.addFlag("continue", abbr: "c");
  parser.addOption("header", abbr: "h", allowMultiple: true);
  parser.addOption("data", abbr: "d");
  parser.addOption("output", abbr: "o");
  parser.addOption("action", abbr: "a", defaultsTo: "GET");
  // parse
  arg.ArgResults parserResult = parser.parse(args);
  print("# d #${parserResult["header"]}");
  print("# c #${parserResult["continue"]}");
  print("# r #${parserResult["retry"]}");
  print("# a #${parserResult["action"]}");
  print("# o #${parserResult["output"]}");
  print("# d #${parserResult["data"]}");
  print("# r #${parserResult.rest}");

  String addr = parserResult.rest[0];
  String action = parserResult["action"];
  tet.HttpUrl httpUrl = await tet.HttpUrl.decodeUrl(addr);
  String host = httpUrl.host;
  bool useSecure = (httpUrl.scheme == "http"?false:true);
  int port = httpUrl.port;
  String pathWithQuery = httpUrl.pathWithQuery;
  List<int> data = [];
  if(parserResult["data"] != null) {
    data = conv.UTF8.encode(parserResult["data"]);
  }

  print("Hello World!!");
  tet.TetSocketBuilder socketBuilder = new tet.TetSocketBuilderDartIO();
  tet.HttpClientPlus client = new tet.HttpClientPlus(socketBuilder,verbose: true);
  tet.HttpClientResponse response = await client.doAction(
      host, port, action, pathWithQuery, data,
      useSecure: useSecure, onBadCertificate: (tet.X509Certificate i){return true;});

  print("# LEN : ${response.info.contentLength}");
  for(tet.HttpResponseHeaderField f in response.info.headerField ) {
    print("# HEA : " + f.fieldName + " " + f.fieldValue + "");
  }
  tet.ParserReader reader = response.body;
  String ret = await reader.getAllString();
  print("${ret}");

}