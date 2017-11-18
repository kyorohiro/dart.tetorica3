import 'package:test/test.dart' as unit;
import 'package:tetorica/util.dart' as hetima;
import 'package:tetorica/data.dart' as hetima;
import 'package:tetorica/parser.dart' as hetima;

import 'dart:async';

void main() {

  unit.test("arraybuilder: init", () {
    hetima.ParserListBuffer buffer = new hetima.ParserListBuffer();
    unit.expect(0, buffer.currentSize);
    unit.expect(0, buffer.toList().length);
    unit.expect("", buffer.toText());
  });

  unit.test("arraybuilder: addBytes 00", () {
    hetima.ParserListBuffer buffer = new hetima.ParserListBuffer();
    buffer.addBytes([1,2,3]);
    buffer.addBytes([2,3,4]);
    unit.expect(buffer.currentSize, 6);
    unit.expect(buffer[0], 1);
    unit.expect(buffer[1], 2);
    unit.expect(buffer[2], 3);
    unit.expect(buffer[3], 2);
    unit.expect(buffer[4], 3);
    unit.expect(buffer[5], 4);
  });

  unit.test("arraybuilder: addBytes 02", () async {
    hetima.ParserListBuffer buffer = new hetima.ParserListBuffer();
    buffer.addBytes([1,2,3]);
    buffer.addBytes([2,3,4]);
    buffer.unusedBuffer(3);
    unit.expect(buffer[0], 0);
    unit.expect(buffer[1], 0);
    unit.expect(buffer[2], 0);
    unit.expect(buffer[3], 2);
    unit.expect(buffer[4], 3);
    unit.expect(buffer[5], 4);
    List<int> r = await buffer.getBytes(1, 3);
    unit.expect(r[0], 0);
    unit.expect(r[1], 0);
    unit.expect(r[2], 2);
  });

  unit.test("arraybuilder: senario", () {
    hetima.ParserListBuffer builder = new hetima.ParserListBuffer();
    builder.appendString("abc");
    unit.expect("abc", builder.toText());
    unit.expect(3, builder.toList().length);
    builder.appendString("abc");
    unit.expect("abcabc", builder.toText());
    unit.expect(6, builder.toList().length);
  });

  unit.test("ArrayBuilderBuffer: [2]", () async {
    hetima.ParserListBuffer builder = new hetima.ParserListBuffer();
    unit.expect(0, builder.currentSize);

    bool isOK1 = false;
    bool isOK2 = false;
    builder.getBytes(5, 1).then((List<int > v) {
      unit.expect(builder.currentSize, 6);
      isOK1 = true;
    });
    await new Future(() {
      builder.addByte(1);
    });
    await new Future(() {
      builder.addByte(2);
    });
    await new Future(() {
      builder.addByte(3);
    });
    await new Future(() {
      builder.addByte(4);
    });
    await new Future(() {
      builder.addByte(5);
    });
    await new Future(() {
      builder.addByte(6);
    });

    builder.getBytes(8, 1).then((List<int > v) {
      unit.expect(v[0], 9);
      isOK2 = true;
    });
    await new Future(() {
      builder.addBytes([7,8,9]);
    });

    await new Future((){});
    return new Future(() {
      unit.expect(isOK1, true);
      unit.expect(isOK2, true);
    });
  });


  unit.test("ArrayBuilderBuffer: [2]", () async {
    hetima.ParserListBuffer builder = new hetima.ParserListBuffer();
    builder.getBytes(2, 3).then((List<int > v) {
      unit.expect(v.length, 2);
      unit.expect(3, v[0]);
      unit.expect(4, v[1]);
    });
    await new Future(() {
      builder.addByte(1);
    });
    await new Future(() {
      builder.addByte(2);
    });
    await new Future(() {
      builder.addByte(3);
    });
    await new Future(() {
      builder.addByte(4);
    });
    //builder.fin();
    builder.loadCompleted = true;
  });
}
