CREATE TABLE IF NOT EXISTS `godz_mdt_warrants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(50) DEFAULT 'active', -- active, served, expired
  `author_id` int(11) NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
