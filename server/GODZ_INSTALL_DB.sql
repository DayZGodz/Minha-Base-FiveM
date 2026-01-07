DROP DATABASE IF EXISTS `godz_database`;
CREATE DATABASE IF NOT EXISTS `godz_database` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `godz_database`;

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- GODZ DATABASE SCHEMA (UNIFIED)
-- Version: 2.0 (Merged Core + Phone + Housing)
-- --------------------------------------------------------

-- --------------------------------------------------------
-- CORE TABLES
-- --------------------------------------------------------

-- Tabela Mestra: godz_users
-- Fix: last_login e ip agora aceitam NULL para evitar falhas no INSERT inicial
CREATE TABLE IF NOT EXISTS `godz_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_login` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
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

-- --------------------------------------------------------
-- PHONE TABLES (Added from GODZ_PHONE.sql)
-- --------------------------------------------------------

-- godz_phone_contacts
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

-- godz_phone_messages
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

SET FOREIGN_KEY_CHECKS = 1;
