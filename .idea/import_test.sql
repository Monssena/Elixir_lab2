-- Creation of a new test base
CREATE DATABASE test;

USE test;

-- Creating the tables
CREATE TABLE sectors
(
    id                   INT(11)      NOT NULL AUTO_INCREMENT,
    coordinates          VARCHAR(255) NOT NULL,
    light_intensity      FLOAT        NOT NULL,
    foreign_objects      INT          NOT NULL,
    star_objects         INT          NOT NULL,
    unidentified_objects INT          NOT NULL,
    identified_objects   INT          NOT NULL,
    notes                TEXT,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE objects
(
    id       INT(11)      NOT NULL AUTO_INCREMENT,
    type     VARCHAR(255) NOT NULL,
    accuracy FLOAT        NOT NULL,
    quantity INT          NOT NULL,
    time     TIME         NOT NULL,
    date     DATE         NOT NULL,
    notes    TEXT,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE natural_objects
(
    id              INT(11)      NOT NULL AUTO_INCREMENT,
    type            VARCHAR(255) NOT NULL,
    galaxy          VARCHAR(255) NOT NULL,
    accuracy        FLOAT        NOT NULL,
    light_flux      FLOAT        NOT NULL,
    related_objects VARCHAR(255),
    notes           TEXT,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE positions
(
    id             INT(11)      NOT NULL AUTO_INCREMENT,
    earth_position VARCHAR(255) NOT NULL,
    sun_position   VARCHAR(255) NOT NULL,
    moon_position  VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE connections
(
    id                 INT(11) NOT NULL AUTO_INCREMENT,
    id_sectors         INT(11) NOT NULL,
    id_objects         INT(11) NOT NULL,
    id_natural_objects INT(11) NOT NULL,
    id_positions       INT(11) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_sectors) REFERENCES sectors (id),
    FOREIGN KEY (id_objects) REFERENCES objects (id),
    FOREIGN KEY (id_natural_objects) REFERENCES natural_objects (id),
    FOREIGN KEY (id_positions) REFERENCES positions (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- Inserting initial data into sectors
INSERT INTO sectors (coordinates, light_intensity, foreign_objects, star_objects, unidentified_objects, identified_objects, notes)
VALUES
    ('Coord1', 123.4, 5, 10, 2, 8, 'Note1'),
    ('Coord2', 223.4, 3, 12, 1, 11, 'Note2'),
    ('Coord3', 323.4, 2, 8, 0, 8, 'Note3'),
    ('Coord4', 423.4, 4, 14, 3, 11, 'Note4'),
    ('Coord5', 523.4, 1, 5, 1, 4, 'Note5');

-- Inserting initial data into objects
INSERT INTO objects (type, accuracy, quantity, time, date, notes)
VALUES
    ('Type1', 0.9, 10, '10:00:00', '2023-01-01', 'Note1'),
    ('Type2', 0.8, 15, '11:00:00', '2023-01-02', 'Note2'),
    ('Type3', 0.95, 8, '12:00:00', '2023-01-03', 'Note3'),
    ('Type4', 0.85, 12, '13:00:00', '2023-01-04', 'Note4'),
    ('Type5', 0.92, 5, '14:00:00', '2023-01-05', 'Note5');

-- Inserting initial data into natural_objects
INSERT INTO natural_objects (type, galaxy, accuracy, light_flux, related_objects, notes)
VALUES
    ('NaturalType1', 'Galaxy1', 0.97, 123.45, 'Related1', 'Note1'),
    ('NaturalType2', 'Galaxy2', 0.89, 234.56, 'Related2', 'Note2'),
    ('NaturalType3', 'Galaxy3', 0.93, 345.67, 'Related3', 'Note3'),
    ('NaturalType4', 'Galaxy4', 0.88, 456.78, 'Related4', 'Note4'),
    ('NaturalType5', 'Galaxy5', 0.95, 567.89, 'Related5', 'Note5');

-- Inserting initial data into positions
INSERT INTO positions (earth_position, sun_position, moon_position)
VALUES
    ('EarthPos1', 'SunPos1', 'MoonPos1'),
    ('EarthPos2', 'SunPos2', 'MoonPos2'),
    ('EarthPos3', 'SunPos3', 'MoonPos3'),
    ('EarthPos4', 'SunPos4', 'MoonPos4'),
    ('EarthPos5', 'SunPos5', 'MoonPos5');

-- Inserting initial data into connections
INSERT INTO connections (id_sectors, id_objects, id_natural_objects, id_positions)
VALUES
    (1, 1, 1, 1),
    (2, 2, 2, 2),
    (3, 3, 3, 3),
    (4, 4, 4, 4),
    (5, 5, 5, 5);

-- Procedure for joining tables
DELIMITER //

CREATE PROCEDURE proc1(table1 VARCHAR(255), table2 VARCHAR(255))
BEGIN
    IF table1 = "Sectors" THEN
        IF table2 = "Objects" THEN
            SELECT s.*, o.*
            FROM sectors s
                     INNER JOIN connections c ON s.id = c.id_sectors
                     INNER JOIN objects o ON c.id_objects = o.id;
        END IF;
        IF table2 = "Positions" THEN
            SELECT s.*, p.*
            FROM sectors s
                     INNER JOIN connections c ON s.id = c.id_sectors
                     INNER JOIN positions p ON c.id_positions = p.id;
        END IF;
        IF table2 = "Natural_objects" THEN
            SELECT s.*, n.*
            FROM sectors s
                     INNER JOIN connections c ON s.id = c.id_sectors
                     INNER JOIN natural_objects n ON c.id_natural_objects = n.id;
        END IF;
    END IF;
    IF table1 = "Objects" THEN
        IF table2 = "Sectors" THEN
            SELECT o.*, s.*
            FROM objects o
                     INNER JOIN connections c ON o.id = c.id_objects
                     INNER JOIN sectors s ON c.id_sectors = s.id;
        END IF;
        IF table2 = "Positions" THEN
            SELECT o.*, p.*
            FROM objects o
                     INNER JOIN connections c ON o.id = c.id_objects
                     INNER JOIN positions p ON c.id_positions = p.id;
        END IF;
        IF table2 = "Natural_objects" THEN
            SELECT o.*, n.*
            FROM objects o
                     INNER JOIN connections c ON o.id = c.id_objects
                     INNER JOIN natural_objects n ON c.id_natural_objects = n.id;
        END IF;
    END IF;
    IF table1 = "Positions" THEN
        IF table2 = "Sectors" THEN
            SELECT p.*, s.*
            FROM positions p
                     INNER JOIN connections c ON p.id = c.id_positions
                     INNER JOIN sectors s ON c.id_sectors = s.id;
        END IF;
        IF table2 = "Objects" THEN
            SELECT p.*, o.*
            FROM positions p
                     INNER JOIN connections c ON p.id = c.id_positions
                     INNER JOIN objects o ON c.id_objects = o.id;
        END IF;
        IF table2 = "Natural_objects" THEN
            SELECT p.*, n.*
            FROM positions p
                     INNER JOIN connections c ON p.id = c.id_positions
                     INNER JOIN natural_objects n ON c.id_natural_objects = n.id;
        END IF;
    END IF;
    IF table1 = "Natural_objects" THEN
        IF table2 = "Sectors" THEN
            SELECT n.*, s.*
            FROM natural_objects n
                     INNER JOIN connections c ON n.id = c.id_natural_objects
                     INNER JOIN sectors s ON c.id_sectors = s.id;
        END IF;
        IF table2 = "Objects" THEN
            SELECT n.*, o.*
            FROM natural_objects n
                     INNER JOIN connections c ON n.id = c.id_natural_objects
                     INNER JOIN objects o ON c.id_objects = o.id;
        END IF;
        IF table2 = "Positions" THEN
            SELECT n.*, p.*
            FROM natural_objects n
                     INNER JOIN connections c ON n.id = c.id_natural_objects
                     INNER JOIN positions p ON c.id_positions = p.id;
        END IF;
    END IF;
END //
DELIMITER ;
