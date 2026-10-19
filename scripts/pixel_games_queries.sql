-- DBAS 1007 - Week 7: CRUD with pixel_games (SELECT, INSERT, UPDATE, DELETE)
-- Connect in Workbench: Host 127.0.0.1  Port 13306  User root  Password rootpassword
--
-- HOW TO USE THIS FILE
--   * First run scripts/pixel_games.sql (the whole file) to build the database.
--   * Each "DEMO n" block matches the DEMO n badge on the slides.
--   * Run ONE statement at a time: put the cursor on it and press Ctrl+Enter.
--   * Some statements fail ON PURPOSE (marked "EXPECT ERROR"). Read the
--     Output panel at the bottom of Workbench each time.
--   * Messed up the data with INSERT / UPDATE / DELETE? Just run scripts/pixel_games.sql
--     again. It rebuilds everything from scratch.
--   * Today we query ONE table at a time. Combining tables (JOIN) is next week.

USE pixel_games;


-- =====================================================================
-- DEMO 1 - Meet the database
-- =====================================================================
SHOW TABLES;

DESCRIBE game;
DESCRIBE customer;

SELECT * FROM platform;                    -- platform_id 5 = Switch, 6 = Switch 2
SELECT * FROM game LIMIT 10;               -- LIMIT: just a peek, not all 62 rows
SELECT * FROM customer LIMIT 10;
SELECT * FROM sale_item LIMIT 10;


-- =====================================================================
-- DEMO 2 - SELECT recap: write order vs. run order
-- =====================================================================
-- The five clauses you know, in the order you WRITE them:
SELECT title, price                        -- 3. pick the columns
FROM game                                  -- 1. start with this table
WHERE platform_id = 5                      -- 2. keep only these rows
ORDER BY price DESC                        -- 4. sort what's left
LIMIT 5;                                   -- 5. keep the first 5
-- The numbers show the order MySQL actually RUNS them in.

-- WHERE runs BEFORE SELECT, so it doesn't know your alias yet:
SELECT title, price * 1.14 AS price_with_hst
FROM game
WHERE price_with_hst > 100;                -- EXPECT ERROR 1054: Unknown column 'price_with_hst' in 'where clause'

-- Fix: repeat the calculation in WHERE
SELECT title, price * 1.14 AS price_with_hst
FROM game
WHERE price * 1.14 > 100;

-- ORDER BY runs AFTER SELECT, so the alias works there:
SELECT title, price * 1.14 AS price_with_hst
FROM game
ORDER BY price_with_hst DESC;


-- =====================================================================
-- DEMO 3 - AND, OR, NOT ... and brackets
-- =====================================================================
-- AND: both must be true. M-rated games under $60
SELECT title, esrb_rating, price
FROM game
WHERE esrb_rating = 'M' AND price < 60;              -- 4 rows

-- OR: either can be true. Switch OR Switch 2 games
SELECT title, platform_id, price
FROM game
WHERE platform_id = 5 OR platform_id = 6;

-- NOT: flip it. Everything that isn't Sports
SELECT title, genre
FROM game
WHERE NOT genre = 'Sports';                           -- same as genre <> 'Sports'

-- GOTCHA: AND is done before OR, like * before + in math.
-- Goal: Switch or Switch 2 games under $50.
SELECT title, platform_id, price
FROM game
WHERE platform_id = 5 OR platform_id = 6 AND price < 50;     -- 14 rows: EVERY Switch game, any price!
-- MySQL read that as:  platform_id = 5  OR  (platform_id = 6 AND price < 50)

SELECT title, platform_id, price
FROM game
WHERE (platform_id = 5 OR platform_id = 6) AND price < 50;   -- 4 rows: what we meant
-- Mixing AND and OR? Use brackets. Always.


-- =====================================================================
-- DEMO 4 - IN, BETWEEN, LIKE
-- =====================================================================
-- IN: matches any value in the list (a shorter way to write lots of ORs)
SELECT title, platform_id
FROM game
WHERE platform_id IN (5, 6);                          -- 18 rows

SELECT title, genre
FROM game
WHERE genre IN ('RPG', 'Action', 'Horror')
ORDER BY genre, title;                                -- 20 rows

-- NOT IN: anything except the list
SELECT name, maker
FROM platform
WHERE maker NOT IN ('Sony', 'Microsoft');

-- BETWEEN: a range, and it INCLUDES both ends
SELECT title, price
FROM game
WHERE price BETWEEN 20 AND 50
ORDER BY price;                                       -- 10 rows

-- BETWEEN works on dates too: every sale in September 2026
SELECT sale_id, customer_id, sale_date
FROM sale
WHERE sale_date BETWEEN '2026-09-01' AND '2026-09-30';     -- 344 rows

-- LIKE: pattern matching on text.  % = any number of characters (even 0)
SELECT title FROM game WHERE title LIKE '%Mario%';    -- contains "Mario"
SELECT title FROM game WHERE title LIKE 'S%';         -- starts with S
SELECT title FROM game WHERE title LIKE '%2';         -- ends with 2

--                                   _ = exactly ONE character
SELECT title FROM game WHERE title LIKE 'NHL __';     -- NHL + space + 2 characters

SELECT first_name, last_name
FROM customer
WHERE last_name LIKE 'Mac%'                           -- MacDonald, MacLeod, MacNeil
ORDER BY last_name, first_name;                       -- 43 rows


-- =====================================================================
-- DEMO 5 - NULL: "no value"
-- =====================================================================
-- Some customers didn't give a phone number. Their phone is NULL (empty), not ''.
SELECT first_name, last_name, phone FROM customer LIMIT 20;

-- This looks right but returns NOTHING. NULL is never "equal" to anything, not even NULL.
SELECT first_name, last_name FROM customer
WHERE phone = NULL;                                   -- 0 rows (no error, which is worse!)

-- Use IS NULL / IS NOT NULL instead
SELECT first_name, last_name FROM customer
WHERE phone IS NULL;                                  -- 193 rows

SELECT first_name, last_name, phone FROM customer
WHERE phone IS NOT NULL;                              -- 407 rows


-- =====================================================================
-- DEMO 6 - Calculated columns and AS
-- =====================================================================
-- Price with 14% HST, rounded to cents
SELECT title,
       price,
       ROUND(price * 1.14, 2) AS price_with_hst
FROM game
ORDER BY price DESC;

-- Glue text together with CONCAT
SELECT CONCAT(first_name, ' ', last_name) AS full_name,
       city
FROM customer
ORDER BY last_name, first_name;

-- Line total on a receipt: quantity x price paid
SELECT sale_id, game_id, quantity, unit_price,
       quantity * unit_price AS line_total
FROM sale_item
WHERE quantity = 2
ORDER BY line_total DESC;

-- Aliases with spaces need quotes
SELECT title AS 'Game', price AS 'Price ($)'
FROM game;


-- =====================================================================
-- DEMO 7 - ORDER BY, LIMIT / OFFSET, DISTINCT
-- =====================================================================
-- Sort by more than one column: price high to low, then ties A to Z by title
SELECT title, price
FROM game
ORDER BY price DESC, title ASC;

-- LIMIT: the top 5
SELECT title, price
FROM game
ORDER BY price DESC
LIMIT 5;

-- OFFSET: skip some rows first. Paging through customers 10 at a time:
SELECT customer_id, first_name, last_name FROM customer
ORDER BY customer_id LIMIT 10 OFFSET 0;               -- page 1: customers 1-10
SELECT customer_id, first_name, last_name FROM customer
ORDER BY customer_id LIMIT 10 OFFSET 10;              -- page 2: customers 11-20

-- DISTINCT: remove duplicate result rows
SELECT title FROM game ORDER BY title;                -- 62 rows (Elden Ring is on 3 platforms)
SELECT DISTINCT title FROM game ORDER BY title;       -- 52 rows

-- DISTINCT applies to the whole row, not just the first column
SELECT DISTINCT city, province
FROM customer
ORDER BY province, city;                              -- 26 rows


-- =====================================================================
-- DEMO 8 - Single-table practice (try them before you look!)
-- =====================================================================
-- 1. List all game titles, without repeats, A to Z
SELECT DISTINCT title FROM game ORDER BY title;

-- 2. Customer full names, sorted by last name then first name
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM customer
ORDER BY last_name, first_name;

-- 3. Customers with the last name 'Smith', and where they live
SELECT first_name, last_name, city
FROM customer
WHERE last_name = 'Smith';                            -- 15 rows

-- 4. Every genre, once each
SELECT DISTINCT genre FROM game ORDER BY genre;

-- 5. Customers who live outside Nova Scotia
SELECT first_name, last_name, city, province
FROM customer
WHERE province <> 'NS'
ORDER BY province, city;                              -- 25 rows

-- 6. Associates who earn $18 an hour or more, best paid first
SELECT first_name, last_name, hourly_wage
FROM staff
WHERE role = 'Associate' AND hourly_wage >= 18
ORDER BY hourly_wage DESC;                            -- 6 rows

-- 7. PC games (platform 1) under $30, cheapest first
SELECT title, price
FROM game
WHERE platform_id = 1 AND price < 30
ORDER BY price;                                       -- 6 rows

-- 8. Every Nintendo-made game: Switch (5) or Switch 2 (6), rated E or E10+
SELECT title, platform_id, esrb_rating
FROM game
WHERE platform_id IN (5, 6)
  AND esrb_rating IN ('E', 'E10+');

-- 9. Halifax customers who joined in 2026
SELECT first_name, last_name, joined_on
FROM customer
WHERE city = 'Halifax' AND joined_on >= '2026-01-01'
ORDER BY joined_on;                                   -- 13 rows

-- 10. The 10 biggest receipt lines (quantity x unit_price)
SELECT sale_id, game_id, quantity * unit_price AS line_total
FROM sale_item
ORDER BY line_total DESC
LIMIT 10;


-- =====================================================================
-- DEMO 9 - INSERT: adding rows
-- =====================================================================
-- One row. List the columns, then the values in the SAME order.
-- game_id is AUTO_INCREMENT, so we leave it out and MySQL picks the next number.
INSERT INTO game (title, genre, platform_id, release_year, price, esrb_rating)
VALUES ('Tetris 99', 'Puzzle', 5, 2019, 0.00, 'E');

-- Several rows in one statement: one (...) per row, separated by commas.
INSERT INTO game (title, genre, platform_id, release_year, price, esrb_rating)
VALUES
    ('Balatro',        'Roguelike', 1, 2024, 19.99, 'E10+'),
    ('Balatro',        'Roguelike', 5, 2024, 19.99, 'E10+'),
    ('Dave the Diver', 'Adventure', 1, 2023, 24.99, 'E10+');

SELECT * FROM game WHERE game_id > 62;     -- our 4 new rows (game_id 63 to 66)

-- Add yourself as a customer. Leave out phone: it's allowed to be NULL.
INSERT INTO customer (first_name, last_name, email, city, province, joined_on, home_store_id)
VALUES ('Sam', 'Student', 'sam.student@example.com', 'Halifax', 'NS', '2026-10-19', 1);

SELECT * FROM customer WHERE customer_id = 601;       -- phone is NULL

-- Sam buys something: a sale (the checkout) ...
INSERT INTO sale (customer_id, store_id, staff_id, sale_date)
VALUES (601, 1, 2, '2026-10-19');

-- ... and a receipt line. We leave out quantity: it has DEFAULT 1.
INSERT INTO sale_item (sale_id, game_id, unit_price)
VALUES (4001, 64, 19.99);

SELECT * FROM sale WHERE sale_id = 4001;
SELECT * FROM sale_item WHERE sale_id = 4001;         -- quantity = 1


-- =====================================================================
-- DEMO 10 - UPDATE: changing rows
-- =====================================================================
-- Habit: SELECT with your WHERE first, so you see exactly which rows will change.
SELECT * FROM customer WHERE customer_id = 601;       -- 1. look: Sam has no phone

UPDATE customer
SET phone = '902-555-0199'
WHERE customer_id = 601;                              -- 2. change (same WHERE)

SELECT * FROM customer WHERE customer_id = 601;       -- 3. check

-- Change several columns at once: Sam moved to Dartmouth
UPDATE customer
SET city = 'Dartmouth',
    home_store_id = 2
WHERE customer_id = 601;

SELECT * FROM customer WHERE customer_id = 601;

-- The new value can use the old one: put two games on sale, 25% off
SELECT game_id, title, price FROM game WHERE game_id IN (65, 66);

UPDATE game
SET price = ROUND(price * 0.75, 2)
WHERE game_id IN (65, 66);                            -- 19.99 -> 14.99,  24.99 -> 18.74

SELECT game_id, title, price FROM game WHERE game_id IN (65, 66);
-- Careful: run that UPDATE again and the prices drop AGAIN. UPDATE doesn't
-- remember anything; it just does the calculation on whatever is there now.


-- =====================================================================
-- DEMO 11 - INSERT and UPDATE: when MySQL says no
-- =====================================================================
-- INSERT
-- 3 columns listed, only 2 values given:
INSERT INTO game (title, genre, platform_id)
VALUES ('Mystery Game', 'Puzzle');         -- EXPECT ERROR 1136: Column count doesn't match value count

-- last_name is NOT NULL:
INSERT INTO customer (first_name, last_name, email, city, province, joined_on, home_store_id)
VALUES ('Alex', NULL, 'alex@example.com', 'Truro', 'NS', '2026-10-19', 3);   -- EXPECT ERROR 1048: Column 'last_name' cannot be null

-- email is UNIQUE, and customer 1 already has this one:
INSERT INTO customer (first_name, last_name, email, city, province, joined_on, home_store_id)
VALUES ('Sophie', 'Leblanc', 'sophia.leblanc@example.com', 'Halifax', 'NS', '2026-10-19', 1);   -- EXPECT ERROR 1062: Duplicate entry

-- platform 99 doesn't exist. The FOREIGN KEY protects us:
INSERT INTO game (title, genre, platform_id, release_year, price, esrb_rating)
VALUES ('Ghost Game', 'Horror', 99, 2026, 59.99, 'M');   -- EXPECT ERROR 1452: Cannot add or update a child row: a foreign key constraint fails

-- UPDATE: the same rules protect it
UPDATE customer SET last_name = NULL
WHERE customer_id = 601;                   -- EXPECT ERROR 1048: Column 'last_name' cannot be null

UPDATE customer SET email = 'sophia.leblanc@example.com'
WHERE customer_id = 601;                   -- EXPECT ERROR 1062: Duplicate entry (customer 1 has that email)

UPDATE customer SET home_store_id = 9
WHERE customer_id = 601;                   -- EXPECT ERROR 1452: Cannot add or update a child row (there is no store 9)

-- Workbench's "Safe Updates" setting: the WHERE must use a KEY column (like game_id).
UPDATE game SET price = 9.99
WHERE title = 'Balatro';                   -- EXPECT ERROR 1175 (in Workbench): You are using safe update mode ...

-- DON'T RUN THIS. With no WHERE, every game in the table gets price 0:
-- UPDATE game SET price = 0;


-- =====================================================================
-- DEMO 12 - DELETE: removing rows
-- =====================================================================
-- Habit: SELECT with your WHERE first, so you see exactly which rows will go.
SELECT * FROM game WHERE game_id = 63;     -- 1. look

DELETE FROM game
WHERE game_id = 63;                        -- 2. delete (same WHERE)

SELECT * FROM game WHERE game_id = 63;     -- 3. check: no rows. Tetris 99 is gone.

-- Delete several rows at once with IN
SELECT * FROM game WHERE game_id IN (65, 66);
DELETE FROM game WHERE game_id IN (65, 66);
SELECT * FROM game WHERE game_id > 62;     -- only 64 (Balatro for PC) is left. Sam bought it.

-- There is no undo. DON'T RUN THIS: with no WHERE, every row goes
-- (the table itself stays, but it's empty):
-- DELETE FROM game;


-- =====================================================================
-- DEMO 13 - DELETE: what protects you
-- =====================================================================
-- 1. Workbench's "Safe Updates" setting: a DELETE must find rows by a KEY column
--    (like game_id). title isn't a key, so Workbench refuses:
DELETE FROM game WHERE title = 'Balatro';  -- EXPECT ERROR 1175 (in Workbench): You are using safe update mode ...
-- Fix: look up the id with a SELECT, then delete by id.
SELECT game_id, title, platform_id FROM game WHERE title = 'Balatro';

-- 2. Foreign keys. Minecraft (game_id 1) has been sold, so sale_item rows point at it:
DELETE FROM game WHERE game_id = 1;        -- EXPECT ERROR 1451: Cannot delete or update a parent row: a foreign key constraint fails

-- Same for Sam: customer 601 has a sale pointing at them.
DELETE FROM customer WHERE customer_id = 601;          -- EXPECT ERROR 1451

-- To remove Sam completely, delete the CHILDREN first, then the parent:
DELETE FROM sale_item WHERE sale_id = 4001;            -- the receipt line
DELETE FROM sale      WHERE sale_id = 4001;            -- the checkout
DELETE FROM customer  WHERE customer_id = 601;         -- now Sam can go
DELETE FROM game      WHERE game_id = 64;              -- and Balatro, now nobody has bought it

SELECT * FROM customer WHERE customer_id = 601;        -- gone
SELECT * FROM game WHERE game_id > 62;                 -- back to the original 62 games


-- =====================================================================
-- YOUR TURN - try these on your own (answers are posted after class)
-- =====================================================================
-- 1. Every game rated 'T', most expensive first.
-- 2. Customers from Sydney or Glace Bay who have no phone number.
--    (careful with AND / OR: use brackets)
-- 3. Games released between 2020 and 2022, sorted by year, then title.
-- 4. Every game with "Edition", "Ultimate" or "Deluxe" in its title.
-- 5. Staff email addresses for store 2, as "full name" and "email" columns.
-- 6. The 3 cheapest games that aren't free.
-- 7. Page 3 of the game list, 10 games per page, sorted by title.
-- 8. INSERT two new games of your choice (one for the Switch 2), then SELECT them.
-- 9. UPDATE: put one of your games on sale (25% off) and change the other one's
--    esrb_rating. Use game_id in the WHERE, and SELECT before and after.
-- 10. DELETE the two games you just added, by game_id. SELECT first!
