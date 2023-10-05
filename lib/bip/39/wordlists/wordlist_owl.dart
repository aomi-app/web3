library bip39;


import '../../../digest/hash/id.dart';
import 'decode_owl.dart';
import 'wordlist.dart';

///  An OWL format Wordlist is an encoding method that exploits
///  the general locality of alphabetically sorted words to
///  achieve a simple but effective means of compression.
///
///  This class is generally not useful to most developers as
///  it is used mainly internally to keep Wordlists for languages
///  based on ASCII-7 small.
///
///  If necessary, there are tools within the ``generation/`` folder
///  to create the necessary data.
class WordlistOwl extends Wordlist {
  final String _data;
  final String _checksum;
  List<String>? _words;

  WordlistOwl(String locale, String data, String checksum)
      : _data = data,
        _checksum = checksum,
        super(locale: locale);

  ///  Decode all the words for the wordlist.
  List<String> _decodeWords() {
    return decodeOwl(_data);
  }

  List<String> _loadWords() {
    if (_words == null) {
      final words = _decodeWords();

      final checksum = id('${words.join('\n')}\n');
      if (checksum != _checksum) {
        throw Exception('BIP39 Wordlist for $locale FAILED');
      }

      _words = words;
    }
    return _words!;
  }

  @override
  String getWord(int index) {
    final words = _loadWords();
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    throw ArgumentError('invalid word index: $index');
  }

  @override
  int getWordIndex(String word) {
    return _loadWords().indexOf(word);
  }
}
