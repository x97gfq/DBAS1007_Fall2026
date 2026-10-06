-- DBAS 1007 - Week 5 Practice: game_shop
-- Connect in Workbench: Host 127.0.0.1  Port 13306  User root  Password rootpassword


-- =====================================================================
-- SETUP - select this whole block and press Ctrl+Shift+Enter
-- =====================================================================
-- It's a "rerunnable" script: DROP ... IF EXISTS first, so you can run
-- it again any time to get a fresh copy of the database.

DROP DATABASE IF EXISTS game_shop;
CREATE DATABASE game_shop;
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

INSERT INTO game (title, genre, platform, release_year, price, in_stock)
VALUES
    ('Minecraft',                                 'Sandbox',    'PC',     2011, 29.99, 12),
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
    ('Halo Infinite',                             'Shooter',    'Xbox',   2021, 59.99,  1),
    ('Tetris Effect',                             'Puzzle',     'PC',     2018, 24.99,  0);

SELECT * FROM game;   -- you should see 16 rows

-- ===================== end of setup =====================


-- =====================================================================
-- PART A - DDL: build the customer table yourself
-- =====================================================================
-- Run each statement with Ctrl+Enter.

-- A1. Write a CREATE TABLE IF NOT EXISTS statement for a table named customer:
--       customer_id  whole number, auto-numbered, primary key
--       first_name   text up to 50 characters, required
--       last_name    text up to 50 characters, required
--       email        text up to 100 characters, required, no two customers the same (UNIQUE)
--       joined_on    a date, required



-- A2. DESCRIBE your table. Does it match the list above?



-- A3. INSERT three customers in ONE statement. Dates look like '2026-10-05'.



-- A4. Try inserting a 4th customer with the SAME email as one you already
--     added. What error do you get? Which constraint stopped it?



-- A5. Run your CREATE TABLE IF NOT EXISTS from A1 again. Error or warning?
--     Now run it WITHOUT "IF NOT EXISTS". What changes?



-- A6. SELECT every customer, newest joined_on first.




-- =====================================================================
-- PART B - SELECT challenges (use the game table)
-- =====================================================================
-- Write ONE SELECT for each. The expected number of rows is in [brackets]
-- so you can check yourself.

-- B1. Every game on PC.                                                     [7]


-- B2. Just the title and price of every game, cheapest first.               [16]


-- B3. Titles of games that are out of stock (in_stock is 0).               [2]


-- B4. Each platform, listed once.                                           [4]


-- B5. The 3 newest games (title and release_year).                          [3]


-- B6. Games under $25 on any platform, showing title, platform and price.   [5]


-- B7. Switch games that cost more than $50.                                 [4]


-- B8. Games whose title contains a colon ':'.                               [2]


-- B9. Racing OR Fighting games released in 2018 or later.                   [2]
--     (Careful: you'll need parentheses.)


-- B10. Games on PS5 or Xbox, using IN.                                      [4]


-- B11. Games priced from $20 to $40, using BETWEEN, most expensive first.   [4]


-- B12. Title, price, and the price with 14% HST as a column called
--      price_with_hst (rounded to 2 decimals), for Switch games only.       [5]


-- STRETCH
-- S1. Which genres do we sell? Each genre once, A to Z.                     [11]
-- S2. The single cheapest game that is actually in stock.                   [1]
-- S3. Games that cost under $30 AND have at least 10 copies.               [3]
