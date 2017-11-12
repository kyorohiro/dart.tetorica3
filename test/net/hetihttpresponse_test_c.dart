//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/net.dart' as hetima;
import 'dart:async';
import 'package:test/test.dart' as unit;
import 'package:tetorica/http.dart' as hetima;

void main() {
  unit.test("request-line", () async {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future<hetima.HetiRequestLine> ret = hetima.HetiHttpResponse.decodeRequestLine(parser);
      builder.appendString("GET /xxx/yy/zz HTTP/1.1\r\n");
      unit.expect("GET",(await ret).method);
      unit.expect("HTTP/1.1",(await ret).httpVersion);
      unit.expect("/xxx/yy/zz",(await ret).requestTarget);
  });

  unit.test("request message",() async{
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future<hetima.HetiHttpRequestMessageWithoutBody> ret = hetima.HetiHttpResponse.decodeRequestMessage(parser);
      builder.appendString("GET /xxx/yy/zz HTTP/1.1\r\n");
      builder.appendString("aaa: bb\r\n");
      builder.appendString("ccc: ddd\r\n");
      builder.appendString("\r\n");
      //builder.fin();
      builder.loadCompleted = true;
      unit.expect("GET", (await ret).line.method);
      unit.expect("HTTP/1.1", (await ret).line.httpVersion);
      unit.expect("/xxx/yy/zz", (await ret).line.requestTarget);
      unit.expect("bb", (await ret).find("aaa").fieldValue);
      unit.expect("ddd", (await ret).find("ccc").fieldValue);
  });
}
