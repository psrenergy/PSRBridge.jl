PRAGMA user_version = 1;
PRAGMA foreign_keys = ON;

CREATE TABLE Configuration (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT UNIQUE NOT NULL
) STRICT;

CREATE TABLE HydroPlant (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT UNIQUE NOT NULL,
    initial_volume REAL,
    has_commitment INTEGER DEFAULT 0
) STRICT;

CREATE TABLE HydroPlant_time_series_parameters (
    id INTEGER, 
    date_time TEXT NOT NULL,
    existing INTEGER,
    max_generation REAL,
    FOREIGN KEY(id) REFERENCES HydroPlant(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id, date_time)
) STRICT;

CREATE TABLE ThermalPlant (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT UNIQUE NOT NULL,
    shutdown_cost REAL,
    max_startups INTEGER
) STRICT;

CREATE TABLE ThermalPlant_time_series_parameters (
    id INTEGER, 
    date_time TEXT NOT NULL,
    existing INTEGER,
    max_generation REAL,
    FOREIGN KEY(id) REFERENCES ThermalPlant(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id, date_time)
) STRICT;