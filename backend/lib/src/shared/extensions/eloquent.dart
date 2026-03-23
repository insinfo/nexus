import 'package:eloquent/eloquent.dart';

/// QueryBuilder extension
extension OrderDir on QueryBuilder {
  static const asc = 'asc';
  static const desc = 'desc';
}

extension Operator on QueryBuilder {
  static const equal = '=';
  static const notEqual = '!=';
  static const isNotNull = 'is not null';
}
