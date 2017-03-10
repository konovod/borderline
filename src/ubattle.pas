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

uses ugame;

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
var
  ship: TAlienResearch;
begin
  Result := True;
  for ship in who do
    if TotalCount(PlayerSys.AlienFleet[ship]) > 0 then
      exit;
  Result := False;
end;

function HumanExists(who: THumanTargets): boolean;
var
  ship: THumanShips;
begin
  Result := True;
  for ship in who do
    if TotalCount(PlayerFleet[ship]) > TotalCount(PlayerDamaged[ship]) then
      exit;
  Result := False;
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
    begin
      //ground combat
      if random < 0.3 then
      begin
        //battle won
        PlayerSys.Capture;
      end
    end
    else if (BattleDistance = BrandersMelee) and AlienExists([AlienBattleship, AlienCruiser]) then
    begin
      //do nothing
    end
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

