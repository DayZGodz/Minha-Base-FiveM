SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `godz_bank_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `value` int(11) DEFAULT 0,
  `date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_bank_logs_sender` (`sender_id`),
  KEY `fk_bank_logs_receiver` (`receiver_id`),
  CONSTRAINT `fk_bank_logs_sender` FOREIGN KEY (`sender_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bank_logs_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `godz_bank_loans` (
  `user_id` int(11) NOT NULL,
  `loan_amount` int(11) DEFAULT 0,
  `remaining_amount` int(11) DEFAULT 0,
  `next_payment` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_bank_loans_user` FOREIGN KEY (`user_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
