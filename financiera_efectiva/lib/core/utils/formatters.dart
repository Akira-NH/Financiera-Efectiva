class Formatters {
  const Formatters._();

  static String currency(num value) {
    final raw = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final reversedIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'S/ ${buffer.toString()}';
  }
}
