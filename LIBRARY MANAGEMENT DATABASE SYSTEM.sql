-- 1. Create and select database (fresh start, no duplicates)
DROP DATABASE IF EXISTS LibraryDB;
CREATE DATABASE LibraryDB;
USE LibraryDB;

-- 2. Create tables
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(100) NOT NULL
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author_id INT,
    total_copies INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    user_id INT,
    issue_date DATE,
    due_date DATE,
    return_date DATE,
    status VARCHAR(20) DEFAULT 'Issued',
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 3. Check structure
SHOW TABLES;
DESC Authors;
DESC Books;
DESC Users;
DESC Transactions;

-- 4. Insert sample data (once)
INSERT INTO Authors (author_name) VALUES
('R.K. Narayan'), ('J.K. Rowling'), ('Chetan Bhagat');

INSERT INTO Books (title, author_id, total_copies, available_copies) VALUES
('Malgudi Days', 1, 5, 5),
('Harry Potter', 2, 4, 4),
('Five Point Someone', 3, 3, 3);

INSERT INTO Users (name, email) VALUES
('Asha Rao', 'asha@example.com'),
('Ravi Kumar', 'ravi@example.com'),
('Meena Iyer', 'meena@example.com');

-- 5. Issue a book (Asha takes Malgudi Days)
INSERT INTO Transactions (book_id, user_id, issue_date, due_date)
VALUES (1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));

UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = 1;

-- 6. Return the book
UPDATE Transactions
SET return_date = CURDATE(), status = 'Returned'
WHERE transaction_id = 1;

UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = 1;

-- 7. More issues (Ravi: normal loan, Meena: overdue loan)
INSERT INTO Transactions (book_id, user_id, issue_date, due_date) VALUES
(2, 2, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
(3, 3, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY));

UPDATE Books SET available_copies = available_copies - 1 WHERE book_id IN (2, 3);

-- 8. Check data
SELECT * FROM Authors;
SELECT * FROM Books;
SELECT * FROM Users;
SELECT * FROM Transactions;

-- 9. Tracking queries

-- Books currently issued
SELECT t.transaction_id, u.name, b.title, t.issue_date, t.due_date
FROM Transactions t
JOIN Users u ON u.user_id = t.user_id
JOIN Books b ON b.book_id = t.book_id
WHERE t.status = 'Issued';

-- Overdue books
SELECT u.name, b.title, t.due_date,
       DATEDIFF(CURDATE(), t.due_date) AS days_overdue
FROM Transactions t
JOIN Users u ON u.user_id = t.user_id
JOIN Books b ON b.book_id = t.book_id
WHERE t.status = 'Issued' AND t.due_date < CURDATE();

-- Books with author and availability
SELECT b.title, a.author_name, b.total_copies, b.available_copies
FROM Books b
JOIN Authors a ON a.author_id = b.author_id;