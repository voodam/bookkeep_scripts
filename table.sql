CREATE TABLE ledger (
  target VARCHAR(256),
  date DATE,
  amount DECIMAL(7,2),
  category VARCHAR(16),
  account CHAR(1),
  iban VARCHAR(32),
  currency CHAR(3),
  PRIMARY KEY(target, date, amount)
);

--SELECT category, SUM(amount), GROUP_CONCAT(target) FROM ledger GROUP BY category ORDER BY SUM(amount) DESC;
