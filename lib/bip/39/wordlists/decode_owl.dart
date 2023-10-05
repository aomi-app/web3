library bip39;

const subsChrs = r" !#$%&'()*+,-./<=>?@[]^_`{|}~";
final wordPattern = RegExp(r'^[a-z]*$', caseSensitive: false);

List<String> unfold(List<String> words, String sep) {
  int initial = 97;
  return words.fold([], (List<String> accum, String word) {
    if (word == sep) {
      initial++;
    } else if (wordPattern.hasMatch(word)) {
      accum.add(String.fromCharCode(initial) + word);
    } else {
      initial = 97;
      accum.add(word);
    }
    return accum;
  });
}

List<String> decode(String data, String subs) {

  // Replace all the substitutions with their expanded form
  for (int i = subsChrs.length - 1; i >= 0; i--) {
    data = data.split(subsChrs[i]).join(subs.substring(2 * i, 2 * i + 2));
  }

  final List<String> clumps = [];
  final leftover = data.replaceAllMapped(RegExp(r'(:|([0-9])|([A-Z][a-z]*))'), (match) {
    final item = match.group(0);
    final semi = match.group(2);
    final word = match.group(3);

    if (semi != null) {
      for (int i = int.parse(semi); i >= 0; i--) {
        clumps.add(";");
      }
    } else {
      clumps.add(item!.toLowerCase());
    }
    return '';
  });

  if (leftover.isNotEmpty) {
    throw Exception('leftovers: $leftover');
  }

  return unfold(unfold(clumps, ";"), ":");
}

List<String> decodeOwl(String data) {
  assert(data[0] == '0', 'unsupported auwl data');

  return decode(data.substring(1 + 2 * subsChrs.length), data.substring(1, 1 + 2 * subsChrs.length));
}
