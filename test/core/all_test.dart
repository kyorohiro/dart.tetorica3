import './arraybuilder_test.dart' as t_arraybuilder;
import './arraybuilder_z99_test.dart' as t_arrraybuilder_z99;
import './easyparser_test.dart' as t_easyparser;
import './hetimacore_dartio_test.dart' as t_coredartio;
import './percentencode_test.dart' as t_persent;

import './bencode_test.dart' as bencode_test;
import './bencode_test2.dart' as bencode_test2;
import './pieceinfo_test.dart' as pieceinfo_test;
void main() {
  t_arraybuilder.main();

  t_arrraybuilder_z99.main();

  t_easyparser.main();

  t_coredartio.main();
  t_persent.main();

  //
  bencode_test.main();
  bencode_test2.main();

  //
  pieceinfo_test.main();
}
