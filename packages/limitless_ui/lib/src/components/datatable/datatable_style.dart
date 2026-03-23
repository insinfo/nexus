/// Built-in text formatting options for datatable columns.
enum DatatableFormat {
  date,
  dateTime,
  dateTimeShort,
  text,
  bool,
  boolHighlightedBadge,
}

/// CSS-style helper object for datatable rendering.
class DatatableStyle {
  String? backgroundColor;
  String? fontColor;
  String? display;
  String? padding;
  String? fontSize;
  String? fontWeight;
  String? lineHeight;
  String? textAlign;
  String? whiteSpace;
  String? verticalAlign;
  String? borderRadius;
  String? border;

  DatatableStyle({
    this.backgroundColor,
    this.fontColor,
    this.display,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.lineHeight,
    this.textAlign,
    this.whiteSpace,
    this.verticalAlign,
    this.borderRadius,
    this.border,
  });

  /// Factory for a badge-like style.
  DatatableStyle.badge() {
    fontColor = '#fff';
    backgroundColor = '#f44336';
    display = 'inline-block';
    padding = '0.3125rem 0.375rem';
    fontSize = '75%';
    fontWeight = '500';
    lineHeight = '1';
    textAlign = 'center';
    whiteSpace = 'nowrap';
    verticalAlign = 'baseline';
    borderRadius = '0.125rem';
  }

  /// Builds an inline CSS string from the configured style values.
  String get styleCss {
    final css = StringBuffer();
    if (fontColor != null) {
      css.write('color: $fontColor;');
    }
    if (backgroundColor != null) {
      css.write('background-color: $backgroundColor;');
    }
    if (padding != null) {
      css.write('padding: $padding;');
    }
    if (fontSize != null) {
      css.write('font-size: $fontSize;');
    }
    if (textAlign != null) {
      css.write('text-align: $textAlign;');
    }
    if (whiteSpace != null) {
      css.write('white-space: $whiteSpace;');
    }
    if (verticalAlign != null) {
      css.write('vertical-align: $verticalAlign;');
    }
    if (borderRadius != null) {
      css.write('border-radius: $borderRadius;');
    }
    if (border != null) {
      css.write('border: $border;');
    }
    return css.toString();
  }
}
