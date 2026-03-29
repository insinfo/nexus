# AGENTS.md

Instrucoes obrigatorias para agentes de IA neste repositorio.

## AngularDart / ngdart

1. Nunca use atributos HTML customizados diretamente no template quando precisarem de binding.
   Exemplo proibido: `data-access-role="admin"`
   Exemplo correto: `[attr.data-access-role]="'admin'"`

2. Nunca use `[style]="..."` para aplicar estilos inline complexos.
   Crie uma diretiva propria, use bindings de atributos especificos ou mova a regra para CSS.

3. Nunca use `class="..."` ou `[class]="..."` para montar classe dinamica complexa.
   Prefira diretiva propria ou bindings de classe especificos e claros.

4. Templates ngdart nao aceitam expressoes soltas estilo Angular moderno com varias instrucoes no mesmo evento.
   Exemplo proibido: `(click)="acao1(); acao2()"`
   Crie um metodo no componente.

5. Sempre valide qualquer alteracao de template/componente com build real, nao apenas com `dart analyze`.

## Testes frontend ngdart

6. Testes de componentes frontend ngdart devem ser executados via build runner.
   Comando base: `dart run build_runner test`

7. Quando alterar componente, template ou stylesheet de ngdart, rode pelo menos:
   `dart analyze`
   `dart run build_runner build --delete-conflicting-outputs`

## Arquivos gerados

8. Nunca corrija arquivo gerado.
   Exemplos: `*.template.dart`, `*.css.shim.dart`, arquivos em `.dart_tool/`, saidas de build.

9. Se o erro estiver em arquivo gerado, corrija o arquivo-fonte que gera esse artefato.

## Dart strings

10. Sempre escape `$` literal em strings Dart com `\$`.
    Isso vale especialmente para JSON inline, regex, snippets e templates textuais.

## Regra operacional

11. Antes de concluir qualquer tarefa que altere frontend ngdart, confirme que o projeto compila.

12. Nao responda "deve funcionar". Verifique.
