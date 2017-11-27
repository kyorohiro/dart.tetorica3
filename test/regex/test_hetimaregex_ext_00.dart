library dart_hetimaparser_test_ext;

import 'package:tetorica/regex.dart' as regex;
import 'package:test/test.dart';

import 'dart:convert' as conv;

void main() => script00();


void script00() {
  group('parser00', () {
    test('char true a', () {
      regex.RegexBuilder builder = new regex.RegexBuilder();
      builder
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("[[")))
      .push(true)
      .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.AllCharCommand()))
      .pop()
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("]]")));
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(builder.done());

      print(vm.toString());

      return vm.lookingAt(conv.UTF8.encode("[[aabb]]")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"aabb");
      }).catchError((e) {
        expect(true, false);
      });
    });
/*
    test('char true a', () {
      regex.RegexBuilder builder = new regex.RegexBuilder();
      builder
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("[[")))
      .push(true)
      .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.UncharacterCommand(conv.UTF8.encode("]]"))))
      .pop()
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("]]")));
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(builder.done());

      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode("[[aabb]]")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"aabb");
      }).catchError((e) {
        expect(true, false);
      });
    });
    regex.RegexBuilder number = new regex.RegexBuilder();
    number
    .push(true)
    .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("+")))
    .or()
    .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("-")))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop()
    .push(true)
    .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.MatchByteCommand([0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39])))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop()
    .push(true)
    .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode(".")))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop()
    .push(true)
    .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.MatchByteCommand([0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39])))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop();
    test('+1000.11', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(number.done());

      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode("+1000.11")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"+");
        expect(conv.UTF8.decode(v[1]),"1000");
        expect(conv.UTF8.decode(v[2]),".");
        expect(conv.UTF8.decode(v[3]),"11");
      }).catchError((e) {
        expect(true, false);
      });

    });
    test('.11', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(number.done());
      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode(".11")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"");
        expect(conv.UTF8.decode(v[1]),"");
        expect(conv.UTF8.decode(v[2]),".");
        expect(conv.UTF8.decode(v[3]),"11");
      }).catchError((e) {
        expect(true, false);
      });
    });

    regex.RegexBuilder hexNumber = new regex.RegexBuilder();
    hexNumber
    .push(true)
    .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("+")))
    .or()
    .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("-")))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop()
    .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("0x")))
    .push(true)
    .addRegexLeaf(new regex.StarPattern.fromCommand(
        new regex.MatchByteCommand([
          0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,
          0x61,0x62,0x63,0x64,0x65,0x66,
          0x41,0x42,0x43,0x44,0x45,0x46
          ])))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop()
    .push(true)
    .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode(".")))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop()
    .push(true)
    .addRegexLeaf(new regex.StarPattern.fromCommand(
        new regex.MatchByteCommand([
          0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,
          0x61,0x62,0x63,0x64,0x65,0x66,
          0x41,0x42,0x43,0x44,0x45,0x46
          ])))
    .or()
    .addRegexCommand(new regex.EmptyCommand())
    .pop();
    test('+0x1000.11', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(number.done());

      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode("+1000.11")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"+");
        expect(conv.UTF8.decode(v[1]),"1000");
        expect(conv.UTF8.decode(v[2]),".");
        expect(conv.UTF8.decode(v[3]),"11");
      }).catchError((e) {
        expect(true, false);
      });

    });*/
  });
}

//commentLong()
