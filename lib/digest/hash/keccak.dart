library digest;

import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:pointycastle/digests/keccak.dart';
import 'package:pointycastle/pointycastle.dart';

Uint8List keccak256(Uint8List bytes) {
  final Digest digest = KeccakDigest(256);
  return digest.process(bytes);
}

String keccak256Hex(Uint8List bytes) {
  final hash = keccak256(bytes);
  return "0x${HEX.encode(hash)}";
}
