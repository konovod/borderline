unit uStaticData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uGameTypes, uMap;

const
  RESEARCH_NAMES: array[THumanResearch] of string =
    ('Xplosives', 'Sensors', 'Engines', 'Armor', 'Weapons');
  ALIEN_SHIP_NAMES: array[TAlienShip] of string =
    ('Cruiser', 'Battleship', 'Mine', 'Minesweeper', 'Satellite');

  POP_STATUS_NAMES: array[TPopulationState] of string =
    ('Colonized', 'Colonizable', 'Alien', 'Lifeless');

  SHIP_NAMES: array[THumanShip] of string =
    ('Brander', 'Cruiser', 'Minesweeper', 'Colonizer', 'Dropship', 'Scout');

  RESEARCH_DESC: array[THumanResearch] of string = (
    'Research subatomic physics to find most potentially destructive reactions. Allows to build better mines and branders',
    'Research statistical methods to discover alien signatures and counter their stealth systems. Allows to build better scouts and minesweepers',
    'Better engines can help us to outmaneuver alien ships. Allows to build better branders, scouts and dropships',
    'Research fields and material that can withstand alien weapons. Allows to build better cruisers and dropships',
    'Long-range weapon technologies - from missiles to gravitational disruptors and beyound. Allows to build better cruisers and orbital defenses');

  MONTH_NAMES: array[1..12] of string = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

implementation

end.
