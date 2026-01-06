SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `godz_user_jobs` (
  `user_id` int(11) NOT NULL,
  `job` varchar(50) NOT NULL,
  `level` int(11) DEFAULT 1,
  `xp` int(11) DEFAULT 0,
  PRIMARY KEY (`user_id`, `job`),
  CONSTRAINT `fk_godz_jobs_user` FOREIGN KEY (`user_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
