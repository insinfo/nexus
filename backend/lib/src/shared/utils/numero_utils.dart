class NumeroUtils {
  static double lerDouble(dynamic valor, {double fallback = 0}) {
    if (valor is num) {
      return valor.toDouble();
    }
    return double.tryParse(valor?.toString() ?? '') ?? fallback;
  }
}
