import 'package:test/test.dart' as unit;
import 'package:tetorica/stun.dart' as turn;

void main() {
  unit.test("ArrayBuilderBuffer: mapped v4", () {
    turn.StunHeader headerA = new turn.StunHeader(turn.StunHeader.bindingResponse);
    headerA.attributes.add(new turn.StunAddressAttribute(turn.StunAttribute.mappedAddress, turn.StunAddressAttribute.familyIPv4, 6881, "127.0.0.1"));
    headerA.attributes.add(new turn.StunChangeRequestAttribute(true, false));
    headerA.attributes.add(new turn.StunBasicAttribute(turn.StunAttribute.userName, [1, 2, 3, 4, 5, 6, 7, 8]));
    headerA.attributes.add(new turn.StunErrorCodeAttribute(400, "abcdefghijklmn"));

    turn.StunHeader headerB = turn.StunHeader.decode(headerA.encode(), 0);
    unit.expect(headerA.type, headerB.type);
    unit.expect(headerA.attributes.length, headerB.attributes.length);
    unit.expect(headerA.attributes[0], headerB.attributes[0]);
    unit.expect(headerA.attributes[1], headerB.attributes[1]);
    unit.expect(headerA.attributes[2], headerB.attributes[2]);
    unit.expect(headerA.attributes[3], headerB.attributes[3]);
  });

  unit.test("ArrayBuilderBuffer: mapped v4", () {
    unit.expect(true, (new turn.StunHeader(turn.StunHeader.bindingResponse)).isSuccessResp());
    unit.expect(true, (new turn.StunHeader(turn.StunHeader.bindingRequest)).isRequest());
    unit.expect(true, (new turn.StunHeader(turn.StunHeader.bindingErrorResponse)).isErrResp());
  });
}
