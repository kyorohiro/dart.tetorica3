import 'package:test/test.dart' as unit;
import 'package:tetorica/net.dart';

void main() {
  unit.group("ipaddr", () {

    unit.test("localhost", () {
      IPAddr addrV6 = new IPAddr.fromString("fe80::10dd:b1ff:fe1d:2c64%bridge100");
      unit.expect("fe80:0:0:0:10dd:b1ff:fe1d:2c64%bridge100", addrV6.toString());
    });
    unit.test("localhost", () {
      IPAddr addrV4 = new IPAddr.fromString("127.0.0.1");
      IPAddr addrV4b = new IPAddr.fromString("127.255.255.255");
      IPAddr addrV6 = new IPAddr.fromString(":1");
      IPAddr addrV6b = new IPAddr.fromString("::1");
      unit.expect(true, addrV4.isLocalHost());
      unit.expect(true, addrV4b.isLocalHost());
      unit.expect(true, addrV6.isLocalHost());
      unit.expect(true, addrV6b.isLocalHost());
    });
    unit.test("broadcast", () {
      IPAddr addrV4 = new IPAddr.fromString("255.255.255.255");
      IPAddr addrV6 = new IPAddr.fromString("ff02::1");
      unit.expect(true, addrV4.isBroadcast());
      unit.expect(true, addrV6.isBroadcast());
    });
    unit.test("linklocal", () {
      IPAddr addrV4 = new IPAddr.fromString("169.254.0.0");
      IPAddr addrV4b = new IPAddr.fromString("169.254.255.255");
      IPAddr addrV6 = new IPAddr.fromString("fe80::");
      IPAddr addrV6b = new IPAddr.fromString("febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff");
      unit.expect(true, addrV4.isLinkLocal());
      unit.expect(true, addrV4b.isLinkLocal());
      unit.expect(true, addrV6.isLinkLocal());
      unit.expect(true, addrV6b.isLinkLocal());
    });

    unit.test("private", () {
      IPAddr addrV4a = new IPAddr.fromString("10.0.0.0");
      IPAddr addrV4b = new IPAddr.fromString("10.255.255.255");
      IPAddr addrV4c = new IPAddr.fromString("172.16.0.0");
      IPAddr addrV4d = new IPAddr.fromString("172.31.255.255");
      IPAddr addrV4e = new IPAddr.fromString("192.168.0.0");
      IPAddr addrV4f = new IPAddr.fromString("192.168.255.255");
      //
      IPAddr addrV6 = new IPAddr.fromString("fec0::");
      IPAddr addrV6b = new IPAddr.fromString("feff:ffff:ffff:ffff:ffff:ffff:ffff:ffff");
      unit.expect(true, addrV4a.isPrivate());
      unit.expect(true, addrV4b.isPrivate());
      unit.expect(true, addrV4c.isPrivate());
      unit.expect(true, addrV4d.isPrivate());
      unit.expect(true, addrV4e.isPrivate());
      unit.expect(true, addrV4f.isPrivate());
      unit.expect(true, addrV6.isPrivate());
      unit.expect(true, addrV6b.isPrivate());
    });

    unit.test("multicast", () {
      IPAddr addrV4 = new IPAddr.fromString("224.0.0.0");
      IPAddr addrV4b = new IPAddr.fromString("239.255.255.255");
      IPAddr addrV6 = new IPAddr.fromString("ff00::");
      IPAddr addrV6b = new IPAddr.fromString("ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff");
      unit.expect(true, addrV4.isMulticast());
      unit.expect(true, addrV4b.isMulticast());
      unit.expect(true, addrV6.isMulticast());
      unit.expect(true, addrV6b.isMulticast());
    });
  });

  unit.group("ipconv v4", () {
    unit.test("127.0.255.1", () {
      unit.expect(IPConv.toIPString([127, 0, 255, 1]), "127.0.255.1");
    });
    unit.test("127.0.255.1", () {
      unit.expect(IPConv.toRawIP("127.0.255.1"), [127, 0, 255, 1]);
    });
    unit.test("0.0.255.1", () {
      unit.expect(IPConv.toRawIP("0.0.255.1"), [0, 0, 255, 1]);
    });
    unit.test("www.a.exsample.com", () async {
      try {
        unit.expect(IPConv.toRawIP("www.a.exsample.com"), [0, 0, 255, 1]);
        unit.expect(true, false);
      } catch (e) {}
    });
  });

  unit.group("ipconv v6", () {
    unit.test("2001:db8:20:3:1000:100:20:3", () {
      unit.expect(IPConv.toIPString([0x20, 0x01, 0x0d, 0xb8, 0x00, 0x20, 0x00, 0x03, 0x10, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00, 0x03]), "2001:db8:20:3:1000:100:20:3");
    });

    unit.test("2001:db8:20:3:1000:100:20:3", () {
      unit.expect(IPConv.toRawIP("2001:db8:20:3:1000:100:20:3"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x20, 0x00, 0x03, 0x10, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00, 0x03]);
    });

    unit.test("2001:0db8:0020:0003:1000:0100:0020:0003", () {
      unit.expect(IPConv.toRawIP("2001:0db8:0020:0003:1000:0100:0020:0003"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x20, 0x00, 0x03, 0x10, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00, 0x03]);
    });
    unit.test("2001:0db8:0000:0000:0000:0000:0000:9abc", () {
      unit.expect(IPConv.toRawIP("2001:0db8:0000:0000:0000:0000:0000:9abc"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9a, 0xbc]);
    });
    unit.test("2001:db8::9abc", () {
      unit.expect(IPConv.toRawIP("2001:db8::9abc"), [0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9a, 0xbc]);
    });
  });
}
