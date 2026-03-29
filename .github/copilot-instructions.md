# Copilot Instructions

Project-specific rules for this repository:

## AngularDart / ngdart

- Do not write raw bound custom attributes such as `data-*` directly in templates.
- Use attribute binding form instead, for example:
  - Correct: `[attr.data-access-role]="'admin'"`
  - Wrong: `data-access-role="admin"`

- Do not use `[style]="..."` for complex style composition.
- Do not rely on dynamic full `class` string composition for complex cases.
- Prefer explicit bindings, CSS, or a dedicated directive.

- Do not place multiple statements inside template event handlers.
  - Wrong: `(click)="save(); closePanel()"`
  - Correct: create a Dart method and call that method.

## Generated files

- Never patch generated files.
- Do not edit:
  - `*.template.dart`
  - `*.css.shim.dart`
  - `.dart_tool/**`
- Fix the source component, template, stylesheet, or builder input instead.

## Validation

- After frontend ngdart changes, verify with:

```bash
dart analyze
dart run build_runner build --delete-conflicting-outputs
```

- For ngdart component tests, use:

```bash
dart run build_runner test
```

## Dart string safety

- Escape literal `$` as `\$`.
- Be careful with JSON snippets, regexes, shell fragments, and template-like strings.
