//import 'package:unittest/unittest.dart' as unit;
import 'package:tetorica/util.dart' as hetima;
import 'package:tetorica/net.dart' as hetima;
import 'package:test/test.dart' as unit;

void main() {

  unit.test("a",(){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("");
    unit.expect(0, map.length);
  });

  unit.test("aa",(){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("=");
    unit.expect(1, map.length);
    unit.expect("",map[""]);
  });

  unit.test("b",(){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("xxx=ccc");
    unit.expect(1, map.length);
    unit.expect("ccc", map["xxx"]);
  });

  unit.test("c",(){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("xxx=ccc&ddd=xxx");
    unit.expect(2, map.length);
    unit.expect("ccc", map["xxx"]);
    unit.expect("xxx", map["ddd"]);
  });

  unit.test("d",(){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("xxx=ccc&ddd=x?x");
    unit.expect(2, map.length);
    unit.expect("ccc", map["xxx"]);
    unit.expect("x?x", map["ddd"]);
  });

  unit.test("e",(){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=%2D%2D%74%65%73%74%87%E4%36%2A%55%AB%0C%E2%B5%33%C2%4B%79%84&event=started&uploaded=0&downloaded=0&left=0");
    unit.expect("%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD",map["info_hash"]);
  });

  unit.test("f",() {
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=%2D%2D%74%65%73%74%87%E4%36%2A%55%AB%0C%E2%B5%33%C2%4B%79%84&event=started&uploaded=0&downloaded=0&left=0");
    unit.expect("%5F%C6%B8%A2%64%63%33%F5%63%9D%4E%95%2B%9B%B8%AD%EE%12%1A%BD", map["info_hash"]);
  });

  unit.test("g", (){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=--test%87%E46%2AU%AB%0C%E2%B53%C2Ky%84&event=started&uploaded=0&downloaded=0&left=0");
    unit.expect("_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD", map["info_hash"]);
  });

  unit.test("h",(){
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("info_hash=_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD&port=6969&peer_id=--test%87%E46%2AU%AB%0C%E2%B53%C2Ky%84&event=started&uploaded=0&downloaded=0&left=0");
    unit.expect("_%C6%B8%A2dc3%F5c%9DN%95%2B%9B%B8%AD%EE%12%1A%BD", map["info_hash"]);
  });
}
