-- =====================================================================
-- DBAS 1007 - Pokemon database in 3NF
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

