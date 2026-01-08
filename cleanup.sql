-- 🚨 SCRIPT DE LIMPEZA E CORREÇÃO DE DUPLICIDADE (GODZ ENGINE)
-- Execute este script no seu banco de dados (HeidiSQL / DBeaver)

-- 1. Remover usuários duplicados (ID 2, 3, etc) se foram criados por erro
-- Mantenha apenas o ID 1 (Admin/Fundador) se for o caso.
-- CUIDADO: Isso deletará o ID 2. Verifique se não é um jogador real antes de rodar.
DELETE FROM godz_users WHERE id > 1;

-- 2. Limpar identificadores órfãos (que não tem usuário na tabela principal)
DELETE FROM godz_user_ids WHERE user_id NOT IN (SELECT id FROM godz_users);

-- 3. Limpar tabelas dependentes para evitar erros de chave estrangeira
DELETE FROM godz_user_data WHERE user_id NOT IN (SELECT id FROM godz_users);
DELETE FROM godz_user_identities WHERE user_id NOT IN (SELECT id FROM godz_users);
DELETE FROM godz_benefits WHERE user_id NOT IN (SELECT id FROM godz_users);

-- 4. Resetar o AUTO_INCREMENT para garantir que o próximo player seja o 2 (ou o próximo livre)
ALTER TABLE godz_users AUTO_INCREMENT = 2;

-- 5. Garantir que o ID 1 tenha Whitelist e não esteja banido
UPDATE godz_users SET whitelisted = 1, banned = 0 WHERE id = 1;

-- 6. Verificação de Integridade (Opcional - Apenas para conferência)
SELECT * FROM godz_users;
SELECT * FROM godz_user_ids;
