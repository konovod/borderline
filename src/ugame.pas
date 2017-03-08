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

var
  Map: TMap;
  PlayerSys, Cursor: TSystem;
  CursorSize: Integer;
  Turn: integer;
  StarDate: TStarDate;

procedure NextTurn;
implementation

uses Math, uMain, uNameGen, zgl_text;

procedure NewGame;
begin
  InitNameGen;
  StarDate := 1;//EncodeDate(2114, 3, 12);
  Map := TMap.Create;
  Map.Generate;
  PlayerSys := Map.Systems[0];
  Cursor := nil;
  PlayerSys.Enter;
  ScrollToCenter(PlayerSys.x, PlayerSys.y);
end;

procedure DrawAll;
begin
  Map.Draw;
  if Cursor <> nil then
    Cursor.ShowInfo(Cursor.X, Cursor.Y);
end;

procedure DrawGameUI;
begin
  DrawPanelUI(TOPPANEL_LEFT-0.005, 0, TOPPANEL_WIDTH+0.01, 0.26);
  //if Cursor <> nil then
  //begin
  //  DrawPanelUI(0, 1-SYSTEMINFO_HEIGHT, SYSTEMINFO_WIDTH, SYSTEMINFO_HEIGHT);
  //  Cursor.ShowInfo(0, SCREENY*(1-SYSTEMINFO_HEIGHT));
  //end;
  DrawPanelUI(1-PLAYERINFO_WIDTH, PLAYERINFO_TOP, PLAYERINFO_WIDTH, PLAYERINFO_HEIGHT);
end;

procedure OnClick(ax, ay: single);
var
  sys: TSystem;
begin
  sys := Map.FindSys(ax, ay);
  if sys <> cursor then
    CursorSize := 0;
  if sys <> nil then
    Cursor := sys
  else
    Cursor := nil;
end;

procedure NextTurn;
var
  sys: TSystem;
begin
  inc(Turn);
  //TODO - all processing
  for sys in Map.Systems do
    sys.PassTime;
  StarDate := StarDate + 1;
end;


end.
