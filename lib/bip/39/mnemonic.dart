library bip39;

import 'dart:convert';
import 'dart:typed_data';
import 'dart:core';
import 'dart:math';
import 'package:hex/hex.dart';
import 'package:pointycastle/pointycastle.dart';

import '../../digest/hash/hash.dart';
import './wordlists/lang_en.dart';
import './wordlists/wordlist.dart';

/// 助记词转换为熵
Uint8List mnemonicToEntropy(String mnemonic, [Wordlist? wl]) {
  final wordlist = wl ?? LangEn.wordlist;

  final List<String> words = wordlist.split(mnemonic);

  if (!((words.length % 3) == 0 && words.length >= 12 && words.length <= 24)) {
    throw ArgumentError('Invalid mnemonic');
  }

  final entropyLength = (11 * words.length / 8).ceil();
  final entropy = Uint8List(entropyLength);

  var offset = 0;
  for (var i = 0; i < words.length; i++) {
    /// TODO words[i].normalize(NormalizationForm.nfkd) 未实现
    final index = wordlist.getWordIndex(words[i]);
    if (index == -1) {
      throw ArgumentError('Invalid mnemonic');
    }

    for (var bit = 0; bit < 11; bit++) {
      if ((index & (1 << (10 - bit))) != 0) {
        entropy[offset >> 3] |= (1 << (7 - (offset % 8)));
      }
      offset++;
    }
  }

  final entropyBits = 32 * words.length / 3;

  final checksumBits = words.length / 3;
  final checksumMask = getUpperMask(checksumBits.toInt());


  final checksum = sha256(entropy.sublist(0, entropyBits ~/ 8))[0] & checksumMask;

  if (checksum != (entropy[entropy.length - 1] & checksumMask)) {
    throw ArgumentError('Invalid checksum');
  }

  return Uint8List.view(entropy.buffer, 0, entropyBits ~/ 8);
}

/// 熵转换为助记词
String entropyToMnemonic(Uint8List entropy, [Wordlist? wl]) {
  if (entropy.length % 4 != 0 || entropy.length < 16 || entropy.length > 32) {
    throw ArgumentError('invalid entropy');
  }
  final wordlist  = wl ?? LangEn.wordlist;

  final indices = <int>[0];
  int remainingBits = 11;

  for (int i = 0; i < entropy.length; i++) {
    if (remainingBits > 8) {
      indices[indices.length - 1] <<= 8;
      indices[indices.length - 1] |= entropy[i];
      remainingBits -= 8;
    } else {
      indices[indices.length - 1] <<= remainingBits;
      indices[indices.length - 1] |= entropy[i] >> (8 - remainingBits);
      indices.add(entropy[i] & getLowerMask(8 - remainingBits));
      remainingBits += 3;
    }
  }

  final checksumBits = entropy.length ~/ 4;
  final checksum = sha256(entropy)[0] & getUpperMask(checksumBits);

  indices[indices.length - 1] <<= checksumBits;
  indices[indices.length - 1] |= checksum >> (8 - checksumBits);

  return wordlist.join(indices.map((index) => wordlist.getWord(index)).toList());
}

// Returns a byte with the LSB bits set
int getLowerMask(int bits) {
  // return (1 << bits) - 1;
  return ((1 << bits) - 1) & 0xff;
}

// Returns a byte with the MSB bits set
int getUpperMask(int bits) {
  // return ((1 << bits) - 1) << (8 - bits);
  return ((1 << bits) - 1) << (8 - bits) & 0xff;

}

class Mnemonic {
  final String phrase;
  final String password;
  final Wordlist wordlist;
  final Uint8List entropy;

  Mnemonic._({
    required this.phrase,
    required this.password,
    required this.wordlist,
    required this.entropy,
  });

  /// Creates a new Mnemonic for the %%phrase%%.
  /// The default %%password%% is the empty string and the default wordlist is the English wordlists.
  factory Mnemonic.fromPhrase(String phrase, [String? password, Wordlist? wordlist]) {
    final wl = wordlist ?? LangEn.wordlist;
    final entropy = mnemonicToEntropy(phrase, wl);
    phrase = entropyToMnemonic(entropy, wl);
    return Mnemonic._(
      phrase: phrase,
      password: password ?? '',
      wordlist: wl,
      entropy: entropy,
    );
  }

  /// Create a new Mnemonic from the %%entropy%%.
  /// The default %%password%% is the empty string and the default wordlist is the English wordlists.
  factory Mnemonic.fromEntropy(Uint8List entropy, [String? password, Wordlist? wordlist]) {
    final wl = wordlist ?? LangEn.wordlist;
    final phrase = entropyToMnemonic(entropy, wl);
    return Mnemonic._(
      entropy: entropy,
      password: password ?? '',
      wordlist: wl,
      phrase: phrase,
    );
  }

  /// Returns the phrase for %%mnemonic%%.
  static String entropyToPhrase(Uint8List entropy, [Wordlist? wordlist]) {
    return entropyToMnemonic(entropy, wordlist ?? LangEn.wordlist);
  }

  /// Returns the entropy for %%phrase%%.
  static Uint8List phraseToEntropy(String phrase, [Wordlist? wordlist]) {
    return mnemonicToEntropy(phrase, wordlist);
  }

  ///  Returns true if %%phrase%% is a valid [[link-bip-39]] phrase.
  ///
  ///  This checks all the provided words belong to the %%wordlist%%,
  ///  that the length is valid and the checksum is correct.
  static bool isValidMnemonic(String phrase, [Wordlist? wordlist]) {
    try {
      mnemonicToEntropy(phrase, wordlist);
      return true;
    } catch (error) {
      return false;
    }
  }

  Uint8List computeSeed() {
    final salt = Uint8List.fromList(utf8.encode('mnemonic$password'));
    final keyDerivator = KeyDerivator('SHA-512/HMAC/PBKDF2')
      ..init(Pbkdf2Parameters(
        salt,
        2048,
        64,
      ));
    return keyDerivator.process(Uint8List.fromList(utf8.encode(phrase)));
  }

  String computeSeedHex() {
    return "0x${HEX.encode(computeSeed())}";
  }
}
