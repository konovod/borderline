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
    VisitTime: TDateTime;
    AlienId: Integer;
    AlienResearch: TAlienResearchLevel;
    SeenHumanResearch, HumanResearch: THumanResearchLevel;
    Ships: TFleetData;
    SeenMines, Mines: TMinesData;
    procedure InitGameStats;
    procedure ShowInfo(aX, aY: single);
    function Color: zglColor;
    procedure Draw;
    procedure DrawLinks;
    constructor Create(aid, ax, ay: integer; aname: string);
    procedure Enter;
    function Linked(asys: TSystem): boolean;
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

implementation

uses zgl_primitives_2d, zgl_text, zgl_fx, ugame, umapgen, uStaticData;

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
  lv: TLevel;
begin
  //TODO: change?
  n := 0;
  for i := 0 to length(mines)-1 do
    for lv in TLevel do
      n := n+mines[i][lv]*lv;
  Result := 'total power: '+IntToStr(n);
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
    if Distance(x, y, sys.x, sys.y) < CLICKDIST then
    begin
      Result := sys;
      exit;
    end;
  Result := nil;
end;

{ TSystem }

procedure TSystem.InitGameStats;
begin
  SetLength(Mines, Length(Links));
  SetLength(SeenMines, Length(Links));
  //TODO: research levels?

end;

procedure TSystem.ShowInfo(aX, aY: single);
var
  text: string;

begin
  DrawPanel(aX,aY,SYSTEMINFO_WIDTH*SCREENX,SYSTEMINFO_HEIGHT*SCREENY, 0.9);
  if VisitTime = 0 then
  begin
    text := 'Unknown system';
  end
  else
  begin
    text := Name+#10+'visited at '+DateToStr(VisitTime)+#10+POP_STATUS_NAMES[SeenPopStatus];
    if SeenPopStatus = Own then
    begin
      text := text+#10+'Research: '+ShortResearchList(SeenHumanResearch);
      text := text+#10+'Mines: '+ShortMinesList(Self, SeenMines);
    end;
  end;
  DrawSomeText(aX+10, aY+10, SYSTEMINFO_WIDTH*SCREENX-20,SYSTEMINFO_HEIGHT*SCREENY-20, text);
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
  else if VisitTime <> 0 then
    text_Draw(fntMain, X, Y, Name);
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

function TSystem.Linked(asys: TSystem): boolean;
var
  sys: TSystem;
begin
  Result := True;
  for sys in Links do
    if sys = asys then exit;
  Result := False;
end;


end.

