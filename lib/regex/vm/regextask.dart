part of hetimaregex;

class RegexTask {
  int _nextCommandLocation = 0;
  heti.EasyParser _parseHelperWithTargetSource = null;
  int get nextCommandLocation => _nextCommandLocation;

  List<List<int>> _memory = [];
  List<int> _currentMemoryTargetId = [];
  int _nextMemoryId = 0;

  RegexTask.clone(RegexTask tasl, [int commandPos = -1]) {
    if (commandPos != -1) {
      this._nextCommandLocation = commandPos;
    } else {
      this._nextCommandLocation = tasl._nextCommandLocation;
    }
    this._parseHelperWithTargetSource = tasl._parseHelperWithTargetSource.toClone();
    {
      //deep copy
      this._memory = [];
      for(List<int> v in tasl._memory) {
        this._memory.add(new List.from(v));
      }
    }
    this._currentMemoryTargetId = new List.from(tasl._currentMemoryTargetId);
    this._nextMemoryId = tasl._nextMemoryId;
  }

  RegexTask.fromCommnadPos(int commandPos, heti.EasyParser parser) {
    _nextCommandLocation = commandPos;
    _parseHelperWithTargetSource = parser.toClone();
  }

  void tryAddMemory(List<int> matchedData) {
    if (_currentMemoryTargetId.length > 0) {
      for (int i in _currentMemoryTargetId) {
        _memory[i].addAll(matchedData);
      }
    }
  }

  async.Future<List<int>> executeNextCommand(RegexVM vm) {
    async.Completer<List<int>> completer = new async.Completer();
    if (_nextCommandLocation >= vm._commands.length) {
      completer.completeError(new Exception(""));
      return completer.future;
    }
    RegexCommand c = vm._commands[_nextCommandLocation];
    c.check(vm, _parseHelperWithTargetSource).then((List<int> v) {
      completer.complete(v);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<List<int>>> lookingAt(RegexVM vm) {
    async.Completer<List<List<int>>> completer = new async.Completer();
    loop() {
      return executeNextCommand(vm).then((List<int> matchedData) {
        tryAddMemory(matchedData);
        return loop();
      }).catchError((e) {
        if (e is MatchCommandNotification) {
          completer.complete(_memory);
        } else {
          completer.completeError(e);
        }
      });
    }
    loop();
    return completer.future;
  }
}
