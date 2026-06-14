class Formatters {
  const Formatters._();

  static String currency(num value) {
    final hasDecimals = value % 1 != 0;
    final fixedValue = hasDecimals ? value.toStringAsFixed(2) : value.round().toString();
    final parts = fixedValue.split('.');
    final raw = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final reversedIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    final decimals = hasDecimals ? '.${parts.last}' : '';
    return 'S/ ${buffer.toString()}$decimals';
  }
}
