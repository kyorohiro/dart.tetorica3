part of hetimanet_stun;

class StunServer {
  net.TetSocketBuilder builder;
  String primaryIP;
  int primaryPort;

  String secondaryIP;
  int secondaryPort;

  net.TetUdpSocket primaryUdp;
  net.TetUdpSocket primaryUdpWithDiffPort;
  net.TetUdpSocket secondaryUdp;
  net.TetUdpSocket secondaryUdpWithDiffPort;

  StunServer(this.builder, this.primaryIP, this.primaryPort, this.secondaryIP, this.secondaryPort) {}

  Future go() async {
    primaryUdp = builder.createUdpClient();
    primaryUdpWithDiffPort = builder.createUdpClient();
    secondaryUdp = builder.createUdpClient();
    secondaryUdpWithDiffPort = builder.createUdpClient();

    await primaryUdp.bind(primaryIP, primaryPort);
    await primaryUdpWithDiffPort.bind(primaryIP, secondaryPort);
    await secondaryUdp.bind(secondaryIP, primaryPort);
    await secondaryUdpWithDiffPort.bind(secondaryIP, secondaryPort);

    await primaryAct();
  }

  Future primaryAct() async {
    print("-- prim");
    await for (net.TetReceiveUdpInfo info in primaryUdp.onReceive) {
      print("-- -- prim ${info.data} ${info.remoteAddress} ${info.remotePort}");
      try {
        StunHeader receivedHeader = await StunHeader.decode(info.data, 0);
        bool changeIP = false;
        bool changePort = false;
        StunRfcVersion rfcVersion = StunRfcVersion.ref3489;

        if (receivedHeader.haveChangeRequest()) {
          StunChangeRequestAttribute attr = receivedHeader.changeReuest();
          changeIP = attr.changeIP;
          changePort = attr.changePort;
        }

        net.TetUdpSocket udpSock = null;
        if (changeIP == false && changePort == false) {print("--sA");
          udpSock = primaryUdp;
        } else if (changeIP == true && changePort == true) {print("--sB");
          udpSock = secondaryUdpWithDiffPort;
        } else if (changeIP == true && changePort == false) {print("--sC");
          udpSock = primaryUdpWithDiffPort;
        } else if (changeIP == false && changePort == true) {print("--sD");
          udpSock = secondaryUdp;
        }
        StunHeader header = new StunHeader(StunHeader.bindingResponse, version:rfcVersion, transactionID: receivedHeader.transactionID);

        header.attributes.add(header.createMappedAddressAttribute(info.remoteAddress, info.remotePort));
        header.attributes.add(header.createOtherAddressAttribute(secondaryIP, secondaryPort));
        header.attributes.add(header.createOriginAddressAttribute(primaryIP, primaryPort));

        udpSock.send(header.encode(), info.remoteAddress, info.remotePort);
        print("--send");
        //
      } catch (e, t) {
        print("-e-${e} ${t}");
      }
    }
  }
}
