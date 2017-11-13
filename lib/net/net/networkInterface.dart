part of hetimanet;

class NetworkInterface
{
  String address;
  int prefixLength;
  String name;

  @override
  String toString() {
    return """${{"address":address,"name":name}}""";
  }
}
