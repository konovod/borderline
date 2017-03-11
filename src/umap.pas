unit uMap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uglobal, uGameTypes;

{.$DEFINE DEBUGDRAW}

type

  TSystemState = (Hidden, Found, Visited, Current);
  TPopulationState = (Own, Colonizable, Alien, WipedOut);
  TPopulationStates = set of TPopulationState;

  TAlienArmyState = (None, Walking, Fleeing, Returning);

  TSystem = class;
  TAlienArmy = record
    State, StateNext: TAlienArmyState;
    waypoints: array of TSystem;
  end;

  { TSystem }

  TSystem = class
    id: integer;
    X,Y: Integer;
    Name: string;
    Links: array of TSystem;
    State: TSystemState;
    SeenPopStatus, PopStatus: TPopulationState;
    VisitTime: TStarDate;
    AlienId: Integer;
    AlienResearch, AlienResearchMax: TAlienResearchLevel;
    AlienResearchNext, AlienResearchMaxNext: TAlienResearchLevel;
    AlienFleet, AlienFleetNext: TAlienFleetData;
    SeenHumanResearch, HumanResearch: THumanResearchLevel;
    Ships: TFleetData;
    Priorities: TPriorities;
    SeenMines, Mines: TMinesData;
    AlienArmy: TAlienArmy;
    procedure InitGameStats;
    procedure DefaultPriorities;
    procedure ShowInfo(aX, aY: single);
    function Color: zglColor;
    procedure Draw;
    procedure DrawLinks;
    constructor Create(aid, ax, ay: integer; aname: string);
    procedure Enter;
    procedure EnterOwn;
    procedure PassTime;
    procedure SecondPass;
    procedure ProcessHumanSystem;
    procedure ProcessAlienSystem;
    procedure AlienMessaging;
    function Linked(asys: TSystem): boolean;
    procedure LogEvent(s: string);
    procedure Capture;
    procedure Colonize;
    procedure ClearAliens;
    procedure ContactHuman(sit: TContactSituation; MineFromSys: TSystem = nil);
    procedure SetResearch(res: TAlienResearch; n: integer);
    function RandomLink(allowed: TPopulationStates = [Own, Alien, Colonizable, WipedOut]): TSystem;
  end;

  { TMap }

  TMap = class
    Systems: array of TSystem;
    constructor Create;
    procedure Generate;
    procedure Draw;
    function FindSys(x, y: single): TSystem;
  end;


function ShortResearchList(res: THumanResearchLevel): string;
function LongResearchList(res: THumanResearchLevel): string;
function LongShipsList(fleet, damaged: TFleetData): string;
function ShortShipsList(fleet: TFleetData): string;
function ShortMinesList(sys: TSystem; mines: TMinesData): string;
function LongMinesList(sys: TSystem; mines: TMinesData): string;
function CalcPower(sqd: TSquadron): Single;
function AvgLevel(sqd: TSquadron): String;
function MaxLevel(sqd: TSquadron): TPowerLevel;
function TotalCount(sqd: TSquadron): Integer;
procedure LogEventRaw(s: string);

//TODO - colony sizes
function PrioToEffect(prio: TPriorityLevel; max: integer): integer;
function GenResLevel(res:THumanResearchLevel; first, second: THumanResearch): TPowerLevel;
function ShipLevel(ship: THumanShip; res:THumanResearchLevel): TPowerLevel;
procedure DoResearch(prio: TPriorityLevel; var res: THumanResearchLevel);

function FreePoints(prio: TPriorities): TPriorityLevel;

implementation

uses zgl_primitives_2d, zgl_text, zgl_fx, ugame, umapgen, uStaticData, uGameUI,
  uUI, ubattle, math;

function ShortResearchList(res: THumanResearchLevel): string;
var
  it: THumanResearch;
begin
  Result := '';
  for it in THumanResearch do
    Result := Result+RESEARCH_NAMES[it][1]+IntToStr(res[it])+',';
  SetLength(Result, Length(Result)-1);
end;

function ShortAlienResearchList(res: TAlienResearchLevel): string;
var
  it: TAlienResearch;
begin
  Result := '';
  for it in TAlienResearch do
    Result := Result+ALIEN_SHIP_NAMES[it][1]+IntToStr(res[it])+',';
  SetLength(Result, Length(Result)-1);
end;

function LongResearchList(res: THumanResearchLevel): string;
var
  it: THumanResearch;
begin
  Result := '';
  for it in THumanResearchLevel do
    Result := Result+RESEARCH_NAMES[it]+': '+IntToStr(res[it])+#10;
  SetLength(Result, Length(Result)-1);
end;

function LongShipsList(fleet, damaged: TFleetData): string;
var
  ship: THumanShip;
  n: integer;
begin
  Result := '';
  for ship in THumanShip do
  begin
    n := TotalCount(fleet[ship]);
    Result := Result+Format('%ss: %d, '#10, [SHIP_NAMES[ship], n]);
    if n > 0 then
      Result := Result+Format('LVL %.1f, DMG %d%%'#10#10, [
        AvgLevel(fleet[ship]),
        Trunc(100*TotalCount(damaged[ship])/TotalCount(fleet[ship]))])
    else
      Result := Result+#10;
  end;
  SetLength(Result, Length(Result)-1);
end;

function ShortShipsList(fleet: TFleetData): string;
var
  ship: THumanShip;
  n: integer;
begin
  Result := '';
  for ship in THumanShip do
  begin
    n := TotalCount(fleet[ship]);
    Result := Result+Format('%ss: %d, '#10, [SHIP_NAMES[ship], n]);
  end;
  SetLength(Result, Length(Result)-1);
end;

function ShortMinesList(sys: TSystem; mines: TMinesData): string;
var
  i, n: integer;
begin
  n := 0;
  for i := 0 to length(mines)-1 do
    n := n+TotalCount(mines[i]);
  Result := 'total: '+IntToStr(n);
end;

function LongMinesList(sys: TSystem; mines: TMinesData): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to length(sys.Links)-1 do
  begin
    Result := Result + '  to '+sys.Links[i].Name+': '+IntToStr(trunc(CalcPower(mines[i])));
    if i < length(sys.Links)-1 then
      Result := Result+#10;
  end;
end;

function CalcPower(sqd: TSquadron): Single;
var
  lv: TPowerLevel;
begin
  Result := 0;
  for lv in TPowerLevel do
    Result := Result + sqd[lv]*power(lv, K_LVL);
end;

function AvgLevel(sqd: TSquadron): String;
var
  lv: TPowerLevel;
  n: integer;
  res: integer;
begin
  Res := 0;
  for lv in TPowerLevel do
    Res := Res+lv*sqd[lv];
  n := TotalCount(sqd);
  if n = 0 then
    Res := 0
  else
    Res := Trunc(10*Res / n);
  Result := IntToStr(Res div 10)+'.'+IntToStr(Res mod 10);
end;

function MaxLevel(sqd: TSquadron): TPowerLevel;
var
  lv: TPowerLevel;
begin
  Result := 0;
  for lv := High(TPowerLevel) downto Low(TPowerLevel) do
    if sqd[lv] > 0 then
    begin
      Result := lv;
      exit
    end;
end;

function TotalCount(sqd: TSquadron): Integer;
var
  lv: TPowerLevel;
begin
  Result := 0;
  for lv in TPowerLevel do
    Inc(Result, sqd[lv]);
end;

procedure LogEventRaw(s: string);
begin
  SetLength(LogWindow.lines, Length(LogWindow.lines)+1);
  LogWindow.lines[Length(LogWindow.lines)-1] := s;
end;

function PrioToEffect(prio: TPriorityLevel; max: integer): integer;
begin
  Result := Trunc(prio/100*max);
  if random < frac(prio/100*max) then
    inc(Result)
end;

function GenResLevel(res: THumanResearchLevel; first, second: THumanResearch
  ): TPowerLevel;
begin
  Result := EnsureRange((res[first] + res[second] + min(res[first], res[second])) div 2, 0, MAX_POWER_LEVEL);
end;

function ShipLevel(ship: THumanShip; res:THumanResearchLevel): TPowerLevel;
begin
  case ship of
    Brander: Result := GenResLevel(res, Explosives, Engines);
    Cruiser: Result := GenResLevel(res, Weapons, Armor);
    Minesweeper: Result := GenResLevel(res, Weapons, Sensors);
    Colonizer: Result := 1;//TODO: cryionics\STC?
    TroopTransport: Result := GenResLevel(res, Armor, Engines);
    Scout: Result := GenResLevel(res, Sensors, Engines);
  end;
end;

procedure DoResearch(prio: TPriorityLevel; var res: THumanResearchLevel);
var
  area: THumanResearch;
  i: integer;
begin
  for i := 1 to 10 do
  begin
    if random < 0.75{0.8 actually :) } then
      area := ResearchPriority
    else
      area := THumanResearch(Random(ord(high(THumanResearch))+1));
    if (random < RESEARCH_CHANCE*prio/10/max(1, res[area])) and
       (res[area] < MAX_RES_LEVEL) then
    begin
      inc(res[area]);
      exit;
    end;
  end;
end;

function FreePoints(prio: TPriorities): TPriorityLevel;
var
  i: integer;
  ship: THumanShip;
begin
  Result := 100 - prio.Research;
	for ship in THumanShip do
  	Result := Result - prio.Ships[ship];
	for i := 0 to length(prio.Mines)-1 do
  	Result := Result - prio.Mines[i];
end;

{ TMap }

constructor TMap.Create;
begin

end;

procedure TMap.Generate;
begin
  uMapGen.Generate(Self);
end;

procedure TMap.Draw;
var
  sys: TSystem;
begin
  for sys in Systems do
    sys.DrawLinks;
  for sys in Systems do
    sys.Draw;
end;

function TMap.FindSys(x, y: single): TSystem;
var
  sys: TSystem;
begin
  for sys in Systems do
    if (sys.State <> Hidden) and (Distance(x, y, sys.x, sys.y) < CLICKDIST) then
    begin
      Result := sys;
      exit;
    end;
  Result := nil;
end;

{ TSystem }

procedure TSystem.InitGameStats;
var
  res: THumanResearch;
begin
  SetLength(Mines, Length(Links));
  SetLength(SeenMines, Length(Links));
  SetLength(Priorities.Mines, Length(Links));
  for res in THumanResearch do
    HumanResearch[res] := 1;
  AlienResearch[AlienBattleship] := 1;
  AlienResearch[AlienCruiser] := 1;
  AlienResearch[AlienMines] := 1;
  AlienResearch[AlienOrbital] := 1;
  DefaultPriorities;
end;

procedure TSystem.DefaultPriorities;
var
  ship: THumanShip;
  i: integer;
begin
  Priorities.Research := 40;
  for ship in THumanShip do
	  Priorities.Ships[ship] := 10;
  for i := 0 to length(links)-1 do
  	Priorities.Mines[i] := 0;
end;

procedure TSystem.ShowInfo(aX, aY: single);
var
  caption, text: string;
begin
  DrawPanel(aX,aY,SYSTEMINFO_WIDTH*SCREENX,SYSTEMINFO_HEIGHT*SCREENY, 0.9);
  caption := Name;
  text := '';
  if VisitTime <> 0 then
  begin
    if VisitTime = StarDate then
      text := #1
    else
      text := 'visited at '+MyDateToStr(VisitTime);
    text := text+#10+POP_STATUS_NAMES[SeenPopStatus];
    if SeenPopStatus = Own then
    begin
      text := text+#10+'Research: '+ShortResearchList(SeenHumanResearch);
      text := text+#10+'Minefields power:'#10+LongMinesList(Self, SeenMines);
    end;

    //debug
    text := text+#10+'Alien:'+ShortAlienResearchList(AlienResearch);
    text := text+#10+'Alien max:'+ShortAlienResearchList(AlienResearchMax);

  end;
  DrawFormattedText(aX+10, aY+10, SYSTEMINFO_WIDTH*SCREENX-20,SYSTEMINFO_HEIGHT*SCREENY-20, caption, text);
end;

function TSystem.Color: zglColor;
begin
  if VisitTime = 0 then
    Result := Black
  else
  case SeenPopStatus of
    Own: Result := Green;
    Colonizable: Result := Blue;
    Alien: Result := Red;
    WipedOut: Result := Dark;
  end;
end;

procedure TSystem.Draw;
begin
  {$IFNDEF DEBUGDRAW}
  if State = Hidden then exit;
  {$ENDIF}
  pr2d_Circle(X, Y, 10, Color, 255, 32, PR2D_FILL);
  if VisitTime = 0 then
    pr2d_Circle(X, Y, 10, White);
  if Self = Cursor then
  begin
    CursorSize := (CursorSize + 1) mod (15*4);
    pr2d_Circle(X, Y, 15+15-CursorSize div 4, IntfDark);
  end;
  if (Self <> Cursor) or not ShowCursor then
    text_DrawEx(fntMain, X+10, Y+10, 0.5, 0, Name, 255, White);
end;

procedure TSystem.DrawLinks;
var
  other: TSystem;
begin
  {$IFNDEF DEBUGDRAW}
  if State <= Found then exit;
  {$ENDIF}
  for other in links do
//    if other.id > id then
      BoldLine(X,Y,other.X, other.Y, White);
end;

constructor TSystem.Create(aid, ax, ay: integer; aname: string);
begin
  id := aid;
  x := ax;
  y := ay;
  name := aname;
  State := Hidden;
end;

procedure TSystem.Enter;
var
  sys: TSystem;
begin
  LogEvent('Entering');
  State := Current;
  for sys in Links do
    if sys.State < Found then
      sys.State := Found;
  //now make visit
  VisitTime := StarDate;
  if SeenPopStatus <> PopStatus then
    LogEvent('System is '+POP_STATUS_NAMES[PopStatus]+'!');
  case PopStatus of
    Own: EnterOwn;
    Alien: StartBattle(False);
  end;
  SeenMines := Mines;
  SetLength(SeenMines, Length(SeenMines));
  SeenHumanResearch := HumanResearch;
  SeenPopStatus := PopStatus;
end;

procedure TSystem.EnterOwn;
var
  ship: THumanShip;
  n1, n2: integer;
  lv: TPowerLevel;
  res: THumanResearch;
begin
  //transfer ships
  n1 := 0;
  n2 := 0;
  for ship in THumanShip do
  begin
    inc(n1, TotalCount(PlayerDamaged[ship]));
    inc(n2, TotalCount(Ships[ship]));
    for lv in TPowerLevel do
    begin
      PlayerFleet[ship][lv] := PlayerFleet[ship][lv]+Ships[ship][lv];
      PlayerDamaged[ship][lv] := 0;
      Ships[ship][lv] := 0;
    end;
  end;
  if n1 > 0 then LogEvent(IntToStr(n1)+' ships repaired');
  if n2 > 0 then LogEvent(IntToStr(n2)+' built ships added to fleet');
  //transfer knowledge
  n1 := 0;
  n2 := 0;
  for res in THumanResearch do
    if PlayerKnowledge[res] > HumanResearch[res] then
    begin
      inc(n1, PlayerKnowledge[res] - HumanResearch[res]);
      HumanResearch[res] := PlayerKnowledge[res];
    end
    else if PlayerKnowledge[res] < HumanResearch[res] then
    begin
      inc(n2, HumanResearch[res] - PlayerKnowledge[res]);
      PlayerKnowledge[res] := HumanResearch[res];
    end;
  if n1 > 0 then LogEvent(IntToStr(n1)+' research levels given to planet');
  if n2 > 0 then LogEvent(IntToStr(n2)+' research levels was discovered on planet');
end;

procedure TSystem.PassTime;
begin
  case PopStatus of
    Own: ProcessHumanSystem;
    Alien: ProcessAlienSystem;
    Colonizable, WipedOut: ;
  end;
  AlienMessaging;
end;

procedure TSystem.SecondPass;
var
  typ: TAlienResearch;
  lv: TPowerLevel;
begin
  for typ in TAlienResearch do
  begin
    if AlienResearchMaxNext[typ] > AlienResearchMax[typ] then
      AlienResearchMax[typ] := AlienResearchMaxNext[typ];
    if AlienResearchNext[typ] > AlienResearch[typ] then
      AlienResearch[typ] := AlienResearchNext[typ];
    for lv in TPowerLevel do
    begin
      AlienFleet[typ][lv] := AlienFleet[typ][lv] + AlienFleetNext[typ][lv];
      AlienFleetNext[typ][lv] := 0;
    end;
  end;
  if AlienArmy.StateNext <> None then
  begin
    AlienArmy.State := AlienArmy.StateNext;
    AlienArmy.StateNext := None;
  end;
end;

procedure TSystem.ProcessHumanSystem;
var
  ship: THumanShip;
  lv, i: integer;
begin
  //1. build ships
    for ship in THumanShip do
    begin
      Inc(Ships[ship][ShipLevel(ship, HumanResearch)], PrioToEffect(Priorities.Ships[ship], 10));
    end;
  //2. do research
  	DoResearch(Priorities.Research, HumanResearch);
  //3. build mines
    lv := HumanResearch[Explosives];
    for i := 0 to length(Mines)-1 do
      Inc(Mines[i][lv], PrioToEffect(Priorities.Mines[i], 10*MINE_MULTIPLIER));
  //4. TODO: drift priorities
end;

procedure TSystem.ProcessAlienSystem;
var
  typ: TAlienResearch;
  i: integer;
begin
  //1. build ships
  repeat
    typ := TAlienResearch(Random(ord(high(TAlienResearch))+1));
  until AlienResearch[typ] > 0;
  case typ of
    AlienMines:
    begin
      i := Random(Length(Links));
      inc(Mines[i][AlienResearch[typ]], MINE_MULTIPLIER);
    end;
    AlienOrbital:
      inc(AlienFleet[typ][AlienResearch[typ]], BUILD_ALIEN_ORBITAL);
    else
      inc(AlienFleet[typ][AlienResearch[typ]])
  end;
  //2. do research
  for typ in TAlienResearch do
    if (AlienResearch[typ] < AlienResearchMax[typ]) and (random < ALIEN_RESEARCH_CHANCE) then
    begin
      inc(AlienResearch[typ]);
      break;
    end;
end;

procedure TSystem.AlienMessaging;
var
  typ: TAlienResearch;
  i: integer;
  target: TSystem;
  army: TAlienFleetData;
  lv: TPowerLevel;
begin
  for i := 0 to length(Links)-1 do
  begin
    if Links[i].PopStatus = Own then continue;
    for typ in TAlienResearch do
    begin
      if AlienResearchMax[typ] > Links[i].AlienResearchMax[typ] then
        Links[i].AlienResearchMaxNext[typ] := AlienResearchMax[typ];
      if AlienResearch[typ] > Links[i].AlienResearch[typ] then
        Links[i].AlienResearchNext[typ] := AlienResearch[typ];
    end;
  end;
  //4. armies navigation
  case AlienArmy.State of
    None:;
    Walking, Returning:
      begin
        if AlienArmy.State = Walking then
          target := RandomLink
        else
        begin
          target := AlienArmy.waypoints[Length(AlienArmy.waypoints)-1];
          SetLength(AlienArmy.waypoints, Length(AlienArmy.waypoints)-1);
          if Length(AlienArmy.waypoints) = 0 then AlienArmy.State := Walking;
        end;
        FillChar(army, SizeOf(army), 0);
        for typ in [AlienCruiser, AlienBattleship, AlienMinesweeper] do
        begin
          Move(AlienFleet[typ], army[typ], sizeof(TSquadron));
          FillChar(AlienFleet[typ], SizeOf(TSquadron), 0);
        end;
        if target.PopStatus = Own then
          //TODO: invasion
        else
        begin
          if target.AlienArmy.StateNext < AlienArmy.State then
            target.AlienArmy.StateNext := AlienArmy.State;
          AlienArmy.State := None;
          for typ in [AlienCruiser, AlienBattleship, AlienMinesweeper] do
            for lv in TPowerLevel do
              target.AlienFleetNext[typ][lv] := target.AlienFleetNext[typ][lv] + army[typ][lv];
        end;
      end;
  end;
end;

function TSystem.Linked(asys: TSystem): boolean;
var
  sys: TSystem;
begin
  Result := True;
  for sys in Links do
    if sys = asys then exit;
  Result := False;
end;

procedure TSystem.LogEvent(s: string);
begin
  LogEventRaw(' '+Name+': '+s);
end;

procedure TSystem.Capture;
begin
  ContactHuman(HumanMarine);
  ClearAliens;
  LogEvent('System was captured by ground forces, alien population wiped out, system can be colonized');
  PopStatus := Colonizable;
  SeenPopStatus := Colonizable;
end;

procedure TSystem.Colonize;
begin
  ClearAliens;
  LogEvent('System was colonized');
  PopStatus := Own;
  EnterOwn;
  SeenMines := Mines;
  SetLength(SeenMines, Length(SeenMines));
  SeenHumanResearch := HumanResearch;
  SeenPopStatus := PopStatus;
end;

procedure TSystem.ClearAliens;
begin
  FillChar(AlienFleet, SizeOf(AlienFleet), 0);
  SetLength(Mines, 0);
  SetLength(Mines, length(Links));
  AlienArmy.State := None;
end;

procedure TSystem.ContactHuman(sit: TContactSituation; MineFromSys: TSystem = nil);
var
  sys: TSystem;
  i: integer;
begin
  case sit of
    HumanMinesweepers:
      for sys in Links do sys.SetResearch(AlienMines, MaxLevel(PlayerFleet[Minesweeper]));
    HumanMines:
    begin
      for i := 0 to Length(Links)-1 do
        if Links[i] = MineFromSys then
        begin
          MineFromSys.SetResearch(AlienMinesweeper, MaxLevel(Mines[i]));
          break;
        end;
    end;
    HumanSpace:
    begin
      for sys in Links do sys.SetResearch(AlienBattleship, MaxLevel(PlayerFleet[Cruiser]));
      for sys in Links do sys.SetResearch(AlienCruiser, MaxLevel(PlayerFleet[Brander]));
    end;
    HumanMarine:
    begin
      for sys in Links do sys.SetResearch(AlienBattleship, MaxLevel(PlayerFleet[Cruiser]));
      for sys in Links do sys.SetResearch(AlienOrbital, MaxLevel(PlayerFleet[TroopTransport]));
    end;
  end;
end;

procedure TSystem.SetResearch(res: TAlienResearch; n: integer);
begin
  inc(n, ALIEN_OVERSEE);
  if n > MAX_RES_LEVEL then
    n := MAX_RES_LEVEL;
  if AlienResearchMax[res] < n then
    AlienResearchMax[res] := n;
end;

function TSystem.RandomLink(allowed: TPopulationStates): TSystem;
var
  i: integer;
  sys: TSystem;
  list: array of TSystem;
begin
  SetLength(List, 0);
  for sys in Links do
    if sys.PopStatus in allowed then
    begin
      SetLength(List, length(list)+1);
      list[length(list)-1] := sys;
    end;
  if Length(list) = 0 then
    Result := nil
  else
    Result := list[random(Length(list))];
end;


end.

