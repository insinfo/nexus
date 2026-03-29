# COPILOT.md

Regras locais para Copilot, agentes e assistentes de codigo.

## Nao quebrar ngdart

- Use bindings de atributo para `data-*`, `aria-*` e afins.
- Formato correto: `[attr.data-access-role]="'admin'"`
- Nao use `[style]="variavel"` para estilo composto.
- Nao use expressoes com multiplas chamadas em eventos de template.
- Se precisar combinar acoes, crie metodo no componente Dart.

## Nao editar gerados

- Nunca editar `*.template.dart`
- Nunca editar `*.css.shim.dart`
- Nunca editar saidas de `.dart_tool/`
- Corrigir sempre a origem

## Validacao minima

Depois de alterar frontend ngdart, executar:

```bash
dart analyze
dart run build_runner build --delete-conflicting-outputs
```

Para testes de componente:

```bash
dart run build_runner test
```

## Strings Dart

- `$` literal deve virar `\$`
- Nao deixar interpolacao acidental em snippets, JSON e regex
