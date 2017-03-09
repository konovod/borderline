unit uGameTypes;

{$mode objfpc}{$H+}

interface


const
  MAX_RES_LEVEL = 20;
  MAX_POWER_LEVEL = 30;

  //balance koeffs
  K_LVL = 1.5;
  MINE_MULTIPLIER = 10;

type

  TStarDate = Integer;
  TPriorityLevel = Integer;

  TResearchLevel = 0..MAX_RES_LEVEL;
  TPowerLevel = 0..MAX_POWER_LEVEL;

  THumanResearch = (Explosives, Sensors, Engines, Armor, Weapons);
  THumanShips = (Brander, Cruiser, Minesweeper, Colonizer, TroopTransport, Scout);
  TAlienResearch = (AlienCruiser, AlienBattleship, AlienMines, AlienMinesweeper, AlienOrbital);

  THumanResearchLevel = array[THumanResearch] of TResearchLevel;
  TAlienResearchLevel = array[TAlienResearch] of TResearchLevel;

  TSquadron = array[TPowerLevel] of Integer;
  TFleetData = array[THumanShips] of TSquadron;

  TMinesData = array of TSquadron;

  TPriorities = record
    Ships: array[THumanShips] of Integer;
    Research: Integer;
    Mines: array of Integer;
  end;


implementation

end.

