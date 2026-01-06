CREATE TABLE IF NOT EXISTS `godz_bank_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `value` int(11) DEFAULT 0,
  `date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `godz_bank_loans` (
  `user_id` int(11) NOT NULL,
  `loan_amount` int(11) DEFAULT 0,
  `remaining_amount` int(11) DEFAULT 0,
  `next_payment` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
