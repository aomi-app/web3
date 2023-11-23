import 'package:web3/random/random.dart';
import 'package:web3/bip/39/mnemonic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';

void main() {
  test('mnemonic', () {
    var entropy = randomBytes(16);

    var mnemonic = Mnemonic.fromEntropy(entropy);
    var mnemonic1 = Mnemonic.fromPhrase("work breeze deal guitar order width jaguar appear day chalk matter double");

    var seed = mnemonic.computeSeed();
    var seed1 = mnemonic1.computeSeed();
    print(mnemonic.phrase);
    print(mnemonic1.phrase);
    // final seed = mnemonicToSeed(mnemonic);
    // print(HEX.encode(seed));
  });
}
