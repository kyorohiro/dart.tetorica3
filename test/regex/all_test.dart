// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dart_hetimaregex.test;

import 'test_hetimaregex_vm_00.dart' as hetimaregex_vm_00;
import 'test_hetimaregex_parser_00.dart' as hetimaregex_parser_00;
import 'test_hetimaregex_lexer_00.dart' as hetimaregex_lexer_00;
import 'test_hetimaregex_ext_00.dart' as hetimaregex_ext_00;

void main() {
  hetimaregex_vm_00.script00();
  hetimaregex_lexer_00.script00();
  hetimaregex_parser_00.script00();
  hetimaregex_ext_00.script00();
}
