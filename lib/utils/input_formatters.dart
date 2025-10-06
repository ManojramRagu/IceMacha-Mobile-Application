import 'package:flutter/services.dart';

class Formatters {
  static final TextInputFormatter digitsOnly =
      FilteringTextInputFormatter.digitsOnly;

  static TextInputFormatter maxLength(int n) =>
      LengthLimitingTextInputFormatter(n);

  static List<TextInputFormatter> cardNumberGrouped() => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(23),
    _CardNumberFormatter(),
  ];

  static List<TextInputFormatter> expiryMmYy() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
    LengthLimitingTextInputFormatter(5),
    _ExpiryMmYyFormatter(),
  ];

  static List<TextInputFormatter> phoneLoose() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
    LengthLimitingTextInputFormatter(20),
  ];
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\s+'), '');
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(raw[i]);
    }
    final formatted = buf.toString();

    final base = formatted.length.clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: base),
      composing: TextRange.empty,
    );
  }
}

class _ExpiryMmYyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue nv,
  ) {
    var t = nv.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (t.length > 4) t = t.substring(0, 4);
    String out;
    if (t.length <= 2) {
      out = t;
    } else {
      out = '${t.substring(0, 2)}/${t.substring(2)}';
    }
    final offset = out.length;
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
