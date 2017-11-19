import 'package:test/test.dart' as unit;
import 'package:tetorica/util.dart' as hetima;
import 'package:tetorica/data.dart' as hetima;
import 'package:tetorica/parser.dart' as hetima;

import 'dart:async';

void main() {

  unit.test("memory buffer: init", () {
    hetima.MemoryData buffer = new hetima.MemoryData();

    //unit.expect(0, buffer.currentSize);
    //unit.expect(0, buffer.toList().length);
    //unit.expect("", buffer.toText());
  });

}
