unit uStaticData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uGameTypes, uMap;

const
  RESEARCH_NAMES: array[THumanResearch] of string = ('Explosives', 'Sensors', 'Engines', 'Armor', 'Weapons');
  ALIEN_RESEARCH_NAMES: array[TAlienResearch] of string = ('Cruiser', 'Battleship', 'Mines', 'Minesweeper', 'Orbital platform');

  POP_STATUS_NAMES: array[TPopulationState] of string = ('Colonized', 'Colonizable', 'Alien', 'Lifeless');


implementation

end.

