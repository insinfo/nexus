//C:\MyDartProjects\new_sali\frontend\lib\src\shared\components\date_range_picker\date_range_picker_component.dart
import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'package:popper/popper.dart';

class CalendarCell {
  final DateTime date;
  final bool isCurrentMonth;

  const CalendarCell({
    required this.date,
    required this.isCurrentMonth,
  });
}

@Component(
  selector: 'date-range-picker',
  styleUrls: ['date_range_picker_component.css'],
  templateUrl: 'date_range_picker_component.html',
  directives: [
    coreDirectives,
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class DateRangePickerComponent implements OnDestroy {
  final ChangeDetectorRef _changeDetectorRef;
  PopperAnchoredOverlay? _overlay;
  StreamSubscription<html.Event>? _documentClickSubscription;
  StreamSubscription<html.KeyboardEvent>? _documentKeySubscription;

  static const List<String> _weekdayLabelsPt = <String>[
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
  ];

  static const List<String> _monthLabelsPt = <String>[
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final _inicioChangeController = StreamController<DateTime?>.broadcast();
  final _fimChangeController = StreamController<DateTime?>.broadcast();

  @Input()
  DateTime? inicio;

  @Input()
  DateTime? fim;

  @Input()
  DateTime? minDate;

  @Input()
  DateTime? maxDate;

  @Input()
  String placeholder = 'Selecione o periodo';

  @Input()
  String locale = 'pt_BR';

  @Output()
  Stream<DateTime?> get inicioChange => _inicioChangeController.stream;

  @Output()
  Stream<DateTime?> get fimChange => _fimChangeController.stream;

  @ViewChild('triggerElement')
  html.Element? triggerElement;

  @ViewChild('panelElement')
  html.Element? panelElement;

  DateTime? draftInicio;
  DateTime? draftFim;
  DateTime? hoverDateValue;
  DateTime leftMonth = _monthStart(DateTime.now());
  DateTime rightMonth = _monthStart(DateTime.now().add(Duration(days: 31)));
  late List<List<CalendarCell>> leftCalendar;
  late List<List<CalendarCell>> rightCalendar;
  bool isOpen = false;
  bool isSelectingEnd = false;

  DateRangePickerComponent(this._changeDetectorRef) {
    _refreshCalendars();
  }

  List<String> get weekdayLabels => _weekdayLabelsPt;

  bool get canApply => draftInicio != null || draftFim != null;

  String get displayValue => _formatRange(inicio, fim);

  String get draftDisplayValue => _formatRange(draftInicio, draftFim);

  void toggleOpen() {
    if (isOpen) {
      close();
      return;
    }
    _open();
  }

  void _open() {
    _ensureOverlay();
    draftInicio = _normalize(inicio);
    draftFim = _normalize(fim);
    hoverDateValue = null;
    isSelectingEnd = draftInicio != null && draftFim == null;
    _syncVisibleMonths();
    isOpen = true;
    _overlay?.startAutoUpdate();
    _overlay?.update();
    _bindDocumentListeners();
    _markForCheck();
  }

  void prevMonth() {
    _setVisibleMonths(DateTime(leftMonth.year, leftMonth.month - 1, 1));
    _markForCheck();
  }

  void nextMonth() {
    _setVisibleMonths(DateTime(leftMonth.year, leftMonth.month + 1, 1));
    _markForCheck();
  }

  void selectDay(DateTime date) {
    final normalized = _normalize(date);
    if (normalized == null || isDisabled(normalized)) {
      return;
    }

    if (draftInicio == null || draftFim != null || !isSelectingEnd) {
      draftInicio = normalized;
      draftFim = null;
      hoverDateValue = null;
      isSelectingEnd = true;
      _markForCheck();
      return;
    }

    if (normalized.isBefore(draftInicio!)) {
      draftInicio = normalized;
      draftFim = null;
      hoverDateValue = null;
      isSelectingEnd = true;
      _markForCheck();
      return;
    }

    draftFim = normalized;
    hoverDateValue = null;
    isSelectingEnd = false;
    _markForCheck();
  }

  void hoverDay(DateTime date) {
    if (!isSelectingEnd || draftInicio == null || draftFim != null) {
      return;
    }

    final normalized = _normalize(date);
    if (normalized == null || normalized.isBefore(draftInicio!)) {
      hoverDateValue = null;
      _markForCheck();
      return;
    }

    hoverDateValue = normalized;
    _markForCheck();
  }

  void apply() {
    var inicioAplicado = _normalize(draftInicio);
    var fimAplicado = _normalize(draftFim);

    if (inicioAplicado != null &&
        fimAplicado != null &&
        fimAplicado.isBefore(inicioAplicado)) {
      final temp = inicioAplicado;
      inicioAplicado = fimAplicado;
      fimAplicado = temp;
    }

    inicio = inicioAplicado;
    fim = fimAplicado;
    _inicioChangeController.add(inicioAplicado);
    _fimChangeController.add(fimAplicado);
    close();
    _markForCheck();
  }

  void clear() {
    draftInicio = null;
    draftFim = null;
    hoverDateValue = null;
    isSelectingEnd = false;
    inicio = null;
    fim = null;
    _inicioChangeController.add(null);
    _fimChangeController.add(null);
    close();
    _markForCheck();
  }

  void close() {
    _unbindDocumentListeners();
    _overlay?.stopAutoUpdate();
    isOpen = false;
    hoverDateValue = null;
    isSelectingEnd = false;
    _markForCheck();
  }

  void handleOutsideClick() {
    if (!isOpen) {
      return;
    }
    close();
  }

  void _ensureOverlay() {
    final reference = triggerElement;
    final floating = panelElement;

    if (_overlay != null || reference == null || floating == null) {
      return;
    }

    _overlay = PopperAnchoredOverlay.attach(
      referenceElement: reference,
      floatingElement: floating,
      portalOptions: const PopperPortalOptions(
        hostClassName: 'DateRangePickerComponent',
        hostZIndex: '1085',
        floatingZIndex: '1086',
      ),
      popperOptions: const PopperOptions(
        placement: 'bottom-start',
        fallbackPlacements: <String>[
          'top-start',
          'bottom-end',
          'top-end',
        ],
        strategy: PopperStrategy.fixed,
        padding: PopperInsets.all(8),
        offset: PopperOffset(mainAxis: 8),
      ),
    );
  }

  void _bindDocumentListeners() {
    _documentClickSubscription ??= html.document.onClick.listen((event) {
      if (!isOpen) {
        return;
      }

      final target = event.target;
      if (target is! html.Node) {
        close();
        _markForCheck();
        return;
      }

      final clickedTrigger = triggerElement?.contains(target) ?? false;
      final clickedPanel = panelElement?.contains(target) ?? false;

      if (!clickedTrigger && !clickedPanel) {
        close();
        _markForCheck();
      }
    });

    _documentKeySubscription ??= html.document.onKeyDown.listen((event) {
      if (isOpen && event.key == 'Escape') {
        event.preventDefault();
        close();
        _markForCheck();
      }
    });
  }

  void _unbindDocumentListeners() {
    _documentClickSubscription?.cancel();
    _documentClickSubscription = null;
    _documentKeySubscription?.cancel();
    _documentKeySubscription = null;
  }

  bool isDisabled(DateTime date) {
    final normalized = _normalize(date);
    if (normalized == null) {
      return true;
    }

    if (minDate != null && normalized.isBefore(_normalize(minDate!)!)) {
      return true;
    }

    if (maxDate != null && normalized.isAfter(_normalize(maxDate!)!)) {
      return true;
    }

    return false;
  }

  bool isToday(DateTime date) => _isSameDate(date, DateTime.now());

  bool isStartDate(DateTime date) => _isSameDate(date, draftInicio);

  bool isEndDate(DateTime date) => _isSameDate(date, draftFim);

  bool isInRange(DateTime date) {
    if (draftInicio == null) {
      return false;
    }

    final normalized = _normalize(date)!;
    final rangeEnd = draftFim ?? hoverDateValue;
    if (rangeEnd == null || rangeEnd.isBefore(draftInicio!)) {
      return false;
    }

    if (_isSameDate(normalized, draftInicio) ||
        _isSameDate(normalized, draftFim)) {
      return false;
    }

    return normalized.isAfter(draftInicio!) && normalized.isBefore(rangeEnd);
  }

  String monthLabel(DateTime month) {
    final label = _monthLabelsPt[month.month - 1];
    return '$label ${month.year}';
  }

  List<List<CalendarCell>> _buildCalendar(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday % 7;
    var cursor = firstDay.subtract(Duration(days: startOffset));
    final weeks = <List<CalendarCell>>[];

    for (var row = 0; row < 6; row++) {
      final week = <CalendarCell>[];
      for (var col = 0; col < 7; col++) {
        week.add(CalendarCell(
          date: cursor,
          isCurrentMonth: cursor.month == month.month,
        ));
        cursor = cursor.add(Duration(days: 1));
      }
      weeks.add(week);
    }

    return weeks;
  }

  void _syncVisibleMonths() {
    final referenceDate = draftInicio ?? draftFim ?? DateTime.now();
    _setVisibleMonths(referenceDate);
  }

  void _setVisibleMonths(DateTime month) {
    leftMonth = _monthStart(month);
    rightMonth = _monthStart(DateTime(leftMonth.year, leftMonth.month + 1, 1));
    _refreshCalendars();
  }

  void _refreshCalendars() {
    leftCalendar = _buildCalendar(leftMonth);
    rightCalendar = _buildCalendar(rightMonth);
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  String _formatRange(DateTime? start, DateTime? end) {
    final startText = _formatDate(start);
    final endText = _formatDate(end);

    if (startText.isEmpty && endText.isEmpty) {
      return '';
    }

    if (startText.isNotEmpty && endText.isNotEmpty) {
      return '$startText - $endText';
    }

    return startText.isNotEmpty ? startText : endText;
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }

    final normalized = _normalize(value)!;
    return '${_twoDigits(normalized.day)}/${_twoDigits(normalized.month)}/${normalized.year}';
  }

  static DateTime _monthStart(DateTime value) =>
      DateTime(value.year, value.month, 1);

  DateTime? _normalize(DateTime? value) {
    if (value == null) {
      return null;
    }
    return DateTime(value.year, value.month, value.day);
  }

  bool _isSameDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return false;
    }

    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _twoDigits(int value) {
    if (value < 10) {
      return '0$value';
    }
    return '$value';
  }

  @override
  void ngOnDestroy() {
    _unbindDocumentListeners();
    _overlay?.dispose();
    _inicioChangeController.close();
    _fimChangeController.close();
  }
}
