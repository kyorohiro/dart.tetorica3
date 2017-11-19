import 'package:tetorica/data.dart' as tet;
import 'package:tetorica/parser.dart' as tet;
import 'package:tetorica/net.dart' as tet;
import 'package:tetorica/http.dart' as tet;

import 'package:args/args.dart' as arg;
import 'dart:convert' as conv;
import 'httpclient.dart';

//
import 'package:tetorica/dartio_net.dart' as tetio;
import 'package:tetorica/dartio_data.dart' as tetio;


//import 'package:tetorica/dart'
main(List<String> args) async {
  //
  // args
  arg.ArgParser parser = new arg.ArgParser();
  parser.addFlag("retry", abbr: "r");
  parser.addFlag("continue", abbr: "c");
  parser.addOption("header", abbr: "h", allowMultiple: true);
  parser.addOption("data", abbr: "d");
  parser.addOption("output", abbr: "o", defaultsTo: "");
  parser.addOption("action", abbr: "a", defaultsTo: "GET");
  parser.addFlag("verbose", abbr: "v", defaultsTo: false);

  // parse
  arg.ArgResults parserResult = parser.parse(args);
  bool verbose = parserResult["verbose"];
  String output = parserResult["output"];
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


  tet.TetSocketBuilder socketBuilder = new tetio.TetSocketBuilderDartIO();
  HttpClient client = new HttpClient(socketBuilder,verbose: false, onBadCertificate: (tet.X509Certificate i){return true;});
  tet.HttpClientResponse response = await client.doAction(
      host, port, action, pathWithQuery, data,
      useSecure: useSecure);

  if(verbose) {
    for (tet.HttpResponseHeaderField f in response.info.headerField) {
      print("[v:header]" + f.fieldName + " " + f.fieldValue + "");
    }
  }
  tet.ParserReader reader = response.body;
  if(output == "") {
    String ret = await reader.getAllString();
    print("${ret}");
  } else {
    tetio.HetimaDataDartIOBuilder builder = new tetio.HetimaDataDartIOBuilder();
    tet.Data data = await builder.createData(output);
    int writeLength = 0;
    int index = 0;
    //
    //
    while(!(reader.loadCompleted && writeLength >= reader.currentSize)) {
      List<int> buffer = await reader.getAndUnusedBuffer();
      await data.write(buffer, writeLength);
      writeLength += buffer.length;
      print("writeed ${writeLength} ${buffer.length} ${reader.currentSize}");
    }
  }

  client.close();
  print("closed");
}