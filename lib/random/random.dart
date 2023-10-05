library random;

import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

Uint8List randomBytes(int length) {
// 创建一个 FortunaRandom 实例
  final random = FortunaRandom();
  final sGen = Random.secure();
  random.seed(KeyParameter(Uint8List.fromList(List.generate(32, (_) => sGen.nextInt(255)))));
  // 生成随机数
  return random.nextBytes(length);
}
