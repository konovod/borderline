unit uMain;

{$IFDEF FPC}
{$mode delphi}
{$ENDIF}

interface

uses
  zgl_application,
  SysUtils,
  zgl_file,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_camera_2d,
  zgl_render_2d,
  zgl_fx,
  zgl_ini,
  zgl_main,
  zgl_keyboard,
  zgl_primitives_2d,
  zgl_particles_2d,
  zgl_resources,
  zgl_textures_tga, // TGA
  zgl_textures_png, // PNG
  zgl_font,
  zgl_text,
  zgl_log,
  zgl_math_2d,
  zgl_utils,
  zgl_mouse,
  uTextures,
  ugame;

var
  Ready: boolean = False;
  particles: zglTPEngine2D;
  emitterFire: zglPEmitter2D;
  emitterRain: zglPEmitter2D;

procedure LoadSplash(datadir: string);
procedure LoadAll(datadir: string);
procedure DrawFrame;
procedure DrawProgress;
procedure ProcessTime;
procedure MouseRight(aX, aY: integer);
procedure MouseUp(aX, aY: integer);
procedure MouseDown(aX, aY: integer);
procedure MousePressed(aX, aY: integer);
procedure MouseMoved(aX, aY: integer);
procedure TimedUpdate(dt: double);
function GetScreenX: integer;
function GetScreenY: integer;
procedure ReloadMedia(datadir: string);
procedure ReloadSplash(datadir: string);
procedure AfterLoad;
procedure DoKeyUp(key: byte);
procedure DoKeyPass(key: byte);
function ProcessQuitting: boolean;

function emit(x, y, r: single): zglPEmitter2D;
procedure noemit(item: zglPEmitter2D); overload;
procedure noemit; overload;

procedure ScrollToCenter(x, y: single);

var
  Camera: zglTCamera2D;

  InitX, InitY: single;
  Moved, MouseScrolling: boolean;
  savex, savey: integer;

  //TAnimatedSprite;
  //TSprite;
  debug: string;

implementation

uses uglobal, uUI, uGameUI, ugameactions;

procedure DoKeyUp(key: byte);
begin
  //case key of
  //  K_ESCAPE: Quitting := true;
  //  //K_R: NewGame;
  //end;
end;

procedure DoKeyPass(key: byte);
begin
  //case key of
  //  K_W: TheMap.Player.JustGo(Up);
  //end;
end;

procedure LoadSplash(datadir: string);
begin
  fntMain := font_LoadFromFile(datadir + 'font.zfi');
  scr_SetOptions(SCREENX, SCREENY, REFRESH_DEFAULT, False, True);
end;

function emit(x, y, r: single): zglPEmitter2D;
begin
  emitterFire.ParParams.SizeXS := 8 * r * 2;
  emitterFire.ParParams.SizeYS := 8 * r * 2;
  emitterFire.ParParams.Frame[0] := 0;
  emitterFire.ParParams.Frame[1] := 0;
  emitterFire.Params.Loop := True;
  emitterFire.Params.LifeTime := 1000;
  pengine2d_AddEmitter(emitterFire, @Result, x, y);
end;

procedure noemit(item: zglPEmitter2D);
begin
  pengine2d_DelEmitter(item^.ID);
end;

procedure noemit;
begin
  pengine2d_ClearAll;
  //  pengine2d_AddEmitter(emitterRain, nil, 0, 0);
end;

procedure ScrollToCenter(x, y: single);
begin
  Camera.X := x - SCREENX / 2;
  Camera.Y := y - SCREENY / 2;
end;


procedure LoadAll(datadir: string);
begin
  randomize;
  log_add('Seed: ' + u_IntToStr(RandSeed));
  //RandSeed := 20118419;

  fntSecond := font_LoadFromFile(datadir + 'font2.zfi');

  TextureDataDir := datadir;
  //TAnimatedSprite.Create('human_'+IntToStr(ord(i)), 5);
  //TSprite.Create('human_face_'+IntToStr(ord(i)));
  emitterFire := emitter2d_LoadFromFile(datadir + 'emitter_fire.zei');
  emitterRain := emitter2d_LoadFromFile(datadir + 'emitter_rain.zei');
  pengine2d_Set(@particles);

  InitUI;
  cam2d_Init(Camera);
  log_Add('init complete');
end;

procedure DrawFrame;
begin
  batch2d_Begin;
  try
    pr2d_Rect(0, 0, SCREENX, SCREENY, Black, 255, PR2D_FILL);
    cam2d_Set(@Camera);
    DrawAll;
    pengine2d_Draw;
    cam2d_Set(nil);
    DrawGameUI;
    DrawUI;
  finally
    batch2d_End;
  end;
  text_Draw(fntSecond, 0, 0, 'FPS: ' + u_IntToStr(zgl_Get(RENDER_FPS)));
  if debug <> '' then
    text_Draw(fntSecond, 0, 100, 'DEBUG: ' + debug);
end;

procedure DrawProgress;
begin
  pr2d_Rect(5 * MINDIST, SCREENY / 2, 500, 30, $00FF00);
  pr2d_Rect(5 * MINDIST, SCREENY / 2, 500 * res_GetCompleted / 100,
    30, $00FF00, 255, PR2D_FILL);
  text_Draw(fntMain, 5 * MINDIST, SCREENY / 2 - 2 * MINDIST, 'Loading... ' +
    u_IntToStr(res_GetCompleted) + '%');
end;

procedure ProcessTime;
begin
  //show_None: TheMap.Update;
  if ModalWindow <> nil then
    TGameWindow(ModalWindow).Process;
end;


procedure MouseUp(aX, aY: integer);
begin
  MouseScrolling := False;
  if moved then
    exit;

  //if Modal <> show_None then

  if ClickUI(ax, ay, LeftUp) then
    exit;
  OnClick(ax + Camera.X, aY + Camera.Y);
end;

procedure MouseRight(aX, aY: integer);
begin
  if moved then
    exit;
  ClickUI(ax, ay, RightUp);
end;

procedure MouseDown(aX, aY: integer);
begin
  savex := ax;
  savey := aY;
  InitX := aX;
  InitY := aY;
  Moved := False;
  if ClickUI(ax, ay, LeftDown) then
    exit;
end;

procedure MouseMoved(aX, aY: integer);
begin
  MouseScrolling := False;
end;


procedure MousePressed(aX, aY: integer);
begin
  if ModalWindow <> nil then
    exit;
  if Moved or (abs(aX - InitX) > 2 * MINDIST) or (abs(aY - InitY) > 2 * MINDIST) then
  begin
    MouseScrolling := True;
    Moved := True;
    Camera.X := Camera.X - (aX - savex);
    Camera.Y := Camera.Y - (aY - savey);
    //Camera.Center.X := MAP_X*TILE_SIZE/2;
    //Camera.Center.Y := MAP_Y*TILE_SIZE/2;
    savex := ax;
    savey := aY;
  end;
end;

procedure TimedUpdate(dt: double);
begin
  pengine2d_Proc(2 * dt);
end;

function GetScreenX: integer;
begin
  Result := SCREENX;
end;

function GetScreenY: integer;
begin
  Result := SCREENY;
end;

procedure ReloadMedia(datadir: string);
begin
  {$ifdef cpuarm}
  scr_SetOptions(SCREENX, SCREENY, REFRESH_DEFAULT, False, False);
  log_add('reloading');
  font_RestoreFromFile(fntSecond, datadir + 'font2.zfi');
  emitter2d_RestoreAll();
  TextureDataDir := datadir;
  ReloadAllTextures(datadir);
  log_add('reloading done');
  {$endif}
end;

procedure ReloadSplash(datadir: string);
begin
  {$ifdef cpuarm}
  log_add('reloading init');
  font_RestoreFromFile(fntMain, datadir + 'font.zfi');
  {$endif}
end;

procedure AfterLoad;
begin
  log_Add('after load');
  ProcessLoadedTextures;
  InitActions;
  NewGame;
  log_Add('after load complete');
end;

function ProcessQuitting: boolean;
begin
  Result := True;
end;


begin
end.
