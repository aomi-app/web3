import 'package:web3/random/random.dart';
import 'package:web3/bip/39/mnemonic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';

void main() {
  test('mnemonic', () {
    var entropy = randomBytes(16);

    var mnemonic = Mnemonic.fromEntropy(entropy);
    // var mnemonic = Mnemonic.fromPhrase("analyst stool fox supply jelly memory spread win mother replace nice miss fashion upper vacuum plastic inherit flight argue risk hill miss clog shuffle");
    print(mnemonic.phrase);
    // final seed = mnemonicToSeed(mnemonic);
    // print(HEX.encode(seed));
  });
}
