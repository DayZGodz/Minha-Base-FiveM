CREATE TABLE IF NOT EXISTS `godz_user_jobs` (
  `user_id` int(11) NOT NULL,
  `job` varchar(50) NOT NULL,
  `level` int(11) DEFAULT 1,
  `xp` int(11) DEFAULT 0,
  PRIMARY KEY (`user_id`, `job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
