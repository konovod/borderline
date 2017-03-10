unit ubattle;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uGameTypes, uMap, uglobal;

type
  TBattleDistance = (
      Maximum, BattleshipsFire, CruisersFire, FireContact,
      BrandersClosing, BrandersMelee,
      BotsClosing, BotsLanding);

  TBattleResult = (InCombat, SpaceWon, SpaceLost, GroundWon, GroundLost);

var
  BattleDistance: TBattleDistance;
  Retreating: Boolean;


procedure TriggerMines(FromSys, ToSys: TSystem);

//uses player fleet and player system
procedure StartBattle;
procedure TurnBattle;
function BattleResult: TBattleResult;
procedure BattleLog(s: string);
function BattleJournal: string;

procedure DoRetreat(total: boolean);

implementation

uses ugame, uGameUI, uUI, uStaticData, ugameactions, Math;

var
  BattleJournals: array of string;


type
  THumanTargets = set of THumanShips;
  TAlienTargets = set of TAlienResearch;

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


procedure DoRetreat(total: boolean);
begin
  ModalWindow := nil;
  if total then
  begin
    Cursor := PrevSystem;
    //lol TODO - ugly hack
    with TJumpAction.Create do
    begin
      Execute;
      Free
    end;
  end;
end;

procedure TriggerMines(FromSys, ToSys: TSystem);
begin

end;

procedure StartBattle;
begin
  SetLength(BattleJournals, 0);
  BattleDistance := Maximum;
  Retreating := False;
  ModalWindow := BattleWindow;

  //TODO: fullscale scouts detection
  if AlienExists([AlienBattleship, AlienCruiser, AlienOrbital]) then
    BattleLog('Scanners detects multiple alien signatures');
end;

procedure DoAlienFireStep(who: TAlienResearch; targets: THumanTargets);
begin
  BattleLog(ALIEN_RESEARCH_NAMES[who]+' opens fire');
end;

procedure DoHumanFireStep(who: THumanShips; targets: TAlienTargets);
begin
  BattleLog(SHIP_NAMES[who]+' opens fire');
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
  if BattleResult <> InCombat then
  begin
    //TODO???
    exit;
  end;
  //change distances
  if Retreating then
  begin
    if BattleDistance in [Maximum, BattleshipsFire, BotsClosing] then
      DoRetreat(BattleDistance = BattleshipsFire)
    else
    begin
      BattleDistance := Pred(BattleDistance);
      BattleLog('Retreating');
    end
  end
  else
  begin
    if BattleDistance = BotsLanding  then
    begin
      //ground combat
      BattleLog('Troops continue invasion');
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
    begin
      if (BattleDistance <> BotsClosing) or (random < 0.5) then
        BattleDistance := Succ(BattleDistance);
      BattleLog('Closing by');
    end
  end;
end;

function BattleResult: TBattleResult;
begin
  if PlayerSys.PopStatus <> Alien then
    Result := GroundWon
  else if AlienExists([AlienBattleship, AlienCruiser]) and not HumanExists([Cruiser, Brander]) then
    Result := SpaceLost
  else if AlienExists([AlienBattleship, AlienCruiser]) and HumanExists([Cruiser, Brander]) then
    Result := InCombat
  else if not HumanExists([TroopTransport]) then
    Result := GroundLost
  else if not AlienExists([AlienOrbital]) then
    Result := GroundWon
  else if BattleDistance <= BrandersMelee then
    Result := SpaceWon
  else
    Result := InCombat;
end;

procedure BattleLog(s: string);
begin
  SetLength(BattleJournals, Length(BattleJournals)+1);
  BattleJournals[Length(BattleJournals)-1] := s;
end;

function BattleJournal: string;
var
  s: string;
  i: integer;
begin
  s := '';
  for i := max(0, Length(BattleJournals)-N_BTL_LOG_LINES) to Length(BattleJournals)-1 do
    s := s+BattleJournals[i]+#10;
  SetLength(s, Length(s)-1);
  Result := s
end;

end.

