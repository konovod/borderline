library borderline;

// RU: Этот файл содержит некоторые настройки(например использовать ли статическую компиляцию) и определения ОС под которую происходит компиляция.
// EN: This file contains some options(e.g. whether to use static compilation) and defines of OS for which is compilation going.
{$I zglCustomConfig.cfg}

uses
  zgl_application, zgl_main, zgl_screen, zgl_window, zgl_timers, zgl_font,
  zgl_utils, zgl_mouse, zgl_file, zgl_resources, zgl_text, zgl_Log, uMain,
  uglobal,

  MySockets,

uUI, uTextures;

type
  TGameState = (Initial, ThreadedLoading, Ready, Paused, Reloading, ThreadedReloading);

var
  DirApp  : UTF8String;
  DirHome : UTF8String;
  GameState: TGameState = Initial;
  tm1, tm2: zglPTimer;

procedure Init;
begin
  zgl_Enable( CORRECT_RESOLUTION );
  scr_CorrectResolution( GetScreenX, GetScreenY );
  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  LoadSplash('assets/');
  file_CloseArchive();
  res_BeginQueue(0);
  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  LoadAll('assets/');
  file_CloseArchive();
  res_EndQueue;
  GameState := ThreadedLoading;
end;

procedure Draw;
begin
  //log_add('draw frame '+u_IntToStr(Ord(GameState)));
  case GameState of
    Initial, Reloading: exit;
    Paused, Ready: DrawFrame;
    ThreadedLoading, ThreadedReloading:
    begin
      //log_add('percent '+u_IntToStr(res_GetCompleted));
      DrawProgress;
      if res_GetCompleted >= 100 then
      begin
        if GameState = ThreadedLoading then
        begin
          AfterLoad;
          GameState := Ready;
        end
        else
        begin
          log_add('crunch!');
          //timer_Del(tm1);
          //timer_Del(tm2);
          //timer_Reset;
          GameState := Ready;
        end;
      end;
    end;
    else exit;
  end;
end;

procedure Update( dt : Double );
begin
  if GameState = Ready then
    TimedUpdate(dt);
end;

procedure _MouseUp(Key: Byte);
begin
  MouseUp(mouse_X, mouse_Y);
end;

procedure _ReloadMedia();
begin
  GameState := Reloading;
  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  ReloadSplash('assets/');
  //file_CloseArchive();
  //res_BeginQueue(0);
  //file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  ReloadMedia('assets/');
  file_CloseArchive();
  //res_EndQueue;
  GameState := ThreadedReloading;
  //GameState := Ready;
end;

procedure _MouseDown(Key: Byte);
begin
  MouseDown(mouse_X, mouse_Y);
end;

function _CanQuit: Boolean;
begin
  Result := ProcessQuitting;
end;

procedure Timer2;
begin
  if GameState = Ready then
    TestOnline;
end;

procedure Timer;
begin
  if GameState = Ready then
  begin
    if mouse_Down(0) then MousePressed(mouse_X, mouse_Y);
    ProcessTime;
  end;
end;

procedure Java_zengl_android_ZenGL_Main( var env; var thiz ); cdecl;
begin
  DirApp  := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  DirHome := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_HOME ) ) );
  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );
  zgl_Reg( INPUT_MOUSE_RELEASE, @_MouseUp );
  zgl_Reg( INPUT_MOUSE_PRESS, @_MouseDown );
  zgl_Reg( SYS_ANDROID_RESTORE, @_ReloadMedia );
  zgl_Reg(SYS_CLOSE_QUERY, @_CanQuit);

  tm1 := timer_Add(@Timer, 15);
  tm2 := timer_Add(@Timer2, 500);
  zgl_Reg( SYS_UPDATE, @Update );

  // RU: Указываем первоначальные настройки.
  // EN: Set screen options.
  scr_SetOptions( 100, 100, REFRESH_DEFAULT, FALSE, FALSE );
end;

exports
  // RU: Эта функция должна быть реализована проектом, который использует ZenGL
  // EN: This function should be implemented by project which is use ZenGL
  Java_zengl_android_ZenGL_Main,

  // RU: Функции реализуемые ZenGL, которые должны быть экспортированы
  // EN: Functions which are implemented by ZenGL and should be exported
  {$I android_export.inc}

Begin
End.
