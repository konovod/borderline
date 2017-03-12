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

  TLogMode = (lBattle, lGlobal, lSilent);

var
  BattleDistance: TBattleDistance;
  Retreating: boolean;


function TriggerMines(Human: boolean; FromSys, ToSys: TSystem): boolean;

//uses player fleet and player system
procedure StartBattle(ground: boolean);
procedure TurnBattle;
function BattleResult: TBattleResult;
procedure BattleLog(s: string);
function BattleJournal: string;

procedure DoRetreat(total: boolean);
function AutoInvasionBattle(sys: TSystem): boolean;

implementation

uses ugame, uGameUI, uUI, uStaticData, ugameactions, Math;

var
  BattleJournals: array of string;

function AlienExists(who: TAlienShips): boolean;
var
  ship: TAlienShip;
begin
  Result := True;
  for ship in who do
    if TotalCount(PlayerSys.AlienFleet[ship]) > 0 then
      exit;
  Result := False;
end;

function HumanExists(who: THumanShips): boolean;
var
  ship: THumanShip;
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
    LogEventRaw('    you have retreated to warp point and jumped to ' + PrevSystem.Name);
    LogAndRetreat(PrevSystem);
  end;
end;

type
  TDamageGroup = record
    lvl: TPowerLevel;
    typ: THumanShip;
    atyp: TAlienShip;
    size: single;
  end;

function DamageHuman(applyvalue: single; typs: THumanShips;
  always_fatal: boolean; log_mode: TLogMode = lBattle): single;
var
  groups: array of TDamageGroup;
  grp: TDamageGroup;
  lv: TPowerLevel;
  ship: THumanShip;
  i: integer;
  x, fullsize, pwr: single;
  lognormal: array[THumanShip] of integer;
  logdamaged: array[THumanShip] of integer;
  s: string;
begin
  //fill groups
  //and count total damage size
  SetLength(groups, 0);
  fullsize := 0;
  for ship in typs do
  begin
    logdamaged[ship] := 0;//TotalCount(PlayerDamaged[ship]);
    lognormal[ship] := 0;//TotalCount(PlayerFleet[ship])-logdamaged[ship];
  end;
  for ship in typs do
    for lv in TPowerLevel do
      if (lv > 0) and (PlayerFleet[ship][lv] > 0) then
      begin
        SetLength(groups, Length(groups) + 1);
        grp.lvl := lv;
        grp.size := PlayerFleet[ship][lv] * power(lv, K_LVL);
        fullsize := fullsize + grp.size;
        grp.typ := ship;
        groups[Length(groups) - 1] := grp;
      end;
  //full destruction, return sum damage
  if applyvalue >= fullsize then
  begin
    for ship in typs do
      for lv in TPowerLevel do
      begin
        lognormal[ship] := lognormal[ship] - PlayerFleet[ship][lv] +
          PlayerDamaged[ship][lv];
        logdamaged[ship] := logdamaged[ship] - PlayerDamaged[ship][lv];
        PlayerFleet[ship][lv] := 0;
        PlayerDamaged[ship][lv] := 0;
      end;
    Result := fullsize;
  end
  else
    //spread damage to random groups
  begin
    Result := applyvalue;
    while applyvalue > 0.001 do
    begin
      x := random * fullsize;
      for i := 0 to Length(groups) - 1 do
        if x >= groups[i].size then
          x := x - groups[i].size
        else
        begin
          grp := groups[i];
          pwr := power(grp.lvl, K_LVL);
          applyvalue := applyvalue - pwr;
          if random < PlayerDamaged[grp.typ][grp.lvl] /
            PlayerFleet[grp.typ][grp.lvl] then
          begin
            //attack damaged ship
            if always_fatal or (random < 0.5) then
            begin
              Dec(logdamaged[grp.typ]);
              Dec(PlayerDamaged[grp.typ][grp.lvl]);
              Dec(PlayerFleet[grp.typ][grp.lvl]);
              grp.size := grp.size - pwr;
              fullsize := fullsize - grp.lvl;
            end;
          end
          else
          begin
            //damage new ship
            if always_fatal or (random < 0.2) then
            begin
              Dec(lognormal[grp.typ]);
              Dec(PlayerFleet[grp.typ][grp.lvl]);
              grp.size := grp.size - pwr;
              fullsize := fullsize - grp.lvl;
            end
            else
            begin
              Inc(PlayerDamaged[grp.typ][grp.lvl]);
              Dec(lognormal[grp.typ]);
              Inc(logdamaged[grp.typ]);
            end;
          end;
          break;
        end;
    end;
  end;
  for ship in typs do
  begin
    if -logdamaged[ship] - lognormal[ship] > 0 then
    begin
      s := Format('    %d %ss destroyed', [-logdamaged[ship] -
        lognormal[ship], SHIP_NAMES[ship]]);
      case log_mode of
        lGlobal: LogEventRaw(s);
        lBattle: BattleLog(s);
        else;
      end;
    end;
    if logdamaged[ship] > 0 then
    begin
      s := Format('    %d %ss damaged', [logdamaged[ship], SHIP_NAMES[ship]]);
      case log_mode of
        lGlobal: LogEventRaw(s);
        lBattle: BattleLog(s);
        else;
      end;
    end;
  end;
end;

function DamageAlien(applyvalue: single; typs: TAlienShips;
  var fleet: TAlienFleetData): single;
var
  groups: array of TDamageGroup;
  grp: TDamageGroup;
  lv: TPowerLevel;
  ship: TAlienShip;
  i: integer;
  x, fullsize, pwr: single;
  lognormal: array[TAlienShip] of integer;
  flt: TAlienFleetData;
begin
  flt := PlayerSys.AlienFleet;
  //fill groups
  //and count total damage size
  SetLength(groups, 0);
  fullsize := 0;
  for ship in typs do
    lognormal[ship] := 0;
  for ship in typs do
    for lv in TPowerLevel do
      if (lv > 0) and (flt[ship][lv] > 0) then
      begin
        SetLength(groups, Length(groups) + 1);
        grp.lvl := lv;
        grp.size := flt[ship][lv] * power(lv, K_LVL);
        fullsize := fullsize + grp.size;
        grp.atyp := ship;
        groups[Length(groups) - 1] := grp;
      end;
  //full destruction, return sum damage
  if applyvalue >= fullsize then
  begin
    for ship in typs do
      for lv in TPowerLevel do
      begin
        lognormal[ship] := lognormal[ship] - flt[ship][lv];
        flt[ship][lv] := 0;
      end;
    Result := fullsize;
  end
  else
    //spread damage to random groups
  begin
    Result := applyvalue;
    while applyvalue > 0.001 do
    begin
      x := random * fullsize;
      for i := 0 to Length(groups) - 1 do
        if x >= groups[i].size then
          x := x - groups[i].size
        else
        begin
          grp := groups[i];
          pwr := power(grp.lvl, K_LVL);
          applyvalue := applyvalue - pwr;
          if random < 0.5 then
          begin
            Dec(lognormal[grp.atyp]);
            Dec(flt[grp.atyp][grp.lvl]);
            grp.size := max(grp.size - pwr, 0);
            fullsize := fullsize - pwr;
          end;
        end;
    end;
  end;
  for ship in typs do
  begin
    if lognormal[ship] <> 0 then
      BattleLog(Format('    %d alien %ss destroyed',
        [-lognormal[ship], LowerCase(ALIEN_SHIP_NAMES[ship])]));
  end;
  PlayerSys.AlienFleet := flt;
end;



function TriggerMines(Human: boolean; FromSys, ToSys: TSystem): boolean;
var
  countered, dmg, applied: single;
  i, n, index: integer;
  lv: TPowerLevel;
begin
  Result := False;
  if human and (ToSys.PopStatus <> Alien) then
    exit;
  if not human and (ToSys.PopStatus <> Own) then
    exit;
  dmg := 0;
  for i := 0 to Length(ToSys.Links) - 1 do
    if ToSys.Links[i] = FromSys then
    begin
      dmg := CalcPower(ToSys.Mines[i]);
      index := i;
      break;
    end;
  if dmg <= 0 then
    exit;
  if Human then
  begin
    Result := True;
    ToSys.LogEvent('Minefields triggered on transit');
    countered := CalcPower(PlayerFleet[Minesweeper]) - CalcPower(
      PlayerDamaged[Minesweeper]);
    if countered > 0 then
    begin
      LogEventRaw(Format('    Minesweepers cleaned about %d%%',
        [Trunc(100 * countered / dmg)]));
      ToSys.ContactHuman(HumanMinesweepers);
    end;
    dmg := dmg - countered;
    if dmg > 0 then
    begin
      applied := DamageHuman(dmg, ALL_HUMAN_SHIPS, False, lGlobal);
      if applied < dmg - 0.001 then
      begin
        LogEventRaw('    Commander ship was destroyed');
        LogEventRaw('    GAME OVER');
        GameIsOver;
        exit;
      end;
    end;
    for lv in TPowerLevel do
      ToSys.Mines[i][lv] := 0;
  end
  else
  begin
    //here result is true only if army is destroyed
    countered := CalcPower(ToSys.AlienFleet[AlienMinesweeper]);
    dmg := dmg - countered;
    if dmg > 0 then
    begin
      ToSys.ContactHuman(HumanMines, FromSys);
      applied := DamageAlien(dmg, ALL_ALIEN_SHIPS, ToSys.AlienFleet);
      if applied < dmg - 0.001 then
      begin
        //army was cleaned by mines
        Result := True;
        //now remove random mines
        while applied > 0.001 do
        begin
          lv := random(MAX_POWER_LEVEL) + 1;
          if ToSys.Mines[index][lv] > 0 then
          begin
            applied := applied - power(lv, K_LVL);
            Dec(ToSys.Mines[index][lv]);
          end;
        end;
        exit;
      end
      else
      begin
        //army surpassed mines
        Result := False;
      end;
    end;
    for lv in TPowerLevel do
      ToSys.Mines[i][lv] := 0;
  end;
end;

procedure StartBattle(ground: boolean);
begin
  SetLength(BattleJournals, 0);
  if ground then
    BattleDistance := BotsClosing
  else
    BattleDistance := Maximum;
  Retreating := False;
  ModalWindow := BattleWindow;

  //TODO: fullscale scouts detection
  if AlienExists([AlienBattleship, AlienCruiser, AlienOrbital]) then
  begin
    BattleLog('Scanners detects multiple alien signatures');
    if ground then
      PlayerSys.ContactHuman(HumanMarine)
    else
      PlayerSys.ContactHuman(HumanSpace);
  end;
end;

procedure DoAlienFireStep(who: TAlienShip; targets: THumanShips);
var
  dmg: single;
begin
  dmg := random * CalcPower(PlayerSys.AlienFleet[who]) * ALIEN_DAMAGE_K;
  if dmg <= 0 then
    exit;
  BattleLog('Alien ' + ALIEN_SHIP_NAMES[who] + 's opens fire');
  DamageHuman(dmg, targets, False);
end;

procedure DoHumanFireStep(who: THumanShip; targets: TAlienShips);
var
  dmg: single;
begin
  dmg := random * (CalcPower(PlayerFleet[who]) - CalcPower(PlayerDamaged[who])) *
    HUMAN_DAMAGE_K;
  if dmg <= 0 then
    exit;
  BattleLog(SHIP_NAMES[who] + 's opens fire');
  dmg := DamageAlien(dmg, targets, PlayerSys.AlienFleet);
  if who = Brander then
    DamageHuman(dmg, [Brander], True);
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
      if HumanExists([Brander]) then
        DoAlienFireStep(AlienCruiser, [Brander])
      else
        DoAlienFireStep(AlienCruiser, [Brander, Cruiser]);
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
      DoRetreat(BattleDistance <> BotsClosing)
    else
    begin
      BattleDistance := Pred(BattleDistance);
      BattleLog('Retreating');
    end;
  end
  else
  begin
    if BattleDistance = BotsLanding then
    begin
      //ground combat
      if random < 0.3 then
      begin
        BattleLog('Troops conquered the planet');
        BattleLog('Xenociding population');
        //battle won
        PlayerSys.Capture;
      end
      else
        BattleLog('Troops continue invasion');
    end
    else if (BattleDistance = BrandersMelee) and
      AlienExists([AlienBattleship, AlienCruiser]) then
    begin
      //do nothing
    end
    else
    begin
      if (BattleDistance <> BotsClosing) or (random < 0.5) then
        BattleDistance := Succ(BattleDistance);
      BattleLog('Closing by');
    end;
  end;
end;

function BattleResult: TBattleResult;
begin
  {if PlayerSys.PopStatus <> Alien then
    Result := GroundWon
  else} if AlienExists([AlienBattleship, AlienCruiser]) and not
    HumanExists([Cruiser, Brander]) then
    Result := SpaceLost
  else if AlienExists([AlienBattleship, AlienCruiser]) and
    HumanExists([Cruiser, Brander]) then
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
  SetLength(BattleJournals, Length(BattleJournals) + 1);
  BattleJournals[Length(BattleJournals) - 1] := s;
end;

function BattleJournal: string;
var
  s: string;
  i: integer;
begin
  s := '';
  for i := max(0, Length(BattleJournals) - N_BTL_LOG_LINES)
    to Length(BattleJournals) - 1 do
    s := s + BattleJournals[i] + #10;
  SetLength(s, Length(s) - 1);
  Result := s;
end;


function AutoInvasionBattle(sys: TSystem): boolean;
var
  powera, powerh: single;
begin
  Result := False;
end;


end.
