part of hetimaregex;

class RegexLexer {

  async.Future<List<RegexToken>> scan(List<int> text) {
    async.Completer completer = new async.Completer();
    heti.EasyParser parser =
        new heti.EasyParser(new heti.ArrayBuilder.fromList(text, true));

    List<RegexToken> tokens = [];
    loop() {
      parser.readByte().then((int v) {
        switch (v) {
          case 0x2a: // *
            tokens.add(new RegexToken.fromChar(v, RegexToken.star));
            break;
          case 0x5c: // \
            parser.readByte().then((int v) {
              tokens.add(new RegexToken.fromChar(v, RegexToken.character));
              loop();
            });
            return;
          case 0x28: // (
            tokens.add(new RegexToken.fromChar(v, RegexToken.lparan));
            break;
          case 0x29: // )
            tokens.add(new RegexToken.fromChar(v, RegexToken.rparen));
            break;
          case 0x7c: // |
            tokens.add(new RegexToken.fromChar(v, RegexToken.union));
            break;
          default:
            tokens.add(new RegexToken.fromChar(v, RegexToken.character));
            break;
        }
        loop();
      }).catchError((e) {
        completer.complete(tokens);
      });
    }
    loop();
    return completer.future;
  }
}
