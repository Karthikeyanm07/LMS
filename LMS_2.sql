create database lms;
use lms;

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    membership_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    membership_status ENUM('Active', 'Inactive') DEFAULT 'Active'
);


CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    author VARCHAR(255),
    publisher VARCHAR(255),
    genre VARCHAR(100),
    quantity INT DEFAULT 0,
    available_quantity INT DEFAULT 0
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    transaction_type ENUM('Borrow', 'Return'),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME,
    return_date DATETIME,
    fine DECIMAL(5, 2) DEFAULT 0.00,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);


CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT,
    fine_amount DECIMAL(5, 2),
    paid_status ENUM('Paid', 'Unpaid') DEFAULT 'Unpaid',
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);


CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(255)
);


CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

select * from authors;
select * from book_authors;
select * from books;
select * from fines;
select * from members;
select * from transactions;
select * from reservations;

INSERT INTO members (first_name, last_name, email, phone, membership_date, membership_status) VALUES
('John', 'Doe', 'john.doe@email.com', '9876543210', NOW(), 'Active'),
('Jane', 'Smith', 'jane.smith@email.com', '9765432109', NOW(), 'Active'),
('Alice', 'Johnson', 'alice.j@email.com', '9654321098', NOW(), 'Active'),
('Bob', 'Brown', 'bob.brown@email.com', '9543210987', NOW(), 'Active'),
('Charlie', 'Davis', 'charlie.d@email.com', '9432109876', NOW(), 'Active');

INSERT INTO books (title, author, publisher, genre, quantity, available_quantity) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', 'Fiction', 5, 5),
('To Kill a Mockingbird', 'Harper Lee', 'J.B. Lippincott & Co.', 'Classic', 7, 6),
('1984', 'George Orwell', 'Secker & Warburg', 'Dystopian', 10, 10),
('Pride and Prejudice', 'Jane Austen', 'T. Egerton', 'Romance', 8, 8),
('Moby-Dick', 'Herman Melville', 'Harper & Brothers', 'Adventure', 4, 3);

INSERT INTO transactions (member_id, book_id, transaction_type, transaction_date, due_date, return_date, fine) VALUES
(1, 3, 'Borrow', NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), NULL, 0.00),
(2, 4, 'Borrow', NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), NULL, 0.00),
(3, 5, 'Return', NOW(), DATE_ADD(NOW(), INTERVAL -3 DAY), NOW(), 0.00),
(4, 1, 'Borrow', NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), NULL, 0.00),
(5, 2, 'Borrow', NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), NULL, 0.00);

INSERT INTO fines (transaction_id, fine_amount, paid_status) VALUES
(6, 10.00, 'Unpaid'),
(10, 5.00, 'Paid'),
(7, 0.00, 'Paid'),
(8, 0.00, 'Paid'),
(9, 0.00, 'Paid');

INSERT INTO authors (author_name) VALUES
('F. Scott Fitzgerald'),
('Harper Lee'),
('George Orwell'),
('Jane Austen'),
('Herman Melville'),
('Leo Tolstoy'),
('J.D. Salinger'),
('J.R.R. Tolkien'),
('Fyodor Dostoevsky'),
('Paulo Coelho');

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- 6) View All Borrowed Books

SELECT m.first_name, m.last_name, b.title, t.transaction_date, t.due_date, t.return_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow' AND t.return_date IS NULL;

-- 7) View All Overdue Books

SELECT m.first_name, m.last_name, b.title, t.due_date, DATEDIFF(CURDATE(), t.due_date) AS overdue_days
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow' AND t.return_date IS NULL AND DATEDIFF(CURDATE(), t.due_date) > 0;

-- 8) View Member’s Borrowing History

SELECT m.first_name, m.last_name, b.title, t.transaction_type, t.transaction_date, t.due_date, t.return_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE m.member_id in (1,3);

-- 9).-- View All Books in the Library

SELECT book_id, title, author, genre, quantity, available_quantity
FROM books;

-- 10) View All Members in the Library

SELECT member_id, first_name, last_name, email, membership_status
FROM members;

-- SPECIAL FUNCNTIONALITIES --
-- 1)Search Books by Title, Author, or Genre

SELECT * FROM books WHERE title LIKE '%graet%' OR author LIKE '%scott%' ;

-- 2) Overdue Fine Management
	-- Automatically Update Fine:
UPDATE transactions
SET fine = DATEDIFF(CURDATE(), due_date) * 1.00
WHERE return_date IS NULL AND DATEDIFF(CURDATE(), due_date) > 0;

-- Send Reminder for Overdue Books:

SELECT m.email, m.first_name, b.title, t.due_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.return_date IS NULL AND DATEDIFF(CURDATE(), t.due_date) > 0;

-- 3) Book Reservation:
-- Allow members to reserve books that are currently unavailable.

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO reservations (member_id, book_id, reservation_date, status) VALUES
(1, 1, '2025-03-01 13:30:00', 'Pending'), 
(2, 3, '2025-03-01 12:15:00', 'Pending'), 
(3, 5, '2025-03-02 09:00:00', 'Completed');

-- 4) Reporting System:
-- Generate reports for overdue books, total fines, and member borrowing history.

-- Overdue Books Report:
SELECT * FROM transactions WHERE return_date IS NULL AND due_date < CURDATE();

-- Total Fine Report:
SELECT SUM(fine_amount) AS total_fines FROM fines WHERE paid_status = 'Unpaid';

-- Member Borrowing History:
SELECT * FROM transactions WHERE member_id = 1;

SELECT t.member_id, r.reservation_date FROM transactions t
join reservations r
on t.member_id=r.member_id

