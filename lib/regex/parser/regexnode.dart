part of hetimaregex;

abstract class RegexLeaf {
  List<RegexCommand> convertRegexCommands();
}

class RegexCommandLeaf extends RegexLeaf {
  RegexCommand _command = null;
  RegexCommandLeaf(RegexCommand c) {
    _command = c;
  }
  List<RegexCommand> convertRegexCommands() {
    return [_command];
  }
}

class RegexNode extends RegexLeaf{
  List<List<RegexLeaf>> elementsList = [[]];
  List<RegexLeaf> get elements => elementsList.last;

  List<RegexCommand> convertRegexCommands(){
    List<RegexCommand> ret = [];
    for(Object o in elements) {
      if(o is RegexNode) {
        ret.addAll(o.convertRegexCommands());
      } else if(o is RegexCommand){
        ret.add(o);
      }
    }
    return ret;
  }

  void addRegexNode(RegexNode node) {
    elements.add(node);
  }

  void addRegexCommand(RegexCommand c) {
    elements.add(new RegexCommandLeaf(c));
  }
}

class CharacterPattern extends RegexNode {
  List<int> _characters = [];
  CharacterPattern.fromBytes(List<int> v) {
    _characters.addAll(v);
  }
  List<RegexCommand> convertRegexCommands() {
    return [new CharCommand.createFromList(_characters)];
  }
}

class StarPattern extends RegexNode {
  RegexLeaf e1 = null;

  StarPattern.fromPattern(RegexLeaf e1) {
    this.e1 = e1;
  }

  StarPattern.fromCommand(RegexCommand c) {
    this.e1 = new RegexCommandLeaf(c);
  }
  List<RegexCommand> convertRegexCommands() {
    List<RegexCommand> e1List = e1.convertRegexCommands();

    List<RegexCommand> ret = [];
    ret.add(new SplitTaskCommand.create(1, (e1List.length) + 2));
    ret.addAll(e1List);
    ret.add(new JumpTaskCommand.create(-1 * (e1List.length) - 1));
    return ret;
  }
}

class GroupPattern extends RegexNode {
  bool _isSaveInMemory = false;

  GroupPattern({isSaveInMemory: true, List<RegexLeaf> elements: null}) {
    this._isSaveInMemory = isSaveInMemory;
    if (elements != null) {
      this.elements.addAll(elements);
    }
  }

  //
  //
  void groupingCurrentElement() {
    this.elementsList.add([]);
  }

  List<RegexCommand> convertRegexCommands() {
    List<RegexCommand> ret = [];
    List<List<RegexCommand>> commandPerOrgroup = [];

    for (List<RegexLeaf> p in elementsList) {
      List<RegexCommand> t = [];
      for(RegexLeaf l in p) {
        t.addAll(l.convertRegexCommands());
      }
      commandPerOrgroup.add(t);
    }
    if (_isSaveInMemory) {
      ret.add(new MemoryStartCommand());
    }

    ret.addAll(_combineRegexCommand(commandPerOrgroup));

    if (_isSaveInMemory) {
      ret.add(new MemoryStopCommand());
    }
    return ret;
  }

  int _commandLengthAfterCombined(List<List<RegexCommand>> tmp) {
    int commandLength = (tmp.length - 1) * 2 + 1;
    for (int i = 0; i < tmp.length; i++) {
      commandLength += tmp[i].length;
    }
    return commandLength;
  }

  List<RegexCommand> _combineRegexCommand(List<List<RegexCommand>> tmp) {
    List<RegexCommand> ret = [];

    if (tmp.length == 1) {
      ret.addAll(tmp[0]);
      return ret;
    } else {
      int commandLength = _commandLengthAfterCombined(tmp);

      int currentLength = 0;
      for (int i = 0; i < tmp.length; i++) {
        if (i < (tmp.length - 1)) {
          ret.add(new SplitTaskCommand.create(1, tmp[i].length + 2));
          currentLength += 1;
          ret.addAll(tmp[i]);
          currentLength += tmp[i].length;
          ret.add(new JumpTaskCommand.create(commandLength - currentLength));
          currentLength += 1;
        } else {
          ret.add(new SplitTaskCommand.create(1, tmp[i].length + 1));
          currentLength += 1;
          ret.addAll(tmp[i]);
          currentLength += tmp[i].length;
        }
      }
    }
    return ret;
  }
}
