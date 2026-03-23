-- Execute este arquivo conectado a um superusuario existente do PostgreSQL.
-- Exemplo:
-- psql -U postgres -d postgres -f nexus/backend/scripts/create_database.sql
--
-- O script:
-- 1. cria o usuario/superusuario dart com senha dart, se ele ainda nao existir
-- 2. se o usuario ja existir, garante SUPERUSER, LOGIN e senha dart
-- 3. encerra conexoes abertas no banco nexus
-- 4. remove e recria o banco nexus com UTF8 e locale pt_BR.UTF-8

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dart') THEN
    CREATE ROLE dart WITH SUPERUSER LOGIN PASSWORD 'dart';
  ELSE
    ALTER ROLE dart WITH SUPERUSER LOGIN PASSWORD 'dart';
  END IF;
END
$$;

-- Encerrar conexoes abertas no banco nexus antes de dropar
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'nexus' AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS nexus;
CREATE DATABASE nexus OWNER dart ENCODING 'UTF8' LC_COLLATE 'pt_BR.UTF-8' LC_CTYPE 'pt_BR.UTF-8' TEMPLATE template0;
