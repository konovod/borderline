program project_desktop;

{$R project_desktop.res}

// RU: Этот файл содержит некоторые настройки(например использовать ли статическую компиляцию) и определения ОС под которую происходит компиляция.
{$I zglCustomConfig.cfg}

uses
  SysUtils, zgl_application, zgl_main, zgl_resources, zgl_screen, zgl_window,
  zgl_timers, zgl_font, zgl_utils, zgl_mouse, zgl_file, zgl_text, zgl_Log,
  zgl_keyboard, umain, ugame, uglobal, uUI, uTextures, uMap, uDelaunay, umapgen,
  uNameGen, uGameUI, ugameactions, uStaticData, uGameTypes;

var
  DirApp: UTF8String;
  DirHome: UTF8String;

procedure Init;
const
  basedir ={$IFDEF MACOSX} '' {$ELSE} './assets/' {$ENDIF};
begin
  LoadSplash(basedir);
  //res_BeginQueue(0);
  LoadAll(basedir);
  //res_EndQueue;
end;

procedure Draw;
begin
  if Ready then
    DrawFrame
  else if res_GetCompleted < 100 then
    DrawProgress
  else
  begin
    AfterLoad;
    Ready := True;
  end;
end;

procedure Update(dt: Double);
begin
  if Ready then
    TimedUpdate(dt);
end;

procedure _MouseUp(Key: Byte);
begin
  if Ready then
  begin
    if Key = M_BRIGHT then
      MouseRight(mouse_X, mouse_Y)
    else
      MouseUp(mouse_X, mouse_Y);
  end;
end;

procedure _MouseDown(Key: Byte);
begin
  if Ready then
	  MouseDown(mouse_X, mouse_Y);
end;

function _CanQuit: Boolean;
begin
 Result := ProcessQuitting;
end;

procedure _TestKeyPress( KeyCode : Byte );
begin
  if Ready then
	  DoKeyPass(KeyCode);
end;

procedure _TestKeyUp( KeyCode : Byte );
begin
  if Ready then
	  DoKeyUp(KeyCode);
end;

procedure Timer;
begin
  if Ready then
  begin
    if mouse_Down(0) then
      MousePressed(mouse_X, mouse_Y)
    else
      MouseMoved(mouse_X, mouse_Y);
    ProcessTime;
  end;
  if Quitting then zgl_Exit;
end;

begin
try
  DirApp := utf8_Copy(PAnsiChar(zgl_Get(DIRECTORY_APPLICATION)));
  DirHome := utf8_Copy(PAnsiChar(zgl_Get(DIRECTORY_HOME)));
  zgl_Reg(SYS_LOAD, @Init);
  zgl_Reg(SYS_DRAW, @Draw);
  zgl_Reg(INPUT_MOUSE_RELEASE, @_MouseUp);
  zgl_Reg(INPUT_MOUSE_PRESS, @_MouseDown);

  zgl_Reg(INPUT_KEY_PRESS, @_TestKeyPress);
  zgl_Reg(INPUT_KEY_RELEASE, @_TestKeyUp);
  zgl_Reg(SYS_CLOSE_QUERY, @_CanQuit);

  timer_Add(@Timer, 15);
  zgl_Reg( SYS_UPDATE, @Update );

  scr_SetOptions(SCREENX, SCREENY, REFRESH_DEFAULT, false, True);
  // RU: Указываем первоначальные настройки.
  wnd_ShowCursor( TRUE );
  zgl_Init();
except
  on E: Exception do
    log_add('Exception: '+E.ClassName+': '+E.Message);

end;
end.

