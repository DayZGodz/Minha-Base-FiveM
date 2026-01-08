DROP DATABASE IF EXISTS `godz_database`;
CREATE DATABASE IF NOT EXISTS `godz_database` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `godz_database`;

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- GODZ DATABASE SCHEMA (UNIFIED MASTER V2.1)
-- Version: 2.1 (Core + Phone + Housing + Bank + Customs)
-- --------------------------------------------------------

-- --------------------------------------------------------
-- CORE TABLES
-- --------------------------------------------------------

-- Tabela Mestra: godz_users
CREATE TABLE IF NOT EXISTS `godz_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_login` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `whitelisted` tinyint(1) DEFAULT 0,
  `banned` tinyint(1) DEFAULT 0,
  `pet` varchar(50) DEFAULT NULL,
  `moedas` int(30) NOT NULL DEFAULT 0,
  `garagem` int(30) NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_user_ids
CREATE TABLE IF NOT EXISTS `godz_user_ids` (
  `identifier` varchar(100) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `dkey` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`identifier`),
  KEY `fk_user_ids_users` (`user_id`),
  CONSTRAINT `fk_user_ids_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_user_data
CREATE TABLE IF NOT EXISTS `godz_user_data` (
  `user_id` int(11) NOT NULL,
  `dkey` varchar(100) NOT NULL,
  `dvalue` text DEFAULT NULL,
  PRIMARY KEY (`user_id`,`dkey`),
  CONSTRAINT `fk_user_data_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_srv_data
CREATE TABLE IF NOT EXISTS `godz_srv_data` (
  `dkey` varchar(100) NOT NULL,
  `dvalue` text DEFAULT NULL,
  PRIMARY KEY (`dkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_user_identities
CREATE TABLE IF NOT EXISTS `godz_user_identities` (
  `user_id` int(11) NOT NULL,
  `registration` varchar(20) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `foragido` int(11) NOT NULL DEFAULT 0,
  `foto` varchar(1500) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  KEY `registration` (`registration`),
  KEY `phone` (`phone`),
  CONSTRAINT `fk_user_identities_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_user_moneys
CREATE TABLE IF NOT EXISTS `godz_user_moneys` (
  `user_id` int(11) NOT NULL,
  `wallet` int(11) DEFAULT 0,
  `bank` int(11) DEFAULT 0,
  `coin` int(11) DEFAULT 0,
  `paypal` int(11) DEFAULT 0,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_user_moneys_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_business
CREATE TABLE IF NOT EXISTS `godz_business` (
  `user_id` int(11) NOT NULL,
  `capital` int(11) DEFAULT 0,
  `laundered` int(11) DEFAULT 0,
  `reset_timestamp` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_business_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_priority
CREATE TABLE IF NOT EXISTS `godz_priority` (
  `steam` varchar(100) NOT NULL,
  `priority` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`steam`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_benefits
CREATE TABLE IF NOT EXISTS `godz_benefits` (
  `user_id` int(11) NOT NULL,
  `steam` varchar(100) DEFAULT NULL,
  `global_ban` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_benefits_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_user_groups (persistência de cargos)
CREATE TABLE IF NOT EXISTS `godz_user_groups` (
  `user_id` int(11) NOT NULL,
  `group_name` varchar(50) NOT NULL,
  `group_grade` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`, `group_name`),
  CONSTRAINT `fk_user_groups_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- godz_whitelist_temp (Token + IP binding)
CREATE TABLE IF NOT EXISTS `godz_whitelist_temp` (
  `user_id` int(11) NOT NULL,
  `token` varchar(16) NOT NULL,
  `ip` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`),
  KEY `idx_token` (`token`),
  CONSTRAINT `fk_wltemp_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- PHONE TABLES
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `godz_phone_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `number` varchar(20) DEFAULT NULL,
  `display` varchar(64) DEFAULT NULL,
  `bank` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_phone_contacts_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `godz_phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `number` varchar(20) DEFAULT NULL,
  `owner` int(11) NOT NULL DEFAULT 0,
  `message` text NOT NULL,
  `read` int(11) NOT NULL DEFAULT 0,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_phone_messages_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- BANKING TABLES
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `godz_bank_loans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `remaining_amount` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_bank_loans_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `godz_bank_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `value` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  KEY `receiver_id` (`receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- HOUSING TABLES
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `godz_housing_homes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `coords` text NOT NULL,
  `shell` varchar(50) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `fk_housing_users` FOREIGN KEY (`owner_id`) REFERENCES `godz_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `godz_housing_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `home_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `home_id` (`home_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_housing_keys_home` FOREIGN KEY (`home_id`) REFERENCES `godz_housing_homes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_housing_keys_users` FOREIGN KEY (`user_id`) REFERENCES `godz_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- RENZU CUSTOMS
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `renzu_customs` (
  `shop` VARCHAR(64) NOT NULL DEFAULT '[]',
  `inventory` LONGTEXT NULL DEFAULT '[]',
  PRIMARY KEY (`shop`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- Seed: Registro ID 0 (NEXUS)
SET @OLD_SQL_MODE=@@SQL_MODE;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
INSERT IGNORE INTO `godz_users` (`id`, `last_login`, `ip`, `whitelisted`, `banned`, `pet`, `moedas`, `garagem`) VALUES (0, 'SYSTEM', '127.0.0.1', 1, 0, NULL, 0, 2);
INSERT IGNORE INTO `godz_user_identities` (`user_id`, `registration`, `phone`, `firstname`, `name`, `age`, `foragido`, `foto`) VALUES (0, '00000000', '000-000', 'NEXUS', 'SISTEMA', 0, 0, NULL);
INSERT IGNORE INTO `godz_user_groups` (`user_id`, `group_name`, `group_grade`) VALUES (0, 'bot', 0);

-- Seed: Staff Base (ID 1 & 2)
INSERT IGNORE INTO `godz_user_groups` (`user_id`, `group_name`, `group_grade`) VALUES (1, 'ceo', 0);
INSERT IGNORE INTO `godz_user_groups` (`user_id`, `group_name`, `group_grade`) VALUES (2, 'ceo', 0);

SET SQL_MODE=@OLD_SQL_MODE;
