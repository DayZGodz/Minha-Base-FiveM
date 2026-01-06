CREATE TABLE IF NOT EXISTS `godz_ems_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `medic_id` int(11) NOT NULL,
  `action` varchar(255) DEFAULT NULL,
  `notes` text,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
