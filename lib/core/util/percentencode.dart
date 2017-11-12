part of hetimacore;

class PercentEncode
{
  ArrayBuilder builder = new ArrayBuilder();

  static final Map<String,int> DECODE_TABLE = {
    "0":0,"1":1,"2":2,"3":3,"4":4,"5":5,"6":6,"7":7,
    "8":8,"9":9,"a":10,"A":10,"b":11,"B":11,"c":12,"C":12,
    "d":13,"D":13,"e":14,"E":14,"f":15,"F":15
   };

  static final Map<int,String> ENCODE_TABLE = {
    0:"0" ,1:"1", 2:"2", 3:"3", 4:"4",
    5:"5", 6:"6", 7:"7", 8:"8", 9:"9",
    10:"A", 11:"B",12:"C", 13:"D",
    14:"E", 15:"F"
   };

  static PercentEncode _sencoder = new PercentEncode();
  static List<int> decode (String message) {
    return _sencoder.decodeWork(message);
  }

  static String encode(List<int> target) {
    return _sencoder.encodeWork(target);
  }

  List<int> decodeWork(String message) {
    builder.clear();
    List<int> target = convert.UTF8.encode(message);
    int count = target.length;
    for(int i=0;i<count;i++) {
      if(message[i] == '%') {
        int f = 0xFF&DECODE_TABLE[message[++i]];
        int e = 0xFF&DECODE_TABLE[message[++i]];
        int r = (f<<4)|e;
        builder.appendByte(r);
      } else {
        builder.appendString(message[i]);
      }
    }
    return builder.toList();
  }

  String encodeWork(List<int> target) {
    builder.clear();
    int count = target.length;
    for(int i=0;i<count;i++) {
      if(45== target[i]||46==target[i]||(48<=target[i]&&target[i]<=57)||
        (65<=target[i]&&target[i]<=90) ||target[i]==95|| (97<=target[i]&&target[i]<=122)||target[i]==126){
        builder.appendByte(target[i]);
      } else {
        int f = ((0xf0&target[i])>>4);
        int e = ((0x0f&target[i]));
        builder.appendString("%"+ENCODE_TABLE[f] + ENCODE_TABLE[e]);
      }
    }
    return builder.toText();
  }

}
