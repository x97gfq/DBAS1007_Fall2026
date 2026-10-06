-- DBAS 1007 - Week 5: SQL DDL Review + Your First SELECTs
-- Connect in Workbench: Host 127.0.0.1  Port 13306  User root  Password rootpassword
--
-- HOW TO USE THIS FILE
--   * Each "DEMO n" block matches the DEMO n badge on the slides.
--   * Run ONE statement at a time: put the cursor on it and press Ctrl+Enter.
--   * Some statements fail ON PURPOSE (marked "EXPECT ERROR"). Read the
--     Output panel at the bottom of Workbench each time.
--   * Don't run the whole file with Ctrl+Shift+Enter (the lightning bolt).
--     Workbench stops at the first error.


-- =====================================================================
-- DEMO 0 - Warm-up: you've had a database since week 1
-- =====================================================================
-- appdb.contacts was created by Docker's initdb script.
SELECT * FROM appdb.contacts;

SELECT first_name, email
FROM appdb.contacts
WHERE last_name = 'Smith';


-- =====================================================================
-- DEMO 1 - CREATE DATABASE
-- =====================================================================
SHOW DATABASES;

CREATE DATABASE game_shop;

SHOW DATABASES;            -- game_shop is now in the list (refresh the Schemas panel too)


-- =====================================================================
-- DEMO 2 - Run it again...
-- =====================================================================
CREATE DATABASE game_shop; -- EXPECT ERROR 1007: Can't create database 'game_shop'; database exists


-- =====================================================================
-- DEMO 3 - IF NOT EXISTS / IF EXISTS
-- =====================================================================
CREATE DATABASE IF NOT EXISTS game_shop;   -- no error, just a WARNING (yellow triangle)
SHOW WARNINGS;                             -- 1007 Can't create database ... database exists

DROP DATABASE game_shop;                   -- gone
DROP DATABASE game_shop;                   -- EXPECT ERROR 1008: Can't drop database; database doesn't exist
DROP DATABASE IF EXISTS game_shop;         -- no error, just a warning

-- The "rerunnable" pattern: safe to run any number of times
DROP DATABASE IF EXISTS game_shop;
CREATE DATABASE game_shop;

USE game_shop;                             -- every statement below now runs inside game_shop
SELECT DATABASE();                         -- which database am I in?


-- =====================================================================
-- DEMO 4 - CREATE USER
-- =====================================================================
-- A MySQL account is 'username'@'host'.
-- '%' means "from any host". We need it because Workbench reaches the
-- Docker container through the network, not from inside it.
CREATE USER 'shop_app'@'%'    IDENTIFIED BY 'apppass';
CREATE USER 'shop_reader'@'%' IDENTIFIED BY 'readpass';

CREATE USER 'shop_reader'@'%' IDENTIFIED BY 'readpass';               -- EXPECT ERROR 1396: Operation CREATE USER failed
CREATE USER IF NOT EXISTS 'shop_reader'@'%' IDENTIFIED BY 'readpass'; -- warning instead of error

-- Your first SELECT on a system table: who can log in?
SELECT user, host FROM mysql.user;


-- =====================================================================
-- DEMO 5 - Permissions: GRANT, SHOW GRANTS, REVOKE
-- =====================================================================
-- A new user can log in but can't do anything yet.
SHOW GRANTS FOR 'shop_reader'@'%';         -- only USAGE (= no privileges)

-- The app needs to read and change data.
GRANT SELECT, INSERT, UPDATE, DELETE ON game_shop.* TO 'shop_app'@'%';

-- The reader only needs to look.
GRANT SELECT ON game_shop.* TO 'shop_reader'@'%';

SHOW GRANTS FOR 'shop_app'@'%';
SHOW GRANTS FOR 'shop_reader'@'%';

-- Oops: gave the reader too much. Take it back.
GRANT INSERT ON game_shop.* TO 'shop_reader'@'%';
SHOW GRANTS FOR 'shop_reader'@'%';
REVOKE INSERT ON game_shop.* FROM 'shop_reader'@'%';
SHOW GRANTS FOR 'shop_reader'@'%';


-- =====================================================================
-- DEMO 6 - CREATE TABLE
-- =====================================================================
USE game_shop;

CREATE TABLE game (
    game_id      INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(100)  NOT NULL,
    genre        VARCHAR(30)   NOT NULL,
    platform     VARCHAR(20)   NOT NULL,
    release_year INT           NOT NULL,
    price        DECIMAL(5,2)  NOT NULL,
    in_stock     INT           NOT NULL DEFAULT 0
);

SHOW TABLES;
DESCRIBE game;


-- =====================================================================
-- DEMO 7 - CREATE TABLE IF NOT EXISTS (and its gotcha)
-- =====================================================================
CREATE TABLE game (game_id INT);                 -- EXPECT ERROR 1050: Table 'game' already exists

CREATE TABLE IF NOT EXISTS game (game_id INT);   -- warning only

-- GOTCHA: IF NOT EXISTS only checks the NAME. It does NOT update the table.
CREATE TABLE IF NOT EXISTS game (
    game_id     INT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(100) NOT NULL,
    esrb_rating CHAR(1)                          -- new column?
);
DESCRIBE game;                                   -- no esrb_rating! The statement was skipped.


-- =====================================================================
-- DEMO 8 - DROP TABLE IF EXISTS: the rerunnable script pattern
-- =====================================================================
-- Want to really change the design (while there's no data to lose)?
-- Drop it, then create it again.
DROP TABLE IF EXISTS game;

CREATE TABLE game (
    game_id      INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(100)  NOT NULL,
    genre        VARCHAR(30)   NOT NULL,
    platform     VARCHAR(20)   NOT NULL,
    release_year INT           NOT NULL,
    price        DECIMAL(5,2)  NOT NULL,
    in_stock     INT           NOT NULL DEFAULT 0
);

DESCRIBE game;

-- (Real databases with real data use ALTER TABLE instead. Coming soon.)


-- =====================================================================
-- DEMO 9 - YOUR TURN (Part A of game_shop_practice.sql): customer table
-- =====================================================================
-- Students build the customer table on their own. Instructor version:
CREATE TABLE IF NOT EXISTS customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    joined_on   DATE         NOT NULL
);

INSERT INTO customer (first_name, last_name, email, joined_on)
VALUES
    ('Ava',  'MacDonald', 'ava@example.com',  '2026-09-02'),
    ('Liam', 'Chen',      'liam@example.com', '2026-09-15'),
    ('Noor', 'Haddad',    'noor@example.com', '2026-10-01');

INSERT INTO customer (first_name, last_name, email, joined_on)
VALUES ('Ava', 'Smith', 'ava@example.com', '2026-10-05');   -- EXPECT ERROR 1062: Duplicate entry (UNIQUE)

SELECT * FROM customer;


-- =====================================================================
-- DEMO 10 - INSERT
-- =====================================================================
-- One row. List the columns, then the values in the SAME order.
-- No game_id: AUTO_INCREMENT fills it in.
INSERT INTO game (title, genre, platform, release_year, price, in_stock)
VALUES ('Minecraft', 'Sandbox', 'PC', 2011, 29.99, 12);

SELECT * FROM game;

-- Many rows in one statement: separate them with commas.
-- Note 'Baldur''s Gate 3': two single quotes = one apostrophe.
INSERT INTO game (title, genre, platform, release_year, price, in_stock)
VALUES
    ('The Legend of Zelda: Tears of the Kingdom', 'Adventure',  'Switch', 2023, 89.99,  4),
    ('Mario Kart 8 Deluxe',                       'Racing',     'Switch', 2017, 79.99,  9),
    ('Stardew Valley',                            'Simulation', 'PC',     2016, 19.99, 15),
    ('Hades',                                     'Roguelike',  'PC',     2020, 31.99,  6),
    ('Elden Ring',                                'RPG',        'PS5',    2022, 79.99,  3),
    ('Animal Crossing: New Horizons',             'Simulation', 'Switch', 2020, 79.99,  0),
    ('Hollow Knight',                             'Platformer', 'PC',     2017, 19.99,  8),
    ('Celeste',                                   'Platformer', 'Switch', 2018, 24.99,  5),
    ('Forza Horizon 5',                           'Racing',     'Xbox',   2021, 69.99,  7),
    ('Baldur''s Gate 3',                          'RPG',        'PC',     2023, 79.99, 10),
    ('Spider-Man 2',                              'Action',     'PS5',    2023, 89.99,  2),
    ('Portal 2',                                  'Puzzle',     'PC',     2011, 12.99, 11),
    ('Super Smash Bros. Ultimate',                'Fighting',   'Switch', 2018, 79.99,  6),
    ('Halo Infinite',                             'Shooter',    'Xbox',   2021, 59.99,  1);

-- Leave out in_stock: the DEFAULT (0) is used.
INSERT INTO game (title, genre, platform, release_year, price)
VALUES ('Tetris Effect', 'Puzzle', 'PC', 2018, 24.99);

-- NOT NULL in action
INSERT INTO game (title, genre, platform, release_year, price)
VALUES ('Mystery Game', NULL, 'PC', 2024, 9.99);   -- EXPECT ERROR 1048: Column 'genre' cannot be null

SELECT * FROM game;                                  -- 16 rows


-- =====================================================================
-- DEMO 11 - Permissions, for real
-- =====================================================================
-- In Workbench: Home > + > new connection
--   Host 127.0.0.1  Port 13306  User shop_reader  Password readpass
-- Then, in THAT connection's tab:
--
--   SELECT * FROM game_shop.game;                          -- works
--   INSERT INTO game_shop.game (title, genre, platform, release_year, price)
--   VALUES ('Hack', 'Hack', 'PC', 2026, 0);                -- ERROR 1142: INSERT command denied
--   DROP TABLE game_shop.game;                             -- ERROR 1142: DROP command denied
--   SHOW DATABASES;                                        -- only sees game_shop (+ system schemas)
--
-- Close it and come back to the root connection.


-- =====================================================================
-- DEMO 12 - SELECT: choosing columns
-- =====================================================================
USE game_shop;

SELECT * FROM game;                     -- * = every column

SELECT title, price FROM game;          -- just the columns you need, in the order you list them

SELECT price, title FROM game;          -- order is up to you

-- Aliases rename a column in the RESULT (the table doesn't change)
SELECT title AS game, price AS 'price ($)'
FROM game;

-- Calculated columns: price with Nova Scotia HST (14%)
SELECT title, price, ROUND(price * 1.14, 2) AS price_with_hst
FROM game;


-- =====================================================================
-- DEMO 13 - WHERE: choosing rows
-- =====================================================================
SELECT * FROM game WHERE platform = 'Switch';     -- text goes in 'single quotes'

SELECT * FROM game WHERE price < 30;              -- numbers don't

SELECT title, in_stock FROM game WHERE in_stock = 0;

SELECT * FROM game WHERE platform <> 'PC';        -- <> means "not equal" (!= works too)

-- AND: both must be true
SELECT * FROM game
WHERE platform = 'PC' AND release_year >= 2020;

-- OR: either can be true
SELECT * FROM game
WHERE genre = 'Racing' OR genre = 'Fighting';

-- Mixing AND + OR: use parentheses!
SELECT title, genre, release_year FROM game
WHERE genre = 'Racing' OR genre = 'Fighting' AND release_year >= 2018;     -- not what you meant?

SELECT title, genre, release_year FROM game
WHERE (genre = 'Racing' OR genre = 'Fighting') AND release_year >= 2018;   -- what you meant


-- =====================================================================
-- DEMO 14 - ORDER BY and LIMIT
-- =====================================================================
SELECT title, price FROM game ORDER BY price;            -- ASC (low to high) is the default

SELECT title, price FROM game ORDER BY price DESC;       -- high to low

SELECT title, release_year, price FROM game
ORDER BY release_year DESC, title;                        -- newest first, then A-Z within a year

-- Top 3 most expensive games
SELECT title, price FROM game
ORDER BY price DESC
LIMIT 3;                                                  -- five games tie at 79.99... which one is #3?

-- Add a tie-breaker so the answer is always the same
SELECT title, price FROM game
ORDER BY price DESC, title
LIMIT 3;

-- Clause order matters: SELECT ... FROM ... WHERE ... ORDER BY ... LIMIT
SELECT title, price FROM game
WHERE platform = 'Switch'
ORDER BY price
LIMIT 2;


-- =====================================================================
-- DEMO 15 - DISTINCT, IN, BETWEEN, LIKE
-- =====================================================================
SELECT platform FROM game;                               -- repeats
SELECT DISTINCT platform FROM game;                      -- each value once
SELECT DISTINCT genre FROM game ORDER BY genre;

-- IN: shorter than a pile of ORs
SELECT title, platform FROM game
WHERE platform IN ('PS5', 'Xbox');

-- BETWEEN includes both ends
SELECT title, price FROM game
WHERE price BETWEEN 20 AND 40;

-- LIKE: pattern matching.  %  = any number of characters
SELECT title FROM game WHERE title LIKE 'S%';            -- starts with S
SELECT title FROM game WHERE title LIKE '%2';            -- ends with 2
SELECT title FROM game WHERE title LIKE '%:%';           -- contains a colon

-- Sneak peek at next week: counting rows
SELECT COUNT(*) AS games_in_shop FROM game;


-- =====================================================================
-- INSTRUCTOR RESET - run before class to start clean
-- =====================================================================
-- DROP DATABASE IF EXISTS game_shop;
-- DROP USER IF EXISTS 'shop_app'@'%';
-- DROP USER IF EXISTS 'shop_reader'@'%';
