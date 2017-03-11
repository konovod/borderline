unit ugame;

{$mode delphi}

interface

uses
  Classes, SysUtils, uglobal, uTextures, uMap, zgl_tiles_2d, zgl_primitives_2d,
  zgl_sprite_2d, zgl_textures, zgl_fx, zgl_particles_2d, uGameTypes;


procedure NewGame;
procedure DrawAll;
procedure DrawGameUI;
procedure OnClick(ax, ay: single);
procedure InitPlayer;

var
  Map: TMap;
  PlayerSys, Cursor, PrevSystem: TSystem;
  CursorSize: Integer;
  Turn: integer;
  StarDate: TStarDate;
  ResearchPriority: THumanResearch = Engines;
  PlayerFleet, PlayerDamaged: TFleetData;
  PlayerKnowledge: THumanResearchLevel;
  ShowCursor: boolean;

procedure NextTurn;
implementation

uses Math, uMain, uNameGen, zgl_text, zgl_mouse;

procedure NewGame;
begin
  InitNameGen;
  StarDate := 1;//EncodeDate(2114, 3, 12);
  Map := TMap.Create;
  Map.Generate;
  PlayerSys := Map.Systems[0];
  Cursor := nil;
  InitPlayer;
  PlayerSys.Enter;
  ScrollToCenter(PlayerSys.x, PlayerSys.y);
end;

procedure DrawAll;
begin
  if cursor = nil then
  begin
    Cursor := PlayerSys;
    ShowCursor := False;
  end;
  Map.Draw;
  if ShowCursor and (Cursor <> nil) then
    Cursor.ShowInfo(Cursor.X, Cursor.Y);
end;

procedure DrawGameUI;
begin
  DrawPanelUI(TOPPANEL_LEFT-0.005, 0, TOPPANEL_WIDTH+0.01, 0.26);
  DrawPanelUI(1-PLAYERINFO_WIDTH, PLAYERINFO_TOP, PLAYERINFO_WIDTH, PLAYERINFO_HEIGHT);
  DrawFormattedText(SCREENX*(1-PLAYERINFO_WIDTH)+10, SCREENY*PLAYERINFO_TOP+10, SCREENX*PLAYERINFO_WIDTH, SCREENY*PLAYERINFO_HEIGHT,
    'Your fleet', ShortShipsList(PlayerFleet)+#10#10'Research data:'#10+LongResearchList(PlayerKnowledge));
end;

procedure OnClick(ax, ay: single);
var
  sys: TSystem;
begin
  if InRect(mouse_x/SCREENX, mouse_y/SCREENY, TOPPANEL_LEFT-0.005, 0, TOPPANEL_WIDTH+0.01, 0.26) then exit;

  sys := Map.FindSys(ax, ay);
  if sys = cursor then
    ShowCursor := not ShowCursor
  else
    CursorSize := 0;

  if sys <> nil then
    Cursor := sys
  else
    Cursor := nil;
end;

procedure InitPlayer;
var
  ship: THumanShip;
  res: THumanResearch;
begin
  PlayerFleet[Cruiser][1] := 5;
  PlayerFleet[Brander][1] := 5;
  PlayerFleet[Scout][1] := 1;
  PlayerFleet[Colonizer][1] := 1;
  PlayerFleet[TroopTransport][1] := 2;
  for res in THumanResearch do
    PlayerKnowledge[res] := 1;
end;

procedure NextTurn;
var
  sys: TSystem;
begin
  inc(Turn);
  for sys in Map.Systems do
    sys.PassTime;
  StarDate := StarDate + 1;
end;


end.
