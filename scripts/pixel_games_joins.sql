-- DBAS 1007 - Week 8 addendum: JOINs, COUNT and GROUP BY with pixel_games
-- Connect in Workbench: Host 127.0.0.1  Port 13306  User root  Password rootpassword
--
-- HOW TO USE THIS FILE
--   * Start from a fresh database: run scripts/pixel_games.sql (the whole file) first,
--     so your results match the slides. (Last week's INSERTs and DELETEs change the numbers.)
--   * Each "DEMO n" block matches the DEMO n badge on the slides (notes/wk08-addendum-joins.pptx).
--   * Run ONE statement at a time: put the cursor on it and press Ctrl+Enter.
--   * One statement fails ON PURPOSE (marked "EXPECT ERROR"). Read the Output panel.
--   * Everything here is SELECT, so nothing you run can change the data.
--   * These are the tools Assignment 4 needs: 3+ JOINs, plus COUNT and GROUP BY.

USE pixel_games;


-- =====================================================================
-- DEMO 1 - Why JOIN? The data is split on purpose
-- =====================================================================
-- Normalization put each fact in one place. game stores platform_id, a number:
SELECT game_id, title, platform_id FROM game LIMIT 6;

-- The platform NAME lives in platform:
SELECT * FROM platform;

-- JOIN puts them back together. ON says how the rows match: foreign key = primary key.
SELECT game.title, platform.name
FROM game
JOIN platform ON game.platform_id = platform.platform_id;     -- 62 rows, one per game


-- =====================================================================
-- DEMO 2 - Aliases, and naming columns clearly
-- =====================================================================
-- Same query with table aliases (g, p): less typing. JOIN on its own means INNER JOIN.
SELECT g.title, p.name AS platform, p.maker, g.price
FROM game g
JOIN platform p ON g.platform_id = p.platform_id
WHERE p.maker = 'Nintendo'                                     -- WHERE and ORDER BY work as usual
ORDER BY g.price DESC;                                         -- 18 rows, Mario Kart World first

-- Both tables have a customer_id column. Which one do you mean?
SELECT customer_id, first_name, sale_date
FROM sale s
JOIN customer c ON s.customer_id = c.customer_id;              -- EXPECT ERROR 1052: Column 'customer_id' in field list is ambiguous

-- Fix: say which table it comes from.
SELECT s.customer_id, c.first_name, s.sale_date
FROM sale s
JOIN customer c ON s.customer_id = c.customer_id
LIMIT 5;


-- =====================================================================
-- DEMO 3 - More than two tables: follow the foreign keys
-- =====================================================================
-- Who bought it, where, and who rang it in: sale + customer + store + staff
SELECT s.sale_id, s.sale_date, c.first_name, c.last_name,
       st.name AS store, sf.first_name AS cashier
FROM sale s
JOIN customer c ON s.customer_id = c.customer_id
JOIN store st   ON s.store_id    = st.store_id
JOIN staff sf   ON s.staff_id    = sf.staff_id
WHERE s.sale_id = 4000;                                        -- Logan Gillis, Truro, Riley

-- The full receipt for sale 4000: five tables, four JOINs
SELECT c.first_name, c.last_name, g.title, p.name AS platform,
       si.quantity, si.unit_price
FROM sale s
JOIN customer c   ON s.customer_id = c.customer_id
JOIN sale_item si ON si.sale_id    = s.sale_id
JOIN game g       ON si.game_id    = g.game_id
JOIN platform p   ON g.platform_id = p.platform_id
WHERE s.sale_id = 4000;                                        -- Stardew Valley 19.99, Hades 31.99


-- =====================================================================
-- DEMO 4 - LEFT JOIN: keep every row on the left, even with no match
-- =====================================================================
-- INNER JOIN only keeps customers who have a sale:
SELECT c.first_name, c.last_name, s.sale_id
FROM customer c
JOIN sale s ON s.customer_id = c.customer_id;                  -- 4,000 rows

-- LEFT JOIN keeps every customer. No sale? The sale columns come back NULL.
SELECT c.first_name, c.last_name, s.sale_id
FROM customer c
LEFT JOIN sale s ON s.customer_id = c.customer_id
ORDER BY s.sale_id;                                            -- 4,032 rows: the NULLs sort first

-- The classic pattern: LEFT JOIN, then keep only the rows with no match
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN sale s ON s.customer_id = c.customer_id
WHERE s.sale_id IS NULL;                                       -- 32 customers who never bought anything

-- Games nobody has bought yet
SELECT g.game_id, g.title
FROM game g
LEFT JOIN sale_item si ON si.game_id = g.game_id
WHERE si.sale_id IS NULL;                                      -- Metroid Prime 4, Pokemon Legends: Z-A


-- =====================================================================
-- DEMO 5 - Aggregate functions: many rows in, ONE row out
-- =====================================================================
SELECT COUNT(*)              AS games,
       MIN(price)            AS cheapest,
       MAX(price)            AS priciest,
       ROUND(AVG(price), 2)  AS avg_price
FROM game;                                                     -- 62, 0.00, 109.99, 70.70

-- WHERE runs first, so it filters the rows BEFORE they're counted
SELECT COUNT(*) AS switch_2_games
FROM game
WHERE platform_id = 6;                                         -- 4


-- =====================================================================
-- DEMO 6 - GROUP BY: one result row per group
-- =====================================================================
-- How many games in each genre?
SELECT genre, COUNT(*) AS games
FROM game
GROUP BY genre
ORDER BY games DESC;                                           -- 13 rows, RPG first with 11

-- The rule: every column in SELECT must be in GROUP BY or inside an aggregate.
-- Which title should MySQL show for the whole RPG group? It refuses to guess:
SELECT genre, title, COUNT(*)
FROM game
GROUP BY genre;                                                -- EXPECT ERROR 1055: ... isn't in GROUP BY

-- HAVING filters GROUPS (WHERE filters rows): genres with at least 6 games
SELECT genre, COUNT(*) AS games
FROM game
GROUP BY genre
HAVING COUNT(*) >= 6
ORDER BY games DESC;                                           -- 5 rows


-- =====================================================================
-- DEMO 7 - JOIN + GROUP BY: real reports
-- =====================================================================
-- Games and average price per platform, by NAME
SELECT p.name AS platform, COUNT(*) AS games, ROUND(AVG(g.price), 2) AS avg_price
FROM game g
JOIN platform p ON g.platform_id = p.platform_id
GROUP BY p.name
ORDER BY games DESC;                                           -- PS5 15, Switch 14, PC 13 ...

-- Sales and revenue per store
SELECT st.name AS store,
       COUNT(DISTINCT s.sale_id)        AS sales,
       SUM(si.quantity * si.unit_price) AS revenue
FROM store st
JOIN sale s       ON s.store_id = st.store_id
JOIN sale_item si ON si.sale_id = s.sale_id
GROUP BY st.name
ORDER BY revenue DESC;                                         -- Halifax 1,189 sales, $137,726.12


-- =====================================================================
-- DEMO 8 - The same patterns on the Pokemon database (Assignment 4)
-- =====================================================================
-- Run scripts/pokemon_3nf.sql (the whole file) first if you don't have it.
USE pokemon_3nf;

-- JOIN through a junction table: every species with its types
SELECT s.PokemonName, t.TypeName
FROM Species s
JOIN SpeciesType st ON st.PokedexNo = s.PokedexNo
JOIN Type t         ON t.TypeID     = st.TypeID
ORDER BY s.PokemonName, t.TypeName;                            -- 21 rows: two-type species appear twice

-- JOIN + GROUP BY: how many species have each type?
SELECT t.TypeName, COUNT(*) AS species
FROM Type t
JOIN SpeciesType st ON st.TypeID = t.TypeID
GROUP BY t.TypeName
ORDER BY species DESC, t.TypeName;                             -- Water 3, then seven types with 2

USE pixel_games;


-- =====================================================================
-- YOUR TURN - try these on your own (answers are posted after class)
-- =====================================================================
-- 1. Every game with its platform name and maker, sorted by maker, then title.
-- 2. Every staff member's full name and role, with the NAME of their store.
-- 3. Every sale at Pixel Games Sydney in September 2026: sale_id, date and the
--    customer's first and last name. (Three tables.)
-- 4. Customers from Halifax who have never bought anything. (LEFT JOIN)
-- 5. How many customers live in each province? Most first.
-- 6. How many staff work at each store? Show the store NAME, not the id.
-- 7. Copies sold per genre (SUM of quantity), best-selling genre first.
-- 8. pokemon_3nf: every trainer with the nickname and species name of each
--    Pokemon they caught.
