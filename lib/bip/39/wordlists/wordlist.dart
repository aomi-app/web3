library bip39;

/// A Wordlist represents a collection of language-specific
/// words used to encode and decode BIP-39 encoded data
/// by mapping words to 11-bit values and vice versa.
abstract class Wordlist {
  final String locale;

  /// Creates a new Wordlist instance.
  ///
  /// Sub-classes MUST call this if they provide their own constructor,
  /// passing in the locale string of the language.
  ///
  /// Generally there is no need to create instances of a Wordlist,
  /// since each language-specific Wordlist creates an instance and
  /// there is no state kept internally, so they are safe to share.
  Wordlist({required this.locale});

  /// Sub-classes may override this to provide a language-specific
  /// method for splitting [phrase] into individual words.
  ///
  /// By default, [phrase] is split using any sequences of
  /// white-space as defined by regular expressions (i.e. /\s+/).
  List<String> split(String phrase) {
    return phrase.toLowerCase().split(RegExp(r'\s+'));
  }

  /// Sub-classes may override this to provide a language-specific
  /// method for joining [words] into a phrase.
  ///
  /// By default, [words] are joined by a single space.
  String join(List<String> words) {
    return words.join(' ');
  }

  /// Maps an 11-bit value into its corresponding word in the list.
  ///
  /// Sub-classes MUST override this.
  String getWord(int index);

  /// Maps a word to its corresponding 11-bit value.
  ///
  /// Sub-classes MUST override this.
  int getWordIndex(String word);
}
