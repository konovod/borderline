unit uGameTypes;

{$mode objfpc}{$H+}

interface


const
  MAX_LEVEL = 20;

  //balance koeffs
  K_LVL = 1.5;
  MINE_MULTIPLIER = 10;

type

  TStarDate = Integer;
  TPriorityLevel = Integer;

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
    Ships: array[THumanShips] of Integer;
    Research: Integer;
    Mines: array of Integer;
  end;


implementation

end.

