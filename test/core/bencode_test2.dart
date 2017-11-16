import 'package:test/test.dart' as unit;
import 'package:tetorica/data.dart' as hetima;
import 'package:tetorica/parser.dart' as hetima;
import 'package:tetorica/util.dart' as hetima;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:async';

void main() {

  unit.group("hetimabencode", (){
    unit.test("number", (){
      type.Uint8List out = hetima.Bencode.encode(1024);
      unit.expect("i1024e", convert.UTF8.decode(out.toList()));
      hetima.ParserBuffer builder = new hetima.ParserBuffer();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future e = hetima.BencodeAsync.decode(parser).then((Object o) {
        int v = o;
        unit.expect(v,1024);
      });
      builder.addBytes(out, index:0, length:out.length);
      return e;
    });

    unit.test("number e1", (){
      hetima.ParserBuffer builder = new hetima.ParserBuffer();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      Future e = hetima.BencodeAsync.decode(parser)
      .then((Object o) {
        unit.expect(true, false);
      }).catchError((e){
        unit.expect(true, true);
      });
      builder.appendString("i00");
      //builder.fin();
      builder.loadCompleted = true;
      return e;
    });
  });
  unit.test("number e2", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    Future e = hetima.BencodeAsync.decode(parser)
    .then((Object o) {
      unit.expect(true, false);
    }).catchError((e){
      unit.expect(true, true);
    });
    builder.appendString("i00x");
    return e;
  });

  unit.test("number e3", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BencodeAsync.decode(parser)
    .then((Object o) {
      unit.expect(true, false);
    }).catchError((e){
      unit.expect(true, true);
    });
    builder.appendString("000");
    //builder.fin();
    builder.loadCompleted = true;
  });

  unit.test("string", (){
    type.Uint8List out = hetima.Bencode.encode("hetimatan");
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);

    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeString(parser).then((Object o) {
      String v = o;
      unit.expect(v, "hetimatan");
    });
    builder.addBytes(out, index:0, length:out.length);
    return e;
  });

  unit.test("string e1", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);

    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeString(parser).then((Object o) {
      unit.expect(true, false);
    }).catchError((e){
      unit.expect(true, true);
    });
    builder.appendString("3:ab");
    //builder.fin();
    builder.loadCompleted = true;
    return e;
  });

  unit.test("string e2", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);

    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeString(parser).then((Object o) {
      unit.expect(true, false);
    }).catchError((e){
      unit.expect(true, true);
    });
    builder.appendString("3abc");
    //builder.fin();
    builder.loadCompleted = true;;
    return e;
  });

  unit.test("string e3", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);

    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeString(parser).then((Object o) {
      unit.expect(true, false);
    }).catchError((e){
      unit.expect(true, true);
    });
    builder.appendString(":abc");
    //builder.fin();
    builder.loadCompleted = true;
    return e;
  });
  unit.test("list", (){
    List l = new List();
    l.add("test");
    l.add(1024);
    type.Uint8List out = hetima.Bencode.encode(l);
    unit.expect("l4:testi1024ee", convert.UTF8.decode(out.toList()));

    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeList(parser).then((List<Object> o) {
      unit.expect(convert.UTF8.decode(o[0]), "test");
      unit.expect(o[1],  1024);
    }).catchError((e) {

    });
    builder.addBytes(out, index:0, length:out.length);
    return e;
  });
  unit.test("list e1", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    decoder.decodeList(parser).then((List<Object> o) {
      unit.expect(true, false);
    }).catchError((e) {
      unit.expect(true, true);
    });
    builder.appendString("l4:testi1024e");
    //builder.fin();
    builder.loadCompleted = true;
  });

  unit.test("list e2", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    decoder.decodeList(parser).then((List<Object> o) {
      unit.expect(true, false);
    }).catchError((e) {
      unit.expect(true, true);
    });
    builder.appendString("l4:test;1024ee");
    //builder.fin();
    builder.loadCompleted = true;
  });

  unit.test("list e3", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    decoder.decodeList(parser).then((List<Object> o) {
      unit.expect(true, false);
    }).catchError((e) {
      unit.expect(true, true);
    });
    builder.appendString("f4:testi1024ee");
    //builder.fin();
    builder.loadCompleted = true;
  });

  unit.test("dictionary", (){

    Map<String, Object> m = new Map();
    m["test"] = "test";
    m["value"] = 1024;
    type.Uint8List out = hetima.Bencode.encode(m);
    unit.expect("d4:test4:test5:valuei1024ee", convert.UTF8.decode(out.toList()));

    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeDiction(parser).then((Map dict) {
      unit.expect(convert.UTF8.decode(dict["test"]),"test");
      unit.expect(dict["value"],1024);
    });
    builder.addBytes(out, index:0, length:out.length);
    return e;
  });

  unit.test("dictionary e1", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeDiction(parser).then((Map dict) {
      unit.expect(true, false);
    }).catchError((e) {
      unit.expect(true, true);
    });
    builder.appendString("d4:test4:test5:valuei1024e");
    //builder.fin();
    builder.loadCompleted = true;
    return e;
  });

  unit.test("dictionary e2", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeDiction(parser).then((Map dict) {
      unit.expect(true, false);
    }).catchError((e) {
      unit.expect(true, true);
    });
    builder.appendString("d4:test4:test5:value1024ee");
    //builder.fin();
    builder.loadCompleted = true;
    return e;
  });

  unit.test("dictionary e3", (){
    hetima.ParserBuffer builder = new hetima.ParserBuffer();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.BdecoderAsync decoder = new hetima.BdecoderAsync();
    Future e = decoder.decodeDiction(parser).then((Map dict) {
      unit.expect(true, false);
    }).catchError((e) {
      unit.expect(true, true);
    });
    builder.appendString("gg4:test4:test5:value1024ee");
    //builder.fin();
    builder.loadCompleted = true;
    return e;
  });
}
