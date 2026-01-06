SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `godz_ems_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `medic_id` int(11) NOT NULL,
  `action` varchar(255) DEFAULT NULL,
  `notes` text,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_ems_history_user` (`user_id`),
  KEY `fk_ems_history_medic` (`medic_id`),
  CONSTRAINT `fk_ems_history_user` FOREIGN KEY (`user_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ems_history_medic` FOREIGN KEY (`medic_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
