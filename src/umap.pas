unit uMap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uglobal, uGameTypes;

{.$DEFINE DEBUGDRAW}

type

  TSystemState = (Hidden, Found, Visited, Current);
  TPopulationState = (Own, Colonizable, Alien, WipedOut);

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
    AlienResearch: TAlienResearchLevel;
    SeenHumanResearch, HumanResearch: THumanResearchLevel;
    Ships: TFleetData;
    Priorities: TPriorities;
    SeenMines, Mines: TMinesData;
    procedure InitGameStats;
    procedure DefaultPriorities;
    procedure ShowInfo(aX, aY: single);
    function Color: zglColor;
    procedure Draw;
    procedure DrawLinks;
    constructor Create(aid, ax, ay: integer; aname: string);
    procedure Enter;
    procedure PassTime;
    function Linked(asys: TSystem): boolean;
    procedure LogEvent(s: string);
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
function ShortMinesList(sys: TSystem; mines: TMinesData): string;
function LongMinesList(sys: TSystem; mines: TMinesData): string;
function CalcPower(sqd: TSquadron): Single;
function AvgLevel(sqd: TSquadron): Single;
function TotalCount(sqd: TSquadron): Integer;

//TODO - colony sizes
function PrioToEffect(prio: TPriorityLevel; max: integer): integer;
function GenResLevel(res:THumanResearchLevel; first, second: THumanResearch): TPowerLevel;
function ShipLevel(ship: THumanShips; res:THumanResearchLevel): TPowerLevel;
procedure DoResearch(prio: TPriorityLevel; var res: THumanResearchLevel);

function FreePoints(prio: TPriorities): TPriorityLevel;
implementation

uses zgl_primitives_2d, zgl_text, zgl_fx, ugame, umapgen, uStaticData, math;

function ShortResearchList(res: THumanResearchLevel): string;
var
  it: THumanResearch;
begin
  Result := '';
  for it in THumanResearchLevel do
    Result := Result+RESEARCH_NAMES[it][1]+IntToStr(res[it])+',';
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
  i, n: integer;
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
  n: integer;
begin
  Result := 0;
  for lv in TPowerLevel do
    Result := Result + sqd[lv]*power(lv, K_LVL);
end;

function AvgLevel(sqd: TSquadron): Single;
var
  lv: TPowerLevel;
  n: integer;
begin
  Result := 0;
  for lv in TPowerLevel do
    Result := Result+lv*sqd[lv];
  n := TotalCount(sqd);
  if n = 0 then
    Result := 0
  else
    Result := Result / n;
end;

function TotalCount(sqd: TSquadron): Integer;
var
  lv: TPowerLevel;
begin
  Result := 0;
  for lv in TPowerLevel do
    Inc(Result, sqd[lv]);
end;

function PrioToEffect(prio: TPriorityLevel; max: integer): integer;
var
  fract: single;
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

function ShipLevel(ship: THumanShips; res:THumanResearchLevel): TPowerLevel;
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
  ship: THumanShips;
begin
  Result := 100 - prio.Research;
	for ship in THumanShips do
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
  AlienResearch[AlienBattleship] := 5;
  AlienResearch[AlienCruiser] := 5;
  DefaultPriorities;
end;

procedure TSystem.DefaultPriorities;
var
  ship: THumanShips;
  i: integer;
begin
  Priorities.Research := 40;
  for ship in THumanShips do
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
  end
  else //if VisitTime <> 0 then
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
  State := Current;
  for sys in Links do
    if sys.State < Found then
      sys.State := Found;
  //now make visit
  VisitTime := StarDate;
  SeenMines := Mines;
  SeenHumanResearch := HumanResearch;
  SeenPopStatus := PopStatus;
end;

procedure TSystem.PassTime;
var
  ship: THumanShips;
  lv, i: integer;
begin
  case PopStatus of
    Own:
  begin
  //1. build ships
    for ship in THumanShips do
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
    Alien: ;//TODO
    Colonizable, WipedOut: ;
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
  //TODO
end;


end.

