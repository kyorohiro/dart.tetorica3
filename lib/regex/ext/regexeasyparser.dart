part of hetimaregex;

class RegexEasyParser extends heti.EasyParser {
  RegexEasyParser(heti.ParserReader builder) : super(builder) {}

  Future<List<List<int>>> readFromCommand(List<RegexCommand> command) {
    RegexVM vm = new RegexVM.createFromCommand(command);
    return vm.lookingAtFromEasyParser(this);
  }
}
