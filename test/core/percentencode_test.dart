import 'package:test/test.dart' as unit;
import 'package:tetorica/util.dart';
import 'dart:convert' as convert;

void main() {
  unit.test("ps1", () {
    List<int> v = convert.UTF8.encode("hello");
    String encode = PercentEncode.encode(v);
    unit.expect(encode, "hello");

    List<int> decode = PercentEncode.decode(encode).toList();
    unit.expect(convert.UTF8.decode(decode), "hello");
  });
  unit.test("ps2", () {
    List<int> v = convert.UTF8.encode("hello");
    String encode = PercentEncode.encode(v);
    unit.expect(encode, "hello");

    List<int> decode = PercentEncode.decode("%68a%65%6C%6C%6F").toList();
    unit.expect(convert.UTF8.decode(decode), "haello");
  });
  unit.test("ps3", () {
    List<int> v = convert.UTF8.encode("||");
    String encode = PercentEncode.encode(v);
    unit.expect(encode, "%7C%7C");

    List<int> decode = PercentEncode.decode(encode).toList();
    unit.expect(convert.UTF8.decode(decode), "||");
  });
}
