import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:web3/bip/32/key_derivation.dart';
import 'package:web3/random/random.dart';
import 'package:web3/bip/39/mnemonic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';

void main() {
  test('key derivation', () {

    final prk = BIP32.fromBase58("xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi");
    final sub0 = prk.deriveHardened(0);
    final sub = BIP32.fromBase58("xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7");

    // final mnemonic = Mnemonic.fromPhrase("analyst stool fox supply jelly memory spread win mother replace nice miss fashion upper vacuum plastic inherit flight argue risk hill miss clog shuffle");

    final subKey0 = childKeyDerivationHardened(prk.privateKey!, Uint8List.fromList([0]), 0);
    print(base64Encode(subKey0));

    // final seed = mnemonicToSeed(mnemonic);
    // print(HEX.encode(seed));
  });
}
