library digest;

import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';

final ZERO32 = Uint8List.fromList(List.generate(32, (index) => 0));

final EC_GROUP_ORDER = HEX.decode("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141");

final secp256k1 = ECCurve_secp256k1();
final n = secp256k1.n;
final G = secp256k1.G;

Uint8List? pointFromScalar(Uint8List d, bool compressed) {
  if (!isPrivate(d)) throw ArgumentError('Expected Private');
  BigInt dd = fromBuffer(d);
  ECPoint pp = (G * dd) as ECPoint;
  if (pp.isInfinity) return null;
  return getEncoded(pp, compressed);
}

Uint8List? privateAdd(Uint8List d, Uint8List tweak) {
  if (!isPrivate(d)) throw ArgumentError('Expected Private');
  if (!isOrderScalar(tweak)) throw ArgumentError( 'Expected Tweak');
  BigInt dd = fromBuffer(d);
  BigInt tt = fromBuffer(tweak);
  Uint8List dt = toBuffer((dd + tt) % n);

  if (dt.length < 32) {
    Uint8List padLeadingZero = Uint8List(32 - dt.length);
    dt = Uint8List.fromList(padLeadingZero + dt);
  }

  if (!isPrivate(dt)) return null;
  return dt;
}

bool isPrivate(Uint8List x) {
  if (!isScalar(x)) return false;
  return _compare(x, ZERO32) > 0 && // > 0
      _compare(x, EC_GROUP_ORDER as Uint8List) < 0; // < G
}

bool isScalar(Uint8List x) {
  return x.length == 32;
}

bool isOrderScalar(x) {
  if (!isScalar(x)) return false;
  return _compare(x, EC_GROUP_ORDER as Uint8List) < 0; // < G
}


BigInt fromBuffer(Uint8List d) {
  return _decodeBigInt(d);
}

Uint8List toBuffer(BigInt d) {
  return _encodeBigInt(d);
}

Uint8List getEncoded(ECPoint? P, compressed) {
  return P!.getEncoded(compressed);
}

var _byteMask = BigInt.from(0xff);
final negativeFlag = BigInt.from(0x80);

/// Encode a BigInt into bytes using big-endian encoding.
Uint8List _encodeBigInt(BigInt number) {
  int needsPaddingByte;
  int rawSize;

  if (number > BigInt.zero) {
    rawSize = (number.bitLength + 7) >> 3;
    needsPaddingByte = ((number >> (rawSize - 1) * 8) & negativeFlag) == negativeFlag ? 1 : 0;

    if (rawSize < 32) {
      needsPaddingByte = 1;
    }
  } else {
    needsPaddingByte = 0;
    rawSize = (number.bitLength + 8) >> 3;
  }

  final size = rawSize < 32 ? rawSize + needsPaddingByte : rawSize;
  var result = Uint8List(size);
  for (int i = 0; i < size; i++) {
    result[size - i - 1] = (number & _byteMask).toInt();
    number = number >> 8;
  }
  return result;
}

/// Decode a BigInt from bytes in big-endian encoding.
BigInt _decodeBigInt(List<int> bytes) {
  BigInt result = BigInt.from(0);
  for (int i = 0; i < bytes.length; i++) {
    result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
  }
  return result;
}

int _compare(Uint8List a, Uint8List b) {
  BigInt aa = fromBuffer(a);
  BigInt bb = fromBuffer(b);
  if (aa == bb) return 0;
  if (aa > bb) return 1;
  return -1;
}
