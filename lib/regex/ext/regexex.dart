part of hetimaregex;

class AllCharCommand extends RegexCommand {
  @override
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    parser.readByte().then((int v) {
      vm._currentTask._nextCommandLocation += 1;
      c.complete([v]);
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
  String toString() {
    return "<all char>";
  }
}

class EmptyCommand extends RegexCommand {
  @override
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    vm._currentTask._nextCommandLocation += 1;
    c.complete([]);
    return c.future;
  }
  String toString() {
    return "<empty>";
  }
}

class MatchByteCommand extends RegexCommand {
  List<int> target = [];
  MatchByteCommand(List<int> target) {
    this.target.addAll(target);
  }

  @override
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    parser.readByte().then((int v) {
      for(int d in target) {
        if(d == v) {
          vm._currentTask._nextCommandLocation += 1;
          c.complete([v]);
          return;
        }
      }
      c.completeError(new Exception());      
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}

class UnmatchByteCommand extends RegexCommand {
  List<int> target = [];
  UnmatchByteCommand(List<int> target) {
    this.target.addAll(target);
  }

  @override
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    parser.readByte().then((int v) {
      for(int d in target) {
        if(d == v) {
          c.completeError(new Exception()); 
          return;
        }
      }
      vm._currentTask._nextCommandLocation += 1;
      c.complete([v]);     
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}
class UncharacterCommand extends RegexCommand {
  List<int> without = [];
  UncharacterCommand(List<int> without) {
    this.without.addAll(without);
  }

  @override
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    int length = without.length;
    parser.push();
    parser.nextBuffer(length).then((List<int> v) {
      parser.back();
      parser.pop();
      if (v.length == 0) {
        c.completeError(new Exception());
        return;
      }
      if (v.length == length) {
        for (int i = 0; i < length; i++) {
          if (v[i] != without[i]) {
            vm._currentTask._nextCommandLocation += 1;
            parser.resetIndex(parser.getInedx() + 1);
            c.complete([v[0]]);
            return;
          }
        }
        c.completeError(new Exception());
      } else {
        // todo
        vm._currentTask._nextCommandLocation += 1;
        parser.resetIndex(parser.getInedx() + 1);
        c.complete([v[0]]);
        return;
      }

    }).catchError((e) {      
      parser.pop();
      c.completeError(e);
    });
    return c.future;
  }
  String toString() {
    return "<not char> ${conv.UTF8.decode(without)}";
  }
}

class RegexBuilder {
  GroupPattern root = new GroupPattern(isSaveInMemory: false);
  List<GroupPattern> stack = [];
  RegexBuilder() {
    stack.add(root);
  }

  RegexBuilder addRegexLeaf(RegexLeaf leaf) {
    stack.last.addRegexNode(leaf);
    return this;
  }

  RegexBuilder addRegexCommand(RegexCommand comm) {
    stack.last.addRegexCommand(comm);
    return this;
  }

  RegexBuilder or() {
    stack.last.groupingCurrentElement();
    return this;
  }

  RegexBuilder push(bool isSaveInMemory) {
    GroupPattern p = new GroupPattern(isSaveInMemory: isSaveInMemory);
    stack.last.addRegexNode(p);
    stack.add(p);
    return this;
  }

  RegexBuilder pop() {
    stack.removeLast();
    return this;
  }

  List<RegexCommand> done() {
    List<RegexCommand> ret = root.convertRegexCommands();
    ret.add(new MatchCommand());
    return ret;
  }
}
