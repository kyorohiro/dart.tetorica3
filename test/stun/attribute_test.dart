import 'package:test/test.dart' as unit;
//import 'package:tetorica/util.dart' as hetima;
import 'package:tetorica/stun.dart' as turn;
//import 'dart:async';

void main() {
  unit.test("ArrayBuilderBuffer: mapped v4", () {
    turn.StunAddressAttribute attrA = new turn.StunAddressAttribute(turn.StunAttribute.mappedAddress, turn.StunAddressAttribute.familyIPv4, 6881, "127.0.0.1");
    turn.StunAddressAttribute attrB = turn.StunAddressAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.address, attrB.address);
    unit.expect(attrA.family, attrB.family);
    unit.expect(attrA.port, attrB.port);
    unit.expect(attrA.length, attrB.length);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: mapped v6", () {
    turn.StunAddressAttribute attrA = new turn.StunAddressAttribute(turn.StunAttribute.mappedAddress, turn.StunAddressAttribute.familyIPv6, 6881, "2001:db8:0:0:0:0:0:9abc"); //"2001:db8::9abc");
    turn.StunAddressAttribute attrB = turn.StunAddressAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.address, attrB.address);
    unit.expect(attrA.family, attrB.family);
    unit.expect(attrA.port, attrB.port);
    unit.expect(attrA.length, attrB.length);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: change request true false", () {
    turn.StunChangeRequestAttribute attrA = new turn.StunChangeRequestAttribute(true, false);
    turn.StunChangeRequestAttribute attrB = turn.StunChangeRequestAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.changeIP, attrB.changeIP);
    unit.expect(attrA.changePort, attrB.changePort);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: change request false true", () {
    turn.StunChangeRequestAttribute attrA = new turn.StunChangeRequestAttribute(true, false);
    turn.StunChangeRequestAttribute attrB = turn.StunChangeRequestAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.changeIP, attrB.changeIP);
    unit.expect(attrA.changePort, attrB.changePort);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: basic message userName", () {
    turn.StunBasicAttribute attrA = new turn.StunBasicAttribute(turn.StunAttribute.userName, [1,2,3,4,5,6,7,8]);
    turn.StunBasicAttribute attrB = turn.StunBasicAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.value, attrB.value);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: basic message password", () {
    turn.StunBasicAttribute attrA = new turn.StunBasicAttribute(turn.StunAttribute.password, [1,2,3,4,5,6,7,8]);
    turn.StunBasicAttribute attrB = turn.StunBasicAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.value, attrB.value);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: basic message integrity", () {
    turn.StunBasicAttribute attrA = new turn.StunBasicAttribute(
      turn.StunAttribute.messageIntegrity, new List.filled(64, 2));
    turn.StunBasicAttribute attrB = turn.StunBasicAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.value, attrB.value);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  unit.test("ArrayBuilderBuffer: errorcode", () {
    turn.StunErrorCodeAttribute attrA = new turn.StunErrorCodeAttribute(400, "abcdefghijklmn");
    turn.StunErrorCodeAttribute attrB = turn.StunErrorCodeAttribute.decode(attrA.encode(), 0);
    //
    //
    unit.expect(attrA.type, attrB.type);
    unit.expect(attrA.code, attrB.code);
    unit.expect(attrA.pharse, attrB.pharse);
    unit.expect(attrA.encode().length, attrA.length+4);
  });

  //
}
