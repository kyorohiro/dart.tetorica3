import 'package:test/test.dart' as unit;
import 'package:tetorica/data.dart';
import 'package:tetorica/util.dart';
import 'package:tetorica/dartio_data.dart';
import 'dart:convert';

void main() {
  unit.test("arraybuilder: init", () async {
    {
      {
        HetimaDataDartIO io = new HetimaDataDartIO("./test/core/test.data", erace: true);
        int l = await io.getLength();
        unit.expect(0, l);
        await io.write(UTF8.encode("abc"), 0);
        await io.write(UTF8.encode("def"), 3);
        io.close();
      }
      {
        HetimaDataDartIO io = new HetimaDataDartIO("./test/core/test.data");
        int l = await io.getLength();
        unit.expect(6, l);
        ReadResult r = await io.read(0, l);
        String m = UTF8.decode(r.buffer);
        unit.expect(m, "abcdef");
        io.close();
      }
    }

    {
      {
        HetimaDataDartIO io = new HetimaDataDartIO("./test/core/test.data", erace: true);
        int l = await io.getLength();
        unit.expect(0, l);
        await io.write(UTF8.encode("abc"), 0);
        await io.write(UTF8.encode("def"), 6);
        await io.write(UTF8.encode("ghq"), 3);
        io.close();
      }
      {
        HetimaDataDartIO io = new HetimaDataDartIO("./test/core/test.data");
        int l = await io.getLength();
        unit.expect(9, l);
        ReadResult r = await io.read(0, l);
        String m = UTF8.decode(r.buffer);
        unit.expect(m, "abcghqdef");
        io.close();
      }
    }
  });
}
