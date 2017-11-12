part of hetimanet_stun;

class StunClientBasicTestResult {
  List<StunNatType> possibility = [];
  List<net.IPAddr> addr = [];
  StunClientBasicTestResult(this.possibility, this.addr) {}
}

class StunClientBasicTest {
  StunClient client;
  StunClientBasicTest(this.client) {
    ;
  }

  Future prepare() async {
    return await client.prepare();
  }

  Future<List<StunNatType>> testBasic(
    {List<net.IPAddr> expectedIpList, List<int> expectedPortList}) async {
    StunClientSendHeaderResult test1Result = null;
    StunClientSendHeaderResult test1ResultB = null;
    StunClientSendHeaderResult test2Result = null;
    StunClientSendHeaderResult test3Result = null;
    //
    // test 001
    try {
      test1Result = await test001();
      if (false == test1Result.passed()) {
        return [StunNatType.stunServerThrowError];
      }
      if (false == test1Result.header.haveOtherAddress()) {
        if (expectedIpList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
          return [StunNatType.openInternet, StunNatType.symmetricUdpFirewall];
        } else {
          return [StunNatType.fullConeNat, StunNatType.symmetricNat, StunNatType.restricted, StunNatType.portRestricted];
        }
      }
    } catch (e) {
      // test1 is no response
      return [StunNatType.blockUdp];
    }

    //
    // test 002
    try {
      test2Result = await test002();
      print("#### ${expectedIpList}");
      print("#### ${test1Result.header.mappedAddress()}");
      if (expectedIpList.contains(new net.IPAddr.fromString(test1Result.header.mappedAddress()))) {
        if (test2Result.passed()) {
          return [StunNatType.openInternet];
        } else {
          return [StunNatType.stunServerThrowError];
        }
      } else {
        if (test2Result.passed()) {
          return [StunNatType.fullConeNat];
        } else {
          return [StunNatType.stunServerThrowError];
        }
      }
    } catch (e) {
      if (expectedIpList.contains(new net.IPAddr.fromString(test1Result.remoteAddress))) {
        return [StunNatType.symmetricUdpFirewall];
      }
    }

    ///
    ///
    ///
    try {
      test1ResultB = await test001();
      if (false == test1ResultB.passed()) {
        return [StunNatType.stunServerThrowError];
      }
      if(test1ResultB.header.mappedAddress() != test1Result.header.mappedAddress()) {
        return [StunNatType.symmetricNat];
      }
    } catch (e) {
      // test1 is no response
      return [StunNatType.stunServerThrowError];
    }

    //
    //
    // print("###-----");
    try {
      test3Result = await test003();
      if (false == test3Result.passed()) {
        return [StunNatType.stunServerThrowError];
      }
      return [StunNatType.restricted];
    } catch (e) {
      return [StunNatType.portRestricted];
    }

    return [StunNatType.restricted, StunNatType.portRestricted];
  }

  Future<StunClientSendHeaderResult> test001({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    if (version == StunRfcVersion.ref3489) {
      header.attributes.add(new StunChangeRequestAttribute(false, false));
    }
    //print("----------1");
    await client.prepare();
    //print("----------2");
    var ret = await client.sendHeader(header);
    //print("----------3");
    client.close();
    //print("----------4");
    return ret;
  }

  Future<StunClientSendHeaderResult> test002({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    header.attributes.add(new StunChangeRequestAttribute(true, true));
    await client.prepare();
    var ret = await client.sendHeader(header);
    client.close();
    return ret;
  }

  Future test003({StunRfcVersion version: StunRfcVersion.ref3489}) async {
    StunHeader header = new StunHeader(StunHeader.bindingRequest, version: version);
    header.attributes.add(new StunChangeRequestAttribute(false, true));
    await client.prepare();
    var ret = await client.sendHeader(header);
    client.close();
    return ret;
  }
}
