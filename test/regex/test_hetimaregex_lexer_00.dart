library dart_hetimaparser_test_lexer;

import 'package:tetorica/regex.dart' as regex;
import 'package:test/test.dart';

import 'dart:convert' as conv;

void main() => script00();

void script00() {
  group('lexer0', () {
    test('char true', () {
      regex.RegexLexer lexer = new regex.RegexLexer();

      return lexer.scan(conv.UTF8.encode("aa|v\\n(a*)")).then((List<regex.RegexToken> v) {
        expect(true, true);
        expect(v[0].kind, regex.RegexToken.character);
        expect(v[1].kind, regex.RegexToken.character);
        expect(v[2].kind, regex.RegexToken.union);
        expect(v[3].kind, regex.RegexToken.character);
        expect(v[4].kind, regex.RegexToken.character);
        expect(v[5].kind, regex.RegexToken.lparan);
        expect(v[6].kind, regex.RegexToken.character);
        expect(v[7].kind, regex.RegexToken.star);
        expect(v[8].kind, regex.RegexToken.rparen);
      }).catchError((e) {
        expect(true, false);
      });
    });

  });
}

//commentLong()
