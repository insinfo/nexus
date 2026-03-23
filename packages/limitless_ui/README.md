# limitless_ui

`limitless_ui` is a reusable AngularDart UI package for web applications.

It groups generic components, directives, pipes, and small UI helpers that can
be shared across multiple frontend projects.

## Scope

The package currently includes:

- data entry components such as `br-currency-input`, custom select, custom
  multi-select, and a date range picker
- data presentation components such as the datatable and tree view
- feedback helpers such as loading overlays, notification toasts, dialogs,
  popovers, and toast utilities
- layout/navigation helpers such as dynamic tabs
- shared AngularDart directives and value accessors
- utility pipes and DOM extensions

## Main exports

Import the public barrel:

```dart
import 'package:limitless_ui/limitless_ui.dart';
```

The public API includes exports for:

- `BrazilianCurrencyInputComponent`
- `BrazilianCurrencyInputFormatter`
- `CustomSelectComponent` and `CustomOptionComp`
- `CustomMultiSelectComponent` and `CustomMultiOptionComp`
- `DatatableComponent`, `DatatableCol`, `DatatableRow`, `DatatableSettings`
- `DateRangePickerComponent`
- `TabsComponent`, `LiTabxDirective`, and `LiTabxHeaderDirective`
- `SimpleLoading`
- `NotificationToast` and `NotificationToastService`
- `SimpleDialogComponent`
- `SimplePopover`
- `SimpleToast`
- `SweetAlertPopover` and `SweetAlertSimpleToast`
- `SimpleTreeViewComponent` and `TreeViewNode`
- `ClickOutsideDirective`, `DropdownMenuDirective`,
  `SafeAppendHtmlDirective`, `SafeInnerHtmlDirective`,
  `IndexedNameDirective`, and `limitlessFormDirectives`
- `CustomDatePipe` and `HideStringPipe`

## Local development

Inside this monorepo, add the package as a path dependency:

```yaml
dependencies:
  limitless_ui:
    path: ../packages/limitless_ui
```

When the package is published, this can be replaced with a hosted dependency
from `pub.dev`.

## Quick start

```dart
import 'package:limitless_ui/limitless_ui.dart';

@Component(
  selector: 'demo-page',
  template: '''
    <notification-outlet [service]="notifications"></notification-outlet>

    <br-currency-input
      [(ngModel)]="amountMinorUnits"
      [required]="true">
    </br-currency-input>
  ''',
  directives: [
    coreDirectives,
    formDirectives,
    NotificationToast,
    BrazilianCurrencyInputComponent,
  ],
)
class DemoPage {
  final notifications = NotificationToastService();

  int? amountMinorUnits;

  void save() {
    notifications.notify('Saved successfully.');
  }
}
```

## Currency input

`br-currency-input` stores values as minor units (`int?`), which makes it easy
to keep currency calculations consistent in forms and API payloads.

```dart
final text = BrazilianCurrencyInputFormatter.formatForDisplay(123456);
// 1.234,56

final minorUnits =
    BrazilianCurrencyInputFormatter.minorUnitsFromText('R\$ 1.234,56');
// 123456
```

## Loading overlay

`SimpleLoading` can be used as a lightweight overlay for any element or for the
whole page.

```dart
final loading = SimpleLoading();

try {
  loading.show(target: hostElement);
  // async work
} finally {
  loading.hide();
}
```

## Notes

- This package is designed for AngularDart web applications.
- It uses `dart:html`, so it is not intended for Flutter or server-side Dart.
- Some components depend on `essential_core` models and the `popper` package.
