PRAGMA user_version = 1;
PRAGMA foreign_keys = ON;

CREATE TABLE Configuration (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT UNIQUE NOT NULL
) STRICT;

CREATE TABLE HydroPlant (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT UNIQUE NOT NULL,
    static_vector_float REAL,
    static_vector_int INTEGER,
    static_vector_bool INTEGER
) STRICT;

CREATE TABLE HydroPlant_time_series_parameters (
    id INTEGER, 
    date_time TEXT NOT NULL,
    time_series_float REAL,
    time_series_int INTEGER,
    time_series_bool INTEGER,
    FOREIGN KEY(id) REFERENCES HydroPlant(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id, date_time)
) STRICT;

CREATE TABLE ThermalPlant (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT UNIQUE NOT NULL,
    static_vector_float REAL,
    static_vector_int INTEGER,
    static_vector_bool INTEGER
) STRICT;

CREATE TABLE ThermalPlant_time_series_parameters (
    id INTEGER, 
    date_time TEXT NOT NULL,
    time_series_float REAL,
    time_series_int INTEGER,
    time_series_bool INTEGER,
    FOREIGN KEY(id) REFERENCES ThermalPlant(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id, date_time)
) STRICT;