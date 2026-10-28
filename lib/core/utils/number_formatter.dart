/// Number and string formatting helpers with Bangla digit support.
/// Reference: AGENT.md Section 8.
abstract final class NumberFormatter {
  static const Map<String, String> _bnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
    '.': '.',
  };

  /// Converts ASCII digits to Bangla digits if useBanglaDigits is true.
  static String formatDigits(String input, {bool useBanglaDigits = false}) {
    if (!useBanglaDigits) return input;
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      buffer.write(_bnDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Formats speed value to string (e.g., "42.5" or "৪২.৫").
  static String formatSpeed(
    double speedKmh, {
    bool useBanglaDigits = false,
    int fractionDigits = 1,
  }) {
    final str = speedKmh.toStringAsFixed(fractionDigits);
    return formatDigits(str, useBanglaDigits: useBanglaDigits);
  }

  /// Formats distance value to string (e.g., "30.4" or "৩০.৪").
  static String formatDistance(
    double meters, {
    bool useBanglaDigits = false,
    int fractionDigits = 1,
  }) {
    final str = meters.toStringAsFixed(fractionDigits);
    return formatDigits(str, useBanglaDigits: useBanglaDigits);
  }

  /// Formats integer count.
  static String formatInt(int value, {bool useBanglaDigits = false}) {
    return formatDigits(value.toString(), useBanglaDigits: useBanglaDigits);
  }
}
