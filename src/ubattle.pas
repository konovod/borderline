unit ubattle;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uGameTypes, uMap;

type
  TBattleDistance = (
      Maximum, BattleshipsFire, CruisersFire, FireContact,
      BrandersClosing, BrandersMelee,
      BotsClosing, BotsLanding);

  TBattleResult = (InCombat, SpaceWon, SpaceLost, GroundWon, GroundLost);

var
  BattleDistance: TBattleDistance;
  BattleLog: array of string;
  Retreating: Boolean;


procedure TriggerMines(FromSys, ToSys: TSystem);

//uses player fleet and player system
procedure StartBattle;
procedure TurnBattle;
function BattleResult: TBattleResult;

implementation

type
  THumanTargets = set of THumanShips;
  TAlienTargets = set of TAlienResearch;


procedure TriggerMines(FromSys, ToSys: TSystem);
begin

end;

procedure StartBattle;
begin
  SetLength(BattleLog, 0);
  BattleDistance := Maximum;
  Retreating := False;
end;

procedure DoAlienFireStep(who: TAlienResearch; targets: THumanTargets);
begin

end;

procedure DoHumanFireStep(who: THumanShips; targets: TAlienTargets);
begin

end;

function AlienExists(who: TAlienTargets): boolean;
begin

end;

function HumanExists(who: THumanTargets): boolean;
begin

end;

procedure TurnBattle;
begin
  //firing
  case BattleDistance of
    Maximum: ;
    BattleshipsFire: DoAlienFireStep(AlienBattleship, [Cruiser, Brander]);
    CruisersFire:
    begin
      DoAlienFireStep(AlienCruiser, [Cruiser, Brander]);
      DoAlienFireStep(AlienBattleship, [Cruiser, Brander]);
    end;
    FireContact:
    begin
      DoAlienFireStep(AlienCruiser, [Cruiser, Brander]);
      DoAlienFireStep(AlienBattleship, [Cruiser, Brander]);
      DoHumanFireStep(Cruiser, [AlienCruiser, AlienBattleship]);
    end;
    BrandersClosing:
    begin
      DoAlienFireStep(AlienCruiser, [Cruiser, Brander]);
      DoAlienFireStep(AlienBattleship, [Cruiser]);
      DoHumanFireStep(Cruiser, [AlienCruiser, AlienBattleship]);
    end;
    BrandersMelee:
    begin
      DoAlienFireStep(AlienCruiser, [Brander]);
      DoAlienFireStep(AlienBattleship, [Cruiser]);
      DoHumanFireStep(Cruiser, [AlienCruiser, AlienBattleship]);
      DoHumanFireStep(Brander, [AlienCruiser, AlienBattleship]);
    end;
    BotsClosing:
    begin
      DoAlienFireStep(AlienOrbital, [Cruiser, TroopTransport]);
      DoHumanFireStep(Cruiser, [AlienOrbital]);
    end;
    BotsLanding:
    begin
      DoAlienFireStep(AlienOrbital, [Cruiser, TroopTransport]);
      DoHumanFireStep(Cruiser, [AlienOrbital]);
    end;
  end;
  if BattleResult <> InCombat then exit;
  //change distances
  if Retreating then
  begin
    if BattleDistance in [BattleshipsFire, BotsClosing] then
      //retreat;
    else
      BattleDistance := Pred(BattleDistance);
  end
  else
  begin
    if BattleDistance = BotsLanding  then
      //ground combat
    else
      BattleDistance := Succ(BattleDistance);
  end;
end;

function BattleResult: TBattleResult;
begin
  Result := InCombat;
  //TODO
end;

end.

