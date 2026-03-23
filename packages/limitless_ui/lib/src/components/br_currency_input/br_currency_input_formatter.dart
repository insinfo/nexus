import 'package:intl/intl.dart';

class BrazilianCurrencyInputFormatter {
  BrazilianCurrencyInputFormatter._();

  static final NumberFormat _groupFormat = NumberFormat.decimalPattern('pt_BR');
  static final RegExp _invalidCharacters = RegExp(r'[^0-9,\.]');
  static final RegExp _nonDigits = RegExp(r'[^0-9]');
  static final RegExp _hasDigit = RegExp(r'\d');

  static String sanitizeForEditing(String? rawValue) {
    final raw = rawValue?.trim() ?? '';
    if (raw.isEmpty) {
      return '';
    }

    final stripped = raw.replaceAll(_invalidCharacters, '');
    if (stripped.isEmpty || !_hasDigit.hasMatch(stripped)) {
      return '';
    }

    final lastComma = stripped.lastIndexOf(',');
    final lastDot = stripped.lastIndexOf('.');
    final lastSeparatorIndex = lastComma > lastDot ? lastComma : lastDot;
    final endsWithSeparator = stripped.endsWith(',') || stripped.endsWith('.');

    if (lastSeparatorIndex != -1) {
      final wholeCandidate =
          stripped.substring(0, lastSeparatorIndex).replaceAll(_nonDigits, '');
      final fractionCandidate =
          stripped.substring(lastSeparatorIndex + 1).replaceAll(_nonDigits, '');
      final useSeparatorAsDecimal =
          fractionCandidate.length <= 2 || endsWithSeparator;

      if (useSeparatorAsDecimal) {
        final wholeDigits =
            _normalizeWholeDigits(wholeCandidate, fallbackZero: true);
        final fractionDigits = fractionCandidate.length > 2
            ? fractionCandidate.substring(0, 2)
            : fractionCandidate;

        if (endsWithSeparator && fractionDigits.isEmpty) {
          return '$wholeDigits,';
        }

        if (fractionDigits.isEmpty) {
          return wholeDigits;
        }

        return '$wholeDigits,$fractionDigits';
      }
    }

    return _normalizeWholeDigits(stripped.replaceAll(_nonDigits, ''));
  }

  static int? minorUnitsFromText(String? rawValue) {
    final sanitized = sanitizeForEditing(rawValue);
    if (sanitized.isEmpty) {
      return null;
    }

    final parts = sanitized.split(',');
    final wholePart = parts.first.isEmpty ? '0' : parts.first;
    final fractionPart =
        parts.length > 1 ? parts[1].padRight(2, '0').substring(0, 2) : '00';

    return int.parse(wholePart) * 100 + int.parse(fractionPart);
  }

  static int? minorUnitsFromValue(num? value) {
    if (value == null) {
      return null;
    }
    return minorUnitsFromText(value.toStringAsFixed(2));
  }

  static double? valueFromMinorUnits(int? minorUnits) {
    if (minorUnits == null) {
      return null;
    }
    return minorUnits / 100;
  }

  static String formatForEditing(int? minorUnits) {
    if (minorUnits == null) {
      return '';
    }
    return _format(minorUnits, grouped: false);
  }

  static String formatForDisplay(int? minorUnits) {
    if (minorUnits == null) {
      return '';
    }
    return _format(minorUnits, grouped: true);
  }

  static String _format(int minorUnits, {required bool grouped}) {
    final absMinorUnits = minorUnits.abs();
    final whole = absMinorUnits ~/ 100;
    final cents = absMinorUnits % 100;
    final wholeText = grouped ? _groupFormat.format(whole) : whole.toString();
    final signal = minorUnits < 0 ? '-' : '';

    return '$signal$wholeText,${cents.toString().padLeft(2, '0')}';
  }

  static String _normalizeWholeDigits(
    String digits, {
    bool fallbackZero = false,
  }) {
    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (normalized.isEmpty) {
      return fallbackZero ? '0' : '';
    }
    return normalized;
  }
}
