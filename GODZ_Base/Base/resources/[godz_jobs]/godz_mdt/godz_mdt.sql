SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `godz_mdt_warrants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(50) DEFAULT 'active', -- active, served, expired
  `author_id` int(11) NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_mdt_warrants_user` (`user_id`),
  KEY `fk_mdt_warrants_author` (`author_id`),
  CONSTRAINT `fk_mdt_warrants_user` FOREIGN KEY (`user_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mdt_warrants_author` FOREIGN KEY (`author_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
