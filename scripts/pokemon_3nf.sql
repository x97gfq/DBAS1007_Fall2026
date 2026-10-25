-- =====================================================================
-- DBAS 1007 - Assignment 2 solution: the Pokemon dataset in 3NF
-- Builds the pokemon_3nf database from the normalized design
-- (see notes/a2-pokemon-solution-review.pptx).
-- Run the whole file in Workbench (Ctrl+Shift+Enter). Safe to re-run.
-- =====================================================================

DROP DATABASE IF EXISTS pokemon_3nf;
CREATE DATABASE pokemon_3nf;
USE pokemon_3nf;

-- ---------- Where trainers live (3NF: Region depends on Town, not on Trainer) ----------
CREATE TABLE Region (
    RegionID   INT,
    RegionName VARCHAR(50) NOT NULL,
    PRIMARY KEY (RegionID)
);

CREATE TABLE Town (
    TownID   INT,
    TownName VARCHAR(50) NOT NULL,
    RegionID INT NOT NULL,
    PRIMARY KEY (TownID),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Trainer (
    TrainerID   CHAR(3),
    TrainerName VARCHAR(50) NOT NULL,
    TownID      INT NOT NULL,
    PRIMARY KEY (TrainerID),
    FOREIGN KEY (TownID) REFERENCES Town(TownID)
);

-- ---------- Species facts (same for every Pokemon of that species) ----------
CREATE TABLE Species (
    PokedexNo   INT,
    PokemonName VARCHAR(50) NOT NULL,
    PRIMARY KEY (PokedexNo)
);

CREATE TABLE Type (
    TypeID   INT,
    TypeName VARCHAR(20) NOT NULL,
    PRIMARY KEY (TypeID)
);

CREATE TABLE SpeciesType (            -- many-to-many: Species <-> Type
    PokedexNo INT,
    TypeID    INT,
    PRIMARY KEY (PokedexNo, TypeID),
    FOREIGN KEY (PokedexNo) REFERENCES Species(PokedexNo),
    FOREIGN KEY (TypeID)    REFERENCES Type(TypeID)
);

CREATE TABLE Ability (
    AbilityID   INT,
    AbilityName VARCHAR(30) NOT NULL,
    PRIMARY KEY (AbilityID)
);

CREATE TABLE SpeciesAbility (         -- many-to-many: Species <-> Ability
    PokedexNo INT,
    AbilityID INT,
    PRIMARY KEY (PokedexNo, AbilityID),
    FOREIGN KEY (PokedexNo) REFERENCES Species(PokedexNo),
    FOREIGN KEY (AbilityID) REFERENCES Ability(AbilityID)
);

-- ---------- Individual Pokemon (one row per catch) ----------
CREATE TABLE CaughtPokemon (
    CatchID    INT,
    TrainerID  CHAR(3) NOT NULL,
    PokedexNo  INT NOT NULL,
    Nickname   VARCHAR(30),
    Level      INT,
    DateCaught DATE,
    PRIMARY KEY (CatchID),
    FOREIGN KEY (TrainerID) REFERENCES Trainer(TrainerID),
    FOREIGN KEY (PokedexNo) REFERENCES Species(PokedexNo)
);

CREATE TABLE Move (
    MoveID   INT,
    MoveName VARCHAR(30) NOT NULL,
    PRIMARY KEY (MoveID)
);

CREATE TABLE CatchMove (              -- many-to-many: CaughtPokemon <-> Move
    CatchID INT,                      -- moves belong to the individual: the two Pikachus differ
    MoveID  INT,
    PRIMARY KEY (CatchID, MoveID),
    FOREIGN KEY (CatchID) REFERENCES CaughtPokemon(CatchID),
    FOREIGN KEY (MoveID)  REFERENCES Move(MoveID)
);

-- ---------- Data (every row of pokemon_unnormalized.csv, stored once) ----------

INSERT INTO Region (RegionID, RegionName) VALUES
    (1, 'Kanto'),
    (2, 'Johto'),
    (3, 'Hoenn');

INSERT INTO Town (TownID, TownName, RegionID) VALUES
    (1, 'Pallet Town', 1),
    (2, 'Cerulean City', 1),
    (3, 'New Bark Town', 2),
    (4, 'Goldenrod City', 2),
    (5, 'Littleroot Town', 3);

INSERT INTO Trainer (TrainerID, TrainerName, TownID) VALUES
    ('T01', 'Maya Chen', 1),
    ('T02', 'Owen Brooks', 2),
    ('T03', 'Priya Nair', 3),
    ('T04', 'Liam MacLeod', 4),
    ('T05', 'Sofia Reyes', 5);

INSERT INTO Species (PokedexNo, PokemonName) VALUES
    (1, 'Bulbasaur'),
    (6, 'Charizard'),
    (7, 'Squirtle'),
    (25, 'Pikachu'),
    (39, 'Jigglypuff'),
    (94, 'Gengar'),
    (130, 'Gyarados'),
    (143, 'Snorlax'),
    (152, 'Chikorita'),
    (155, 'Cyndaquil'),
    (196, 'Espeon'),
    (248, 'Tyranitar'),
    (258, 'Mudkip'),
    (282, 'Gardevoir');

INSERT INTO Type (TypeID, TypeName) VALUES
    (1, 'Grass'),
    (2, 'Poison'),
    (3, 'Electric'),
    (4, 'Normal'),
    (5, 'Water'),
    (6, 'Flying'),
    (7, 'Ghost'),
    (8, 'Psychic'),
    (9, 'Fire'),
    (10, 'Rock'),
    (11, 'Dark'),
    (12, 'Fairy');

INSERT INTO SpeciesType (PokedexNo, TypeID) VALUES
    (1, 1),
    (1, 2),
    (6, 9),
    (6, 6),
    (7, 5),
    (25, 3),
    (39, 4),
    (39, 12),
    (94, 7),
    (94, 2),
    (130, 5),
    (130, 6),
    (143, 4),
    (152, 1),
    (155, 9),
    (196, 8),
    (248, 10),
    (248, 11),
    (258, 5),
    (282, 8),
    (282, 12);

INSERT INTO Ability (AbilityID, AbilityName) VALUES
    (1, 'Overgrow'),
    (2, 'Static'),
    (3, 'Immunity'),
    (4, 'Thick Fat'),
    (5, 'Torrent'),
    (6, 'Intimidate'),
    (7, 'Cursed Body'),
    (8, 'Synchronize'),
    (9, 'Blaze'),
    (10, 'Sand Stream'),
    (11, 'Trace'),
    (12, 'Cute Charm'),
    (13, 'Competitive');

INSERT INTO SpeciesAbility (PokedexNo, AbilityID) VALUES
    (1, 1),
    (6, 9),
    (7, 5),
    (25, 2),
    (39, 12),
    (39, 13),
    (94, 7),
    (130, 6),
    (143, 3),
    (143, 4),
    (152, 1),
    (155, 9),
    (196, 8),
    (248, 10),
    (258, 5),
    (282, 8),
    (282, 11);

INSERT INTO CaughtPokemon (CatchID, TrainerID, PokedexNo, Nickname, Level, DateCaught) VALUES
    (1, 'T01', 1, 'Sprout', 14, '2026-01-12'),
    (2, 'T01', 25, 'Sparky', 22, '2026-01-19'),
    (3, 'T01', 143, 'Pillow', 35, '2026-03-02'),
    (4, 'T02', 7, 'Shelly', 12, '2026-02-04'),
    (5, 'T02', 130, 'Riptide', 41, '2026-02-27'),
    (6, 'T02', 94, 'Smirk', 38, '2026-04-15'),
    (7, 'T03', 152, 'Leafy', 10, '2026-01-30'),
    (8, 'T03', 25, 'Volt', 18, '2026-02-11'),
    (9, 'T03', 196, 'Luna', 33, '2026-05-08'),
    (10, 'T04', 155, 'Ember', 11, '2026-02-19'),
    (11, 'T04', 248, 'Boulder', 55, '2026-06-21'),
    (12, 'T04', 143, 'Nap', 40, '2026-07-03'),
    (13, 'T05', 258, 'Splash', 13, '2026-03-14'),
    (14, 'T05', 282, 'Grace', 44, '2026-05-25'),
    (15, 'T05', 39, 'Melody', 16, '2026-06-02'),
    (16, 'T05', 6, 'Blaze', 48, '2026-08-10');

INSERT INTO Move (MoveID, MoveName) VALUES
    (1, 'Tackle'),
    (2, 'Vine Whip'),
    (3, 'Leech Seed'),
    (4, 'Thunder Shock'),
    (5, 'Quick Attack'),
    (6, 'Thunderbolt'),
    (7, 'Rest'),
    (8, 'Body Slam'),
    (9, 'Water Gun'),
    (10, 'Bite'),
    (11, 'Hydro Pump'),
    (12, 'Dragon Rage'),
    (13, 'Shadow Ball'),
    (14, 'Hypnosis'),
    (15, 'Razor Leaf'),
    (16, 'Confusion'),
    (17, 'Psychic'),
    (18, 'Ember'),
    (19, 'Smokescreen'),
    (20, 'Crunch'),
    (21, 'Rock Slide'),
    (22, 'Mud-Slap'),
    (23, 'Moonblast'),
    (24, 'Sing'),
    (25, 'Pound'),
    (26, 'Flamethrower'),
    (27, 'Wing Attack'),
    (28, 'Dragon Claw');

INSERT INTO CatchMove (CatchID, MoveID) VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 4),
    (2, 5),
    (2, 6),
    (3, 7),
    (3, 8),
    (4, 1),
    (4, 9),
    (5, 10),
    (5, 11),
    (5, 12),
    (6, 13),
    (6, 14),
    (7, 1),
    (7, 15),
    (8, 4),
    (8, 5),
    (9, 16),
    (9, 17),
    (10, 1),
    (10, 18),
    (10, 19),
    (11, 20),
    (11, 21),
    (12, 7),
    (12, 8),
    (13, 9),
    (13, 22),
    (14, 17),
    (14, 23),
    (15, 24),
    (15, 25),
    (16, 26),
    (16, 27),
    (16, 28);


-- ---------- Did it work? ----------
SHOW TABLES;                               -- 11 tables

-- Same species, different moves: why Move hangs off CaughtPokemon, not Species
SELECT c.Nickname, m.MoveName
FROM CaughtPokemon c
JOIN CatchMove cm ON cm.CatchID = c.CatchID
JOIN Move m       ON m.MoveID   = cm.MoveID
WHERE c.PokedexNo = 25
ORDER BY c.Nickname, m.MoveName;           -- Sparky knows 3 moves, Volt knows 2
