SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `godz_housing_homes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `price` int(11) NOT NULL DEFAULT 0,
  `coords` text NOT NULL, -- JSON {x,y,z}
  `garage` text DEFAULT NULL, -- JSON {x,y,z,h}
  `shell` varchar(50) NOT NULL DEFAULT 'shell_v16_mid',
  `max_keys` int(11) NOT NULL DEFAULT 3,
  PRIMARY KEY (`id`),
  KEY `fk_housing_owner` (`owner_id`),
  CONSTRAINT `fk_housing_owner` FOREIGN KEY (`owner_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `godz_housing_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `home_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `home_id` (`home_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_housing_keys_home` FOREIGN KEY (`home_id`) REFERENCES `godz_housing_homes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_housing_keys_user` FOREIGN KEY (`user_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `godz_housing_furniture` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `home_id` int(11) NOT NULL,
  `model` varchar(100) NOT NULL,
  `coords` text NOT NULL, -- JSON {x,y,z}
  `rotation` text NOT NULL, -- JSON {x,y,z}
  PRIMARY KEY (`id`),
  KEY `home_id` (`home_id`),
  CONSTRAINT `fk_housing_furniture_home` FOREIGN KEY (`home_id`) REFERENCES `godz_housing_homes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
