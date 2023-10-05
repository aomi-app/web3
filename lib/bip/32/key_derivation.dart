library bip32;

import 'dart:typed_data';

import '../../digest/ecurve.dart';
import '../../digest/hash/hmac.dart';

const HIGHEST_BIT = 0x80000000;

const UINT32_MAX = 4294967295; // 2^32 - 1

Uint8List childKeyDerivation(Uint8List masterKey, Uint8List chainCode, int index) {
  if (index > UINT32_MAX || index < 0) throw ArgumentError("Expected UInt32");

  final isHardened = index >= HIGHEST_BIT;
  Uint8List data = Uint8List(37);

  if (isHardened) {
    // if (isNeutered()) {
    //   throw new ArgumentError("Missing private key for hardened child key");
    // }
    data[0] = 0x00;
    data.setRange(1, 33, masterKey);
    data.buffer.asByteData().setUint32(33, index);
  } else {
    final publicKey = pointFromScalar(masterKey, true)!;
    data.setRange(0, 33, publicKey);
    data.buffer.asByteData().setUint32(33, index);
  }
  final I = hmacSHA512(chainCode, data);
  final IL = I.sublist(0, 32);
  final IR = I.sublist(32);
  if (!isPrivate(IL)) {
    return childKeyDerivation(masterKey, chainCode, index + 1);
  }

  final ki = privateAdd(masterKey, IL);
  if (ki == null) {
    return childKeyDerivation(masterKey, chainCode, index + 1);
  }
  return ki;
}

Uint8List childKeyDerivationHardened(Uint8List masterKey, Uint8List chainCode, int index) {
  return childKeyDerivation(masterKey, chainCode, index + HIGHEST_BIT);
}
