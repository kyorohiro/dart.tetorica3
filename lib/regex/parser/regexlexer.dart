part of hetimaregex;

class RegexLexer {

  Future<List<RegexToken>> scan(List<int> text) async {
    Completer completer = new Completer();
    heti.EasyParser parser =
        new heti.EasyParser(new heti.ParserByteBuffer.fromList(text, true));

    List<RegexToken> tokens = [];
      do {
        try {
          int v = await parser.readByte();
          switch (v) {
            case 0x2a: // *
              tokens.add(new RegexToken.fromChar(v, RegexToken.star));
              break;
            case 0x5c: // \
              int vv = await parser.readByte();
              tokens.add(new RegexToken.fromChar(vv, RegexToken.character));
              break;
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
        } catch(e) {
          return tokens;
        }
      }while(true);
    return completer.future;
  }
}
