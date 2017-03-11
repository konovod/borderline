unit uGameTypes;

{$mode objfpc}{$H+}

interface


const
  MAX_RES_LEVEL = 20;
  MAX_POWER_LEVEL = 30;

  //balance koeffs
  K_LVL = 1.5;
  MINE_MULTIPLIER = 10;
  RESEARCH_CHANCE = 0.05;
  ALIEN_RESEARCH_CHANCE = 0.02;
  HUMAN_DAMAGE_K = 1;
  ALIEN_DAMAGE_K = 0.3;
  ALIEN_OVERSEE = 2;



type

  TStarDate = Integer;
  TPriorityLevel = Integer;

  TResearchLevel = 0..MAX_RES_LEVEL;
  TPowerLevel = 0..MAX_POWER_LEVEL;

  THumanResearch = (Explosives, Sensors, Engines, Armor, Weapons);
  THumanShip = (Brander, Cruiser, Minesweeper, Colonizer, TroopTransport, Scout);
  THumanShips = set of THumanShip;


  TAlienResearch = (AlienCruiser, AlienBattleship, AlienMines, AlienMinesweeper, AlienOrbital);
  TAlienShip = TAlienResearch;
  TAlienShips = set of TAlienShip;

  THumanResearchLevel = array[THumanResearch] of TResearchLevel;
  TAlienResearchLevel = array[TAlienResearch] of TResearchLevel;

  TSquadron = array[TPowerLevel] of Integer;
  TFleetData = array[THumanShip] of TSquadron;
  TAlienFleetData = array[TAlienShip] of TSquadron;

  TMinesData = array of TSquadron;

  TPriorities = record
    Ships: array[THumanShip] of Integer;
    Research: Integer;
    Mines: array of Integer;
  end;

  TContactSituation = (HumanMinesweepers, HumanSpace, HumanMarine, HumanMines);


implementation

end.

