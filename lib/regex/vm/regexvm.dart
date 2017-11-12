part of hetimaregex;

class RegexVM {
  List<RegexCommand> _commands = [];
  List<RegexTask> _tasks = [];

  RegexVM.createFromCommand(List<RegexCommand> command) {
    _commands = new List.from(command);
  }

  void addCommand(RegexCommand command) {
    _commands.add(command);
  }

//  void _addTask(RegexTask task) {
//      _tasks.add(task);
//  }

  void _insertTask(int index, RegexTask task) {
    _tasks.insert(index, task);
  }

  String toString() {
    String ret = "";
    for (RegexCommand c in _commands) {
      ret += "${c.toString()}\n";
    }
    return ret;
  }

  bool get _haveCurrentTask {
    if (_tasks.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  RegexTask get _currentTask {
    if (_haveCurrentTask) {
      return _tasks[0];
    } else {
      throw new Exception("");
    }
  }

  RegexTask _eraseCurrentTask() {
    if (_haveCurrentTask) {
      RegexTask prevTask = _tasks[0];
      _tasks.removeAt(0);
      return prevTask;
    } else {
      throw new Exception("");
    }
  }

  async.Future<List<List<int>>> lookingAt(List<int> text) {
    heti.EasyParser parser = new heti.EasyParser(new heti.ArrayBuilder.fromList(text, true));
    return lookingAtFromEasyParser(parser);
  }

  async.Future<List<List<int>>> lookingAtFromEasyParser(heti.EasyParser parser) {
    async.Completer completer = new async.Completer();
    _tasks.add(new RegexTask.fromCommnadPos(0, parser));

    loop() {
      if (!_haveCurrentTask) {
        completer.completeError(new Exception());
        return;
      }
      _currentTask.lookingAt(this).then((List<List<int>> v) {
        parser.resetIndex(_currentTask._parseHelperWithTargetSource.getInedx());
        _tasks.clear();
        completer.complete(v);
      }).catchError((e) {
        _eraseCurrentTask();
        loop();
      });
    }
    loop();
    return completer.future;
  }
}
