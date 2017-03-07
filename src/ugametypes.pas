unit uGameTypes;

{$mode objfpc}{$H+}

interface


const
  MAX_LEVEL = 20;

type

  TLevel = 0..MAX_LEVEL;

  THumanResearch = (Explosives, Sensors, Engines, Armor, Weapons);
  THumanShips = (Brander, Cruiser, Minesweeper, Colonizer, TroopTransport, Scout);
  TAlienResearch = (AlienCruiser, AlienBattleship, AlienMines, AlienMinesweeper, AlienOrbital);

  THumanResearchLevel = array[THumanResearch] of TLevel;
  TAlienResearchLevel = array[TAlienResearch] of TLevel;

  TSquadron = array[TLevel] of Integer;
  TFleetData = array[THumanShips] of TSquadron;

  TMinesData = array of TSquadron;

  TPriorities = record
    Ships: array[THumanShips] of Single;
    Research: single;
    Mines: array of Single;
  end;


implementation

end.

