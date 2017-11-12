library hetimanet.tmp;
import 'dart:convert' as convert;


class RfcTable {
  static const String HEADER_FIELD_CONTENT_LENGTH = "Content-Length";
  static const String HEADER_FIELD_CONTENT_TYPE = "Content-Type";
  static const String HEADER_FIELD_RANGE = "Range";
  //0x21-0x7E
  static String VCHAR_STRING =
      """!#\$%&'()*+,-./"""
      +"""0123456789:;<=>?"""
      +"""@ABCDEFGHIJKLMNO"""
      +"""PQRSTUVWXYZ[\\]^_"""
      +"""`abcdefghijklmno###"""
      +"""pqrstuvwxyz{|}~""";

  static String TCHAR_STRING =
      """!#\$%&'*+-.^_`|~"""
      + ALPHA_AS_STRING
      + DIGIT_AS_STRING;

  static String OWS_STRING = SP_STRING +"\t";
  static String SP_STRING = " ";
  static String ALPHA_AS_STRING =
       "abcdefghijklmnopqrstuvwxyz"
      +"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static String DIGIT_AS_STRING =
      "0123456789";
  static String HEXDIG_AS_STRING =
      DIGIT_AS_STRING+"ABCDEFabcdef";
  static String RFC3986_UNRESERVED_AS_STRING =
      ALPHA_AS_STRING+DIGIT_AS_STRING+"-._~";
  static String RFC3986_RESERVED_AS_STRING =
      GEM_DELIMS_AS_STRING+SUB_DELIMS_AS_STRING+"%";

  static String GEM_DELIMS_AS_STRING = """:/?#[]@""";
  static String SUB_DELIMS_AS_STRING = """!\$&'()*+,;=""";
  static String PCT_ENCODED_AS_STRING = "%"+HEXDIG_AS_STRING;
  static String RFC3986_SUB_DELIMS_AS_STRING = "!\$&'()*+,;=";
  static String RFC3986_PCHAR_AS_STRING = RFC3986_UNRESERVED_AS_STRING+":@"+RFC3986_SUB_DELIMS_AS_STRING+"%";
  static List<int> ALPHA = convert.UTF8.encode(ALPHA_AS_STRING);
  static List<int> DIGIT = convert.UTF8.encode(DIGIT_AS_STRING);
  static List<int> RFC3986_UNRESERVED = convert.UTF8.encode(RFC3986_UNRESERVED_AS_STRING);
  static List<int> RFC3986_RESERVED = convert.UTF8.encode(RFC3986_RESERVED_AS_STRING);
  static List<int> GEM_DELIMS = convert.UTF8.encode(GEM_DELIMS_AS_STRING);
  static List<int> SUB_DELIMS = convert.UTF8.encode(SUB_DELIMS_AS_STRING);
  static List<int> HEXDIG = convert.UTF8.encode(HEXDIG_AS_STRING);
  static List<int> PCT_ENCODED = convert.UTF8.encode(PCT_ENCODED_AS_STRING);
  static List<int> VCHAR = convert.UTF8.encode(VCHAR_STRING);
  static List<int> TCHAR = convert.UTF8.encode(TCHAR_STRING);
  static List<int> OWS = convert.UTF8.encode(OWS_STRING);
  static List<int> SP = convert.UTF8.encode(SP_STRING);

  //  obs-text = %x80-FF
  static List<int> OBS_TEXT = [
                               0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
                               0x8A, 0x8B, 0x8C, 0x8E, 0x8F,
                               0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99,
                               0x9A, 0x9B, 0x9C, 0x9E, 0x9F,
                               0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9,
                               0xAA, 0xAB, 0xAC, 0xAE, 0xAF,
                               0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9,
                               0xBA, 0xBB, 0xBC, 0xBE, 0xBF,
                               0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
                               0xCA, 0xCB, 0xCC, 0xCE, 0xCF,
                               0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9,
                               0xDA, 0xDB, 0xDC, 0xDE, 0xDF,
                               0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9,
                               0xEA, 0xEB, 0xEC, 0xEE, 0xEF,
                               0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9,
                               0xFA, 0xFB, 0xFC, 0xFE, 0xFF,
                               ];
}

class ParseError extends Error {
  ParseError([String mes=""])  {
  }
}
