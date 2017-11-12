//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/data.dart' as hetima;
import 'package:tetorica/parser.dart' as hetima;
import 'package:tetorica/core.dart' as hetima;
import 'package:tetorica/net.dart' as hetima;
import 'package:tetorica/http.dart' as hetima;
import 'package:test/test.dart' as unit;

import 'dart:async';

void main() {
  unit.group("response_b", () {
    unit.test("http/1.1", () async {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future<String> ret = hetima.HetiHttpResponse.decodeHttpVersion(parser);
      builder.appendString("HTTP/1.1");
      unit.expect("HTTP/1.1", await ret);
    });
  });

  unit.test("response phase", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<String> ret = hetima.HetiHttpResponse.decodeReasonPhrase(parser);
    builder.appendString("aaa bbb");
    builder.appendString(" ccc");
    builder.appendString("\r\n");
    unit.expect("aaa bbb ccc", await ret);
  });

  unit.test("reasonphase_2", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<String> ret = hetima.HetiHttpResponse.decodeReasonPhrase(parser);
    builder.appendString("aaa bbb");
    builder.appendString(" ccc");
    //builder.fin();
    builder.loadCompleted = true;
    unit.expect("aaa bbb ccc", await ret);
  });

  unit.test("decodeCrlf_1", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<String> ret = hetima.HetiHttpResponse.decodeCrlf(parser);
    builder.appendString("\n");
    //builder.fin();
    builder.loadCompleted = true;
    unit.expect("\n", await ret);
  });

  unit.test("decodeCrlf_2", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<String> ret = hetima.HetiHttpResponse.decodeCrlf(parser);
    builder.appendString(" ");
    //builder.fin();
    builder.loadCompleted = true;
    try {
      unit.fail("${await ret}");
    } catch (e) {
      // expected
    }
  });

  unit.test("statusline", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<hetima.HetiHttpResponseStatusLine> ret = hetima.HetiHttpResponse.decodeStatusline(parser);
    builder.appendString("HTTP/1.1 200 tes test test\r\n");
    //builder.fin();
    builder.loadCompleted = true;
    unit.expect((await ret).statusCode, 200);
    unit.expect((await ret).version, "HTTP/1.1");
    unit.expect((await ret).statusPhrase, "tes test test");
  });

  unit.test("decodeHeaderField_1f", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<hetima.HttpResponseHeaderField> ret = hetima.HetiHttpResponse.decodeHeaderField(parser);
    builder.appendString("test:   aaa\r\n");
    //builder.fin();
    builder.loadCompleted = true;
    unit.expect((await ret).fieldName, "test");
    unit.expect((await ret).fieldValue, "aaa");
  });

  unit.test("decodeHeaderField_2f", () async {
    try {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future<hetima.HttpResponseHeaderField> ret = hetima.HetiHttpResponse.decodeHeaderField(parser);
      builder.appendString("test   aaa\r\n");
      //builder.fin();
      builder.loadCompleted = true;
      unit.fail("${await ret}");
    } catch (e) {
      // expected
    }
  });

  unit.test("decodeHeaderFields_1f", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<List<hetima.HttpResponseHeaderField>> ret = hetima.HetiHttpResponse.decodeHeaderFields(parser);
    builder.appendString("test1:   aaa\r\n");
    builder.appendString("test2:   bbb\r\n\r\n");
    //builder.fin();
    builder.loadCompleted = true;
    unit.expect((await ret)[0].fieldName, "test1");
    unit.expect((await ret)[0].fieldValue, "aaa");
    unit.expect((await ret)[1].fieldName, "test2");
    unit.expect((await ret)[1].fieldValue, "bbb");
  });

  unit.test("decodeHttpMessage_1f", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<hetima.HttpClientResponseInfo> ret = hetima.HetiHttpResponse.decodeHttpMessage(parser);
    builder.appendString("HTTP/1.1 200 tes test test\r\n");
    builder.appendString("test1:   aaa\r\n");
    builder.appendString("test2:   bbb\r\n\r\n");
    //builder.fin();
    builder.loadCompleted = true;
    unit.expect((await ret).headerField[0].fieldName, "test1");
    unit.expect((await ret).headerField[0].fieldValue, "aaa");
    unit.expect((await ret).headerField[1].fieldName, "test2");
    unit.expect((await ret).headerField[1].fieldValue, "bbb");
  });
  unit.test("decodeHttpMessage_2f", () async {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future<hetima.HttpClientResponseInfo> ret = hetima.HetiHttpResponse.decodeHttpMessage(parser);
    builder.appendString("HTTP/1.1 200 tes test test\r\n");
    builder.appendString("test1:   aaa\r\n");
    builder.appendString("test2   bbb\r\n\r\n");
    //builder.fin();
    builder.loadCompleted = true;
    try {
      await ret;
      unit.fail("");
    } catch (e) {}
  });
}
