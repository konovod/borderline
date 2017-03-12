unit uGameTypes;

{$mode objfpc}{$H+}

interface


const
  MAX_RES_LEVEL = 20;
  MAX_POWER_LEVEL = 30;

  //balance koeffs
  K_LVL = 1.6;
  HUMAN_BUILD_SHIPS = 4;
  HUMAN_BUILD_MINES = 20;
  RESEARCH_CHANCE = 0.02;
  ALIEN_RESEARCH_CHANCE = 0.02;
  HUMAN_DAMAGE_K = 1;
  ALIEN_DAMAGE_K = 1;
  ALIEN_OVERSEE = 2;
  BUILD_ALIEN_ORBITAL = 7;
  BUILD_ALIEN_SHIPS = 2;
  BUILD_ALIEN_MINES = 20;

type

  TStarDate = integer;
  TPriorityLevel = integer;

  TResearchLevel = 0..MAX_RES_LEVEL;
  TPowerLevel = 0..MAX_POWER_LEVEL;

  THumanResearch = (Explosives, Sensors, Engines, Armor, Weapons);
  THumanShip = (Brander, Cruiser, Minesweeper, Colonizer, TroopTransport, Scout);
  THumanShips = set of THumanShip;


  TAlienResearch = (AlienCruiser, AlienBattleship, AlienMines,
    AlienMinesweeper, AlienOrbital);
  TAlienShip = TAlienResearch;
  TAlienShips = set of TAlienShip;

  THumanResearchLevel = array[THumanResearch] of TResearchLevel;
  TAlienResearchLevel = array[TAlienResearch] of TResearchLevel;

  TSquadron = array[TPowerLevel] of integer;
  TFleetData = array[THumanShip] of TSquadron;
  TAlienFleetData = array[TAlienShip] of TSquadron;

  TMinesData = array of TSquadron;

  TPriorities = record
    Ships: array[THumanShip] of integer;
    Research: integer;
    Mines: array of integer;
  end;

  TContactSituation = (HumanMinesweepers, HumanSpace, HumanMarine, HumanMines);

  TGameFinal = (
    LostByMines,
    LostByDeadLoop,
    LostByElimination,
    WonByElimination,
    WonBySacrifice,
    TotalWon
  );

  TStoryStage = (BeforePortal, BeforeLove, BeforeProphecy, AfterProphecy, LoveTaken);

const
  ALL_HUMAN_SHIPS: THumanShips = [Low(THumanShip)..High(THumanShip)];
  ALL_ALIEN_SHIPS: TAlienShips = [Low(TAlienShip)..High(TAlienShip)];

implementation

end.
