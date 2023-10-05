library digest;

import 'dart:convert';
import 'dart:typed_data';

import 'keccak.dart';

///  A simple hashing function which operates on UTF-8 strings to
///  compute an 32-byte identifier.
///
///  This simply computes the [UTF-8 bytes](toUtf8Bytes) and computes
///  the [[keccak256]].
///
///  @example:
///    id("hello world")
///    //_result:
String id(String value) {
  final Uint8List utf8Bytes = Uint8List.fromList(utf8.encode(value));
  return keccak256Hex(utf8Bytes);
}
