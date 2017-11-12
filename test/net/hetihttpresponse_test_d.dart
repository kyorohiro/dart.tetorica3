//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/data.dart' as hetima;
import 'package:tetorica/parser.dart' as hetima;
import 'package:tetorica/net.dart' as hetima;
import 'dart:async';
import 'package:test/test.dart' as unit;
import 'package:tetorica/http.dart' as hetima;

void main() {
  unit.test("001",() async{
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future<hetima.HetiHttpRequestRange> f = hetima.HetiHttpResponse.decodeRequestRangeValue(parser);
      builder.appendString("bytes=0-100");
      //builder.fin();
      builder.loadCompleted = true;
      unit.expect(0, (await f).start);
      unit.expect(100, (await f).end);
  });

  unit.test("002",() async {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future<hetima.HetiHttpRequestRange> f = hetima.HetiHttpResponse.decodeRequestRangeValue(parser);
      builder.appendString("bytes=0-");
      //builder.fin();
      builder.loadCompleted = true;

      unit.expect(0, (await f).start);
      unit.expect(-1, (await f).end);
  });
}
