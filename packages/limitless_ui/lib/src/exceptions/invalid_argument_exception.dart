class InvalidArgumentException extends FormatException {
  InvalidArgumentException(Type type, Object? value)
      : super("Invalid argument '$value' for '$type'");
}
