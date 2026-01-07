CREATE TABLE IF NOT EXISTS godz_user_vehicles (
  user_id INT(11) NOT NULL,
  vehicle VARCHAR(100) NOT NULL,
  plate VARCHAR(20) NOT NULL,
  mechanic_report TEXT,
  PRIMARY KEY (user_id, vehicle)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
