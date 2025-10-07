import 'package:flutter/material.dart';

typedef StrValidator = String? Function(String?);

class Validators {
  /// Runs validators in order and returns the first error.
  static StrValidator compose(List<StrValidator> validators) {
    return (value) {
      for (final v in validators) {
        final res = v(value);
        if (res != null) return res;
      }
      return null;
    };
  }

  // Required & Length

  /// Required field
  static StrValidator required([String label = 'This field']) {
    return (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null;
  }

  /// Minimum length
  static StrValidator minLength(int n, {String? label}) {
    return (v) {
      final t = v?.trim() ?? '';
      return t.length < n
          ? '${label ?? "This field"} must be at least $n characters'
          : null;
    };
  }

  /// Maximum length
  static StrValidator maxLength(int n, {String? label}) {
    return (v) {
      final t = v?.trim() ?? '';
      return t.length > n
          ? '${label ?? "This field"} must be at most $n characters'
          : null;
    };
  }

  // Common Field Validations

  /// Email format
  static StrValidator email([String label = 'Email']) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return (v) {
      final t = v?.trim() ?? '';
      if (t.isEmpty) return '$label is required';
      return re.hasMatch(t) ? null : 'Enter a valid $label';
    };
  }

  /// Generic phone validation
  static StrValidator phone([String label = 'Phone']) {
    final allowed = RegExp(r'^[0-9+\-()\s]+$');
    return (v) {
      final t = v?.trim() ?? '';
      if (t.isEmpty) return '$label is required';
      if (!allowed.hasMatch(t)) return 'Enter a valid $label';
      final digitsOnly = t.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        return 'Enter a valid $label (7–15 digits)';
      }
      return null;
    };
  }

  /// Integer range
  static StrValidator intRange(int min, int max, {String? label}) {
    return (v) {
      final t = v?.trim() ?? '';
      if (t.isEmpty) return '${label ?? "This field"} is required';
      final n = int.tryParse(t);
      if (n == null) return '${label ?? "This field"} must be a number';
      if (n < min || n > max)
        return '${label ?? "This field"} must be between $min and $max';
      return null;
    };
  }

  /// Match another field
  static StrValidator match(
    TextEditingController other, {
    String message = 'Values do not match',
  }) {
    return (v) => (v ?? '') == other.text ? null : message;
  }

  /// Regex validator with a custom message.
  static StrValidator regex(RegExp re, {String message = 'Invalid value'}) {
    return (v) {
      final t = v?.trim() ?? '';
      return re.hasMatch(t) ? null : message;
    };
  }

  // Card Validations

  // Card number Validation
  static StrValidator cardNumberLuhn([String label = 'Card number']) {
    return (v) {
      final digits = (v ?? '').replaceAll(RegExp(r'\s+'), '');
      if (digits.isEmpty) return '$label is required';
      // Accept common lengths (12–19)
      if (!RegExp(r'^\d{12,19}$').hasMatch(digits)) {
        return 'Enter a valid $label';
      }
      if (!_luhnOk(digits)) return 'Enter a valid $label';
      return null;
    };
  }

  // CVV
  static StrValidator cvv([String label = 'CVV']) {
    final re = RegExp(r'^\d{3}$');
    return (v) {
      final t = v?.trim() ?? '';
      if (t.isEmpty) return '$label is required';
      return re.hasMatch(t) ? null : 'Enter a valid $label (3 digits)';
    };
  }

  // Expiry (MM/YY)
  // Checks format and ensures not in the past.
  static StrValidator expiryMmYy([String label = 'Expiry']) {
    final re = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    return (v) {
      final t = v?.trim() ?? '';
      if (t.isEmpty) return '$label is required';
      if (!re.hasMatch(t)) return 'Enter $label as MM/YY';

      final parts = t.split('/');
      final mm = int.parse(parts[0]);
      final yy = int.parse(parts[1]);
      final year = 2000 + yy;

      // Last moment of the expiry month
      final firstOfNext = (mm == 12)
          ? DateTime(year + 1, 1, 1)
          : DateTime(year, mm + 1, 1);
      final lastMoment = firstOfNext.subtract(const Duration(seconds: 1));
      final now = DateTime.now();

      if (lastMoment.isBefore(DateTime(now.year, now.month, now.day))) {
        return '$label is in the past';
      }
      return null;
    };
  }

  static bool _luhnOk(String digits) {
    var sum = 0;
    var even = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = digits.codeUnitAt(i) - 48;
      if (even) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      even = !even;
    }
    return sum % 10 == 0;
  }
}
