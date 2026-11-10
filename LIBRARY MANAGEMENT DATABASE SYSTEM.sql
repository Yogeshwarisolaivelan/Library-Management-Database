

-- 1. CREATE DATABASE

DROP DATABASE IF EXISTS LibraryDB;

CREATE DATABASE LibraryDB;

USE LibraryDB;


-- 2. CREATE TABLES

-- Authors Table

CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(100) NOT NULL
);


-- Books Table

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author_id INT NOT NULL,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,

    FOREIGN KEY (author_id)
    REFERENCES Authors(author_id)
);


-- Users Table

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);


-- Transactions Table

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Issued',

    FOREIGN KEY (book_id)
    REFERENCES Books(book_id),

    FOREIGN KEY (user_id)
    REFERENCES Users(user_id)
);


-- 3. CHECK TABLE STRUCTURE

SHOW TABLES;

DESC Authors;
DESC Books;
DESC Users;
DESC Transactions;


-- 4. INSERT SAMPLE DATA

-- Authors

INSERT INTO Authors (author_name) VALUES
('R.K. Narayan'),
('J.K. Rowling'),
('Chetan Bhagat');


-- Books

INSERT INTO Books
(title, author_id, total_copies, available_copies)
VALUES
('Malgudi Days', 1, 5, 5),
('Harry Potter', 2, 4, 4),
('Five Point Someone', 3, 3, 3);


-- Users

INSERT INTO Users (name, email) VALUES
('Asha Rao', 'asha@example.com'),
('Ravi Kumar', 'ravi@example.com'),
('Meena Iyer', 'meena@example.com');


-- 5. ISSUE A BOOK

-- Asha issues Malgudi Days

START TRANSACTION;

UPDATE Books
SET available_copies = available_copies - 1
WHERE book_id = 1 AND available_copies > 0;

SET @issued = ROW_COUNT();

INSERT INTO Transactions
(book_id, user_id, issue_date, due_date)
SELECT 1, 1, CURDATE(),
DATE_ADD(CURDATE(), INTERVAL 14 DAY)
WHERE @issued = 1;

COMMIT;


-- 6. RETURN A BOOK

-- Asha returns Malgudi Days

START TRANSACTION;

UPDATE Transactions
SET return_date = CURDATE(),
    status = 'Returned'
WHERE transaction_id = 1
AND status = 'Issued';

SET @returned = ROW_COUNT();

UPDATE Books b
JOIN Transactions t ON b.book_id = t.book_id
SET b.available_copies = b.available_copies + 1
WHERE t.transaction_id = 1
AND @returned = 1;

COMMIT;


-- 7. MORE BOOK ISSUES

-- Ravi issues Harry Potter

START TRANSACTION;

UPDATE Books
SET available_copies = available_copies - 1
WHERE book_id = 2 AND available_copies > 0;

SET @issued = ROW_COUNT();

INSERT INTO Transactions
(book_id, user_id, issue_date, due_date)
SELECT 2, 2, CURDATE(),
DATE_ADD(CURDATE(), INTERVAL 14 DAY)
WHERE @issued = 1;

COMMIT;


-- Meena issues Five Point Someone
-- Overdue example

START TRANSACTION;

UPDATE Books
SET available_copies = available_copies - 1
WHERE book_id = 3 AND available_copies > 0;

SET @issued = ROW_COUNT();

INSERT INTO Transactions
(book_id, user_id, issue_date, due_date)
SELECT 3, 3,
DATE_SUB(CURDATE(), INTERVAL 20 DAY),
DATE_SUB(CURDATE(), INTERVAL 6 DAY)
WHERE @issued = 1;

COMMIT;


-- 8. DISPLAY ALL RECORDS

SELECT * FROM Authors;

SELECT * FROM Books;

SELECT * FROM Users;

SELECT * FROM Transactions;


-- 9. TRACKING QUERIES

-- A. Currently issued books

SELECT
    t.transaction_id,
    u.name,
    b.title,
    t.issue_date,
    t.due_date
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Books b ON t.book_id = b.book_id
WHERE t.status = 'Issued';


-- B. Overdue books

SELECT
    u.name,
    b.title,
    t.due_date,
    DATEDIFF(CURDATE(), t.due_date)
    AS days_overdue
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Books b ON t.book_id = b.book_id
WHERE t.status = 'Issued'
AND t.due_date < CURDATE();


-- C. Books with author details

SELECT
    b.title,
    a.author_name,
    b.total_copies,
    b.available_copies
FROM Books b
JOIN Authors a ON b.author_id = a.author_id;


-- D. Returned books

SELECT
    t.transaction_id,
    u.name,
    b.title,
    t.return_date,
    t.status
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Books b ON t.book_id = b.book_id
WHERE t.status = 'Returned';


-- E. Available books

SELECT *
FROM Books
WHERE available_copies > 0;


-- F. Unavailable books

SELECT *
FROM Books
WHERE available_copies = 0;



