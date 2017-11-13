import 'package:tetorica/data.dart' as tet;
import 'package:tetorica/parser.dart' as tet;
import 'package:tetorica/net.dart' as tet;
import 'package:tetorica/net_dartio.dart' as tet;
import 'package:tetorica/http.dart' as tet;

main() async {
  print("Hello World!!");
  tet.TetSocketBuilder socketBuilder = new tet.TetSocketBuilderDartIO();
  tet.HttpClientPlus client = new tet.HttpClientPlus(socketBuilder);
  tet.HttpClientResponse response = await client.get("www.google.co.jp", 80, "/");
//  tet.HttpClientResponse response = await client.get("www.google.com", 80, "/");

  print("# LEN : ${response.info.contentLength}");
  for(tet.HttpResponseHeaderField f in response.info.headerField ) {
    print("# HEA : " + f.fieldName + " " + f.fieldValue + "");
  }
  tet.ParserReader reader = response.body;
  String ret = await reader.getAllString();
  print("${ret}");

}