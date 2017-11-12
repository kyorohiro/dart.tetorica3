import 'package:test/test.dart' as unit;
import 'package:tetorica/data.dart';
import 'package:tetorica/parser.dart';
import 'package:tetorica/core.dart';

void main() {
  unit.test("nextBuffer", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendIntList([1, 2, 3, 4, 5]);
      EasyParser parser = new EasyParser(b);
      List<int> bb = await parser.nextBuffer(3);
      unit.expect(bb, [1, 2, 3]);
    }
  });

  unit.test("nextString", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendString("abc");
      EasyParser parser = new EasyParser(b);
      String bb = await parser.nextString("abc");
      unit.expect(bb, "abc");
    }
  });

  unit.test("readSign", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendString("abc");
      EasyParser parser = new EasyParser(b);
      String bb = await parser.readSignWithLength(2);
      unit.expect(bb, "ab");
    }
  });
  unit.test("readShort", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendIntList(ByteOrder.parseShortByte(10, ByteOrderType.BigEndian));
      EasyParser parser = new EasyParser(b);
      int bb = await parser.readShort(ByteOrderType.BigEndian);
      unit.expect(bb, 10);
    }
  });


  unit.test("readInt", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendIntList(ByteOrder.parseIntByte(10, ByteOrderType.LittleEndian));
      EasyParser parser = new EasyParser(b);
      int bb = await parser.readInt(ByteOrderType.LittleEndian);
      unit.expect(bb, 10);
    }
  });

  unit.test("readLong", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendIntList(ByteOrder.parseLongByte(10, ByteOrderType.LittleEndian));
      EasyParser parser = new EasyParser(b);
      int bb = await parser.readLong(ByteOrderType.LittleEndian);
      unit.expect(bb, 10);
    }
  });

  unit.test("readByte", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendByte(10);
      EasyParser parser = new EasyParser(b);
      int bb = await parser.readByte();
      unit.expect(bb, 10);
    }
  });

  unit.test("nextBuffer", () async {
    {
      ArrayBuilder b = new ArrayBuilder();
      b.appendIntList([1,2,3,4,5,6]);
      EasyParser parser = new EasyParser(b);
      List<int> b1 = await parser.nextBuffer(3);
      unit.expect(b1, [1,2,3]);
      List<int> b2 = await parser.nextBuffer(3);
      unit.expect(b2, [4,5,6]);
    }
  });

}
