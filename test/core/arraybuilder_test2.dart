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

  unit.test("arraybuilder: addBytes", () {
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

    //unit.expect(0, buffer.toList().length);
    //unit.expect("", buffer.toText());
  });

}
