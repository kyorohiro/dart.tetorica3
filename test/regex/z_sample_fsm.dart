
bool fsm(String target, int currentStatus, Map<Action, int> table, List<int> goal) {
  if (target.length == 0) {
    return goal.contains(currentStatus);
  } else {
    Action expectAction = new Action(currentStatus, target[0]);
    if (table.keys.contains(expectAction)) {
      return fsm(target.substring(1), table[expectAction], table, goal);
    } else {
      return false;
    }
  }
}

class Action extends Object {
  int status;
  String character;
  Action(int status, String character) {
    this.status = status;
    this.character = character;
  }
  int get hashCode => status<<8|character.codeUnitAt(0);
  bool operator ==(Action t) => this.hashCode == t.hashCode;
}

void main() {
  var table = <Action,int> {
    new Action(1, 'a'): 2,
    new Action(1, 'b'): 2,
    new Action(2, 'c'): 3,
    new Action(2, 'd'): 3
  };
  var goal = [2,3];
  print(fsm("a", 1, table, goal));
  print(fsm("b", 1, table, goal));
  print(fsm("ad", 1, table, goal));
  print(fsm("e", 1, table, goal));
}
