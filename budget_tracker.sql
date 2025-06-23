-- Create and use database
DROP DATABASE IF EXISTS BudgetTracker;
CREATE DATABASE BudgetTracker;
USE BudgetTracker;

-- Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL
);

-- Accounts Table
CREATE TABLE Accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    account_name VARCHAR(50),
    account_type ENUM('cash', 'bank', 'credit card'),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    category_type ENUM('income', 'expense'),
    category_name VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Transactions Table
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    account_id INT,
    category_id INT,
    transaction_date DATE,
    amount DECIMAL(10, 2),
    description VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Budgets Table
CREATE TABLE Budgets (
    budget_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    category_id INT,
    month INT,  -- Format: YYYYMM
    budget_amount DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Recurring Transactions Table
CREATE TABLE RecurringTransactions (
    recurring_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    account_id INT,
    category_id INT,
    amount DECIMAL(10,2),
    description VARCHAR(255),
    frequency ENUM('daily', 'weekly', 'monthly'),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Shared Accounts Table
CREATE TABLE SharedAccounts (
    user_id INT,
    account_id INT,
    PRIMARY KEY (user_id, account_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

-- Users
INSERT INTO Users (username, hashed_password) VALUES 
('kartik', 'hash1'), 
('abhay', 'hash2');

-- Accounts
INSERT INTO Accounts (user_id, account_name, account_type) VALUES 
(1, 'Kartik Bank', 'bank'),
(2, 'Abhay Cash', 'cash');

-- Shared Accounts 
INSERT INTO SharedAccounts (user_id, account_id) VALUES (1, 2);

-- Categories
INSERT INTO Categories (user_id, category_type, category_name) VALUES 
(1, 'expense', 'Groceries'),
(1, 'income', 'Salary'),
(2, 'expense', 'Travel');

-- Transactions
INSERT INTO Transactions (user_id, account_id, category_id, transaction_date, amount, description) VALUES 
(1, 1, 1, '2025-06-01', 1500.00, 'Monthly groceries'),
(1, 1, 2, '2025-06-01', 50000.00, 'June salary'),
(2, 2, 3, '2025-06-01', 3000.00, 'Bus tickets');

-- Budgets
INSERT INTO Budgets (user_id, category_id, month, budget_amount) VALUES 
(1, 1, 202506, 2000.00),
(2, 3, 202506, 4000.00);

-- Recurring Transactions
INSERT INTO RecurringTransactions (user_id, account_id, category_id, amount, description, frequency, start_date, end_date) VALUES
(1, 1, 1, 1500.00, 'Monthly grocery bill', 'monthly', '2025-06-01', '2025-12-01');

-- Budget vs Actual Report
SELECT 
    u.username,
    c.category_name,
    b.budget_amount,
    IFNULL(SUM(t.amount), 0) AS actual_spent,
    (b.budget_amount - IFNULL(SUM(t.amount), 0)) AS remaining
FROM Budgets b
JOIN Users u ON b.user_id = u.user_id
JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Transactions t 
    ON t.category_id = b.category_id 
    AND MONTH(t.transaction_date) = 6 
    AND YEAR(t.transaction_date) = 2025
GROUP BY b.budget_id;

-- Monthly Summary
SELECT 
    u.username,
    MONTH(t.transaction_date) AS month,
    c.category_type,
    SUM(t.amount) AS total_amount
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Categories c ON t.category_id = c.category_id
GROUP BY u.username, month, c.category_type;

-- Account Balance
SELECT 
    a.account_name,
    SUM(CASE WHEN c.category_type = 'income' THEN t.amount ELSE -t.amount END) AS balance
FROM Accounts a
JOIN Transactions t ON t.account_id = a.account_id
JOIN Categories c ON t.category_id = c.category_id
GROUP BY a.account_id;

SELECT 
    c.category_name,
    SUM(t.amount) AS total_expense
FROM Transactions t
JOIN Categories c ON t.category_id = c.category_id
WHERE c.category_type = 'expense'
GROUP BY c.category_name;
