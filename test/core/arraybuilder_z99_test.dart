import 'package:test/test.dart' as unit;
import 'package:tetorica/util.dart' as hetima;
import 'package:tetorica/data.dart' as hetima;

void main() {
//  hetima.HetiTest test = new hetima.HetiTest("tt");

  unit.test("ArrayBuilderBuffer: ", () {
    hetima.TetMemoryBuffer buffer = new hetima.TetMemoryBuffer(5);
    unit.expect(5, buffer.length);

    buffer[0] = 1;
    buffer[1] = 2;
    buffer[2] = 3;
    buffer[3] = 4;
    buffer[4] = 5;

    buffer.unusedBuffer(3,reuse: false);

    unit.expect(0, buffer[0]);
    unit.expect(0, buffer[1]);
    unit.expect(0, buffer[2]);
    unit.expect(4, buffer[3]);
    unit.expect(5, buffer[4]);
    unit.expect(5, buffer.length);
    unit.expect(2, buffer.rawbuffer8.length);

    buffer.expandBuffer(10);
    buffer.unusedBuffer(4,reuse: false);
    unit.expect(0, buffer[0]);
    unit.expect(0, buffer[1]);
    unit.expect(0, buffer[2]);
    unit.expect(0, buffer[3]);
    unit.expect(5, buffer[4]);
    unit.expect(10, buffer.length);
    unit.expect(6, buffer.rawbuffer8.length);

    buffer[4] = 5;
    buffer[5] = 6;
    buffer[6] = 7;
    buffer[7] = 8;
    buffer[8] = 9;
    buffer[9] = 10;
    unit.expect(5, buffer[4]);
    unit.expect(6, buffer[5]);
    unit.expect(7, buffer[6]);
    unit.expect(8, buffer[7]);
    unit.expect(9, buffer[8]);
    unit.expect(10, buffer[9]);

    unit.expect([0,0,0,0,5,6,7,8,9,10], buffer.sublist(0, 10));
    unit.expect([0,0,5,6,7,8,9], buffer.sublist(2, 9));
    unit.expect([9], buffer.sublist(8, 9));
    unit.expect([], buffer.sublist(8, 8));

    buffer.unusedBuffer(10,reuse: false);
    unit.expect(0, buffer.rawbuffer8.length);
  });

  unit.test("ArrayBuilderBuffer: ", () {
    hetima.TetMemoryBuffer buffer = new hetima.TetMemoryBuffer(5);
    unit.expect(5, buffer.length);

    buffer[0] = 1;
    buffer[1] = 2;
    buffer[2] = 3;
    buffer[3] = 4;
    buffer[4] = 5;

    buffer.unusedBuffer(3,reuse: true);

    unit.expect(0, buffer[0]);
    unit.expect(0, buffer[1]);
    unit.expect(0, buffer[2]);
    unit.expect(4, buffer[3]);
    unit.expect(5, buffer[4]);
    unit.expect(5, buffer.length);
    unit.expect(5, buffer.rawbuffer8.length);

    buffer.expandBuffer(10);
    buffer.unusedBuffer(4,reuse: true);
    unit.expect(0, buffer[0]);
    unit.expect(0, buffer[1]);
    unit.expect(0, buffer[2]);
    unit.expect(0, buffer[3]);
    unit.expect(5, buffer[4]);
    unit.expect(10, buffer.length);
    unit.expect(7, buffer.rawbuffer8.length);

    buffer[4] = 5;
    buffer[5] = 6;
    buffer[6] = 7;
    buffer[7] = 8;
    buffer[8] = 9;
    buffer[9] = 10;
    unit.expect(5, buffer[4]);
    unit.expect(6, buffer[5]);
    unit.expect(7, buffer[6]);
    unit.expect(8, buffer[7]);
    unit.expect(9, buffer[8]);
    unit.expect(10, buffer[9]);

    unit.expect([0,0,0,0,5,6,7,8,9,10], buffer.sublist(0, 10));
    unit.expect([0,0,5,6,7,8,9], buffer.sublist(2, 9));
    unit.expect([9], buffer.sublist(8, 9));
    unit.expect([], buffer.sublist(8, 8));

    buffer.unusedBuffer(10,reuse: true);
    unit.expect(7, buffer.rawbuffer8.length);
  });
}
