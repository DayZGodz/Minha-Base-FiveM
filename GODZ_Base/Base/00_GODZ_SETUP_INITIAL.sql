SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `vrp` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `vrp`;

-- --------------------------------------------------------
-- Tabela Mestra: vrp_users
-- Essencial para todas as Foreign Keys do sistema
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vrp_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_login` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `whitelisted` tinyint(1) DEFAULT NULL,
  `banned` tinyint(1) DEFAULT NULL,
  `pet` varchar(50) DEFAULT NULL,
  `moedas` int(30) NOT NULL DEFAULT 0,
  `garagem` int(30) NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET FOREIGN_KEY_CHECKS = 1;
