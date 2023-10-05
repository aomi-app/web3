library digest;

import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/macs/hmac.dart';

Uint8List hmacSHA512(Uint8List key, Uint8List data) {
  final tmp = HMac(SHA512Digest(), 128)..init(KeyParameter(key));
  return tmp.process(data);
}
