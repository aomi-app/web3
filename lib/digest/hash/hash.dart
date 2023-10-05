library digest;

import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

Uint8List sha256(Uint8List input) {
  final Digest sha256Digest = Digest("SHA-256");
  return sha256Digest.process(input);
}
