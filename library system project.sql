CREATE DATABASE libary_project_p02;

-- Project Name: Libary Management System
-- Creating tables
CREATE TABLE branch(
	branch_id	VARCHAR(10) PRIMARY KEY,
	manager_id	VARCHAR(10),
	branch_address	VARCHAR(55),
	contact_no VARCHAR(10)
);

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(20);

CREATE TABLE employees(
	emp_id	VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(25),
	position VARCHAR (20),
	salary	INT,
	branch_id VARCHAR(15)
);

ALTER TABLE employees
ALTER COLUMN salary TYPE FLOAT;

CREATE TABLE books(
	isbn VARCHAR(25) PRIMARY KEY,
	book_title	VARCHAR(100),
	category	VARCHAR(20),
	rental_price	FLOAT,
	status	VARCHAR(10),
	author	VARCHAR(35),
	publisher VARCHAR(75)
);

CREATE TABLE members(
	member_id VARCHAR(20) PRIMARY KEY,
	member_name	VARCHAR(35),
	member_address	VARCHAR(70),
	reg_date DATE
);

CREATE TABLE issued_status(
	issued_id	VARCHAR(20) PRIMARY KEY,
	issued_member_id VARCHAR(20),  -- FK
	issued_book_name VARCHAR(100),
	issued_date	DATE,
	issued_book_isbn VARCHAR(55),  --FK
	issued_emp_id VARCHAR(20)   --FK
);

CREATE TABLE return_status(
	return_id	VARCHAR(20) PRIMARY KEY,
	issued_id	VARCHAR(20),
	return_book_name	VARCHAR(100),
	return_date	DATE,
	return_book_isbn VARCHAR(25)
);

-- FOREIGN KEY
ALTER TABLE issued_status 
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status 
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status 
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

-- Import the Data file using query
COPY branch(branch_id, manager_id, branch_address, contact_no)
FROM 'G:\Data Analysis project-2025\Projects_using_sql\Library-System-Management---P2\branch.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM branch;

COPY books(isbn, book_title, category, rental_price, status, author, publisher)
FROM 'G:\Data Analysis project-2025\Projects_using_sql\Library-System-Management---P2\books.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM books;

COPY employees(emp_id, emp_name, position, salary, branch_id)
FROM 'G:\Data Analysis project-2025\Projects_using_sql\Library-System-Management---P2\employees.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM employees;

COPY members(member_id, member_name, member_address, reg_date)
FROM 'G:\Data Analysis project-2025\Projects_using_sql\Library-System-Management---P2\members.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM members;

COPY issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
FROM 'G:\Data Analysis project-2025\Projects_using_sql\Library-System-Management---P2\issued_status.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM issued_status;

COPY return_status(return_id, issued_id, return_book_name, return_date, return_book_isbn)
FROM 'G:\Data Analysis project-2025\Projects_using_sql\Library-System-Management---P2\return_status.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM return_status;

-- Project Tasks
-- #CRUD Operations-
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';
SELECT * FROM issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT 
	issued_emp_id,
	COUNT(issued_id) as total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1;

-- CTAS(Create Tables as Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE books_cnts
as
SELECT 
	b.isbn,
	b.book_title,    -- if we want name 
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Data Analysis & Findings
-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:
SELECT
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('S120', 'Soumik', 'DLF Phase3', '2025-05-21'),
('S121', 'Vicky', 'Gurgaon', '2025-05-22');

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;