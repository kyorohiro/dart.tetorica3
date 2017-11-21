import 'dart:async';
import 'package:tetorica/net.dart' as tet;
import 'package:tetorica/http.dart' as tet;
import 'package:tetorica/data.dart' as tet;
import 'package:tetorica/dartio_net.dart' as tetio;
import 'package:args/args.dart' as arg;
import 'httpserver_plus.dart' as app;
import 'dart:convert' as conv;

main(List<String> args) async {
  print("http server");
  //
  // args
  //
  arg.ArgParser parser = new arg.ArgParser();
  parser.addOption("port", abbr: "p", defaultsTo: "80");
  parser.addOption("bind", abbr: "b", defaultsTo: "0.0.0.0");

  arg.ArgResults parserResult = parser.parse(args);
  int port = int.parse(parserResult["port"]);
  String host = parserResult["bind"];

  tet.TetSocketBuilder builder = new tetio.TetSocketBuilderDartIO();
  app.HetiHttpServerPlus sv = new app.HetiHttpServerPlus(builder);
  await sv.startServer();
  sv.onResponse.listen((app.HetiHttpServerPlusResponseItem res) {
    sv.response(res.req, new tet.MemoryData(buffer: conv.UTF8.encode("Hello, World!!")),contentType:"text/html");
  });
}