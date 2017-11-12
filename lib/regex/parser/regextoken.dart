part of hetimaregex;

class RegexToken {
  static const int none = 0;
  static const int character = 1;
  static const int star = 2;
  static const int union = 3;
  static const int lparan = 4;
  static const int rparen = 5;
  static const int eof = 6;

  int value = none;
  int kind = none;
  RegexToken.fromChar(int value, int kind) {
    this.value = value;
    this.kind = kind;
  }
}

