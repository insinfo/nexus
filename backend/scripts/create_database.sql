-- Execute este arquivo conectado a um superusuario existente do PostgreSQL.
-- Exemplo:
-- psql -U postgres -d postgres -f nexus/backend/scripts/create_database.sql
--
-- O script:
-- 1. cria o usuario/superusuario dart com senha dart, se ele ainda nao existir
-- 2. se o usuario ja existir, garante SUPERUSER, LOGIN e senha dart
-- 3. encerra conexoes e remove bancos temporarios nexus_tmp* acumulados
-- 4. remove e recria os bancos salus e nexus com UTF8 e locale pt_BR.UTF-8

SELECT 'CREATE ROLE dart WITH SUPERUSER LOGIN PASSWORD ''dart'''
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = 'dart'
)
\gexec

SELECT 'ALTER ROLE dart WITH SUPERUSER LOGIN PASSWORD ''dart'''
WHERE EXISTS (
  SELECT 1
  FROM pg_roles
  WHERE rolname = 'dart'
)
\gexec

SELECT format(
  'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = %L AND pid <> pg_backend_pid()',
  datname
)
FROM pg_database
WHERE datname IN ( 'nexus') OR datname LIKE 'nexus\\_tmp%%' ESCAPE '\\'
\gexec

SELECT format('DROP DATABASE IF EXISTS %I', datname)
FROM pg_database
WHERE datname LIKE 'nexus\\_tmp%%' ESCAPE '\\'
\gexec

DROP DATABASE IF EXISTS nexus;



CREATE DATABASE nexus OWNER dart ENCODING 'UTF8' LC_COLLATE 'pt_BR.UTF-8' LC_CTYPE 'pt_BR.UTF-8' TEMPLATE template0;
