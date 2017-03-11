unit ugameactions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uGameTypes;

type
  TAction = class
    procedure Execute; virtual; abstract;
    function Allowed: Boolean; virtual; abstract;
    function Visible: Boolean; virtual; abstract;
    function Text: String; virtual; abstract;
    //TODO: hotkey
  end;

  { TJumpAction }
  TJumpAction = class(TAction)
    procedure Execute; override;
    function Allowed: Boolean; override;
    function Visible: Boolean; override;
    function Text: String; override;
  end;

  { TColonizeAction }

  TColonizeAction = class(TAction)
    procedure Execute; override;
    function Allowed: Boolean; override;
    function Visible: Boolean; override;
    function Text: String; override;
  end;

  { TAssaultAction }

  TAssaultAction = class(TAction)
    procedure Execute; override;
    function Allowed: Boolean; override;
    function Visible: Boolean; override;
    function Text: String; override;
  end;

  { TOwnSystemAction }

  TOwnSystemAction = class(TAction)
    function Allowed: Boolean; override;
    function Visible: Boolean; override;
  end;

  { TPrioritiesAction }

  TPrioritiesAction = class(TOwnSystemAction)
    procedure Execute; override;
    function Text: String; override;
  end;

  { TResearchAction }

  TResearchAction = class(TAction)
    procedure Execute; override;
    function Allowed: Boolean; override;
    function Visible: Boolean; override;
    function Text: String; override;
  end;

  { TCheckLogAction }

  TCheckLogAction = class(TAction)
    function Allowed: Boolean; override;
    function Visible: Boolean; override;
    procedure Execute; override;
    function Text: String; override;
  end;

procedure InitActions;

var
  ActiveActions, AllActions: array of TAction;
  FirstCapture: Boolean = true;
  FirstColony: Boolean = true;
implementation

uses ugame, uMap, uMain, uGameUI, uUI, ubattle;

procedure InitActions;
  procedure adda(act: TAction);
  begin
    SetLength(AllActions, Length(AllActions)+1);
    AllActions[Length(AllActions)-1] := act;
  end;
begin
  adda(TJumpAction.Create);
  adda(TResearchAction.Create);
  adda(TPrioritiesAction.Create);
  adda(TCheckLogAction.Create);
  adda(TColonizeAction.Create);
  adda(TAssaultAction.Create);
  ActiveActions := AllActions;
end;

{ TAssaultAction }

procedure TAssaultAction.Execute;
begin
  if BattleResult = GroundWon then
  begin
    PlayerSys.Capture;
    if FirstCapture then
    begin
      ModalWindow := LogWindow;
      FirstCapture := False;
    end
  end
  else
    StartBattle(false);
end;

function TAssaultAction.Allowed: Boolean;
begin
  Result := (PlayerSys.PopStatus = Alien) and (BattleResult in [SpaceWon, GroundWon]);
end;

function TAssaultAction.Visible: Boolean;
begin
  Result := (PlayerSys.PopStatus = Alien) ;
end;

function TAssaultAction.Text: String;
begin
  Result := 'Capture'
end;

{ TColonizeAction }

procedure TColonizeAction.Execute;
begin
  PlayerSys.Colonize;
  Dec(PlayerFleet[Colonizer][1]);
end;

function TColonizeAction.Allowed: Boolean;
begin
  Result := (PlayerSys.PopStatus = Colonizable) and (TotalCount(PlayerFleet[Colonizer])>0);
end;

function TColonizeAction.Visible: Boolean;
begin
  Result := (PlayerSys.PopStatus = Colonizable);
end;

function TColonizeAction.Text: String;
begin
  Result := 'Colonize';
end;

{ TCheckLogAction }

function TCheckLogAction.Allowed: Boolean;
begin
  Result := True;
end;

function TCheckLogAction.Visible: Boolean;
begin
  Result := True;
end;

procedure TCheckLogAction.Execute;
begin
  ModalWindow := LogWindow;
end;

function TCheckLogAction.Text: String;
begin
  Result := 'Check log'
end;

{ TResearchAction }

procedure TResearchAction.Execute;
begin
  ModalWindow := ResearchWindow;
end;

function TResearchAction.Allowed: Boolean;
begin
  Result := True;
end;

function TResearchAction.Visible: Boolean;
begin
  Result := True;
end;

function TResearchAction.Text: String;
begin
  Result := 'Research'
end;

{ TPrioritiesAction }

procedure TPrioritiesAction.Execute;
begin
  PlayerSys.Priorities.Research := 0;
  ModalWindow := PrioritiesWindow;
end;

function TPrioritiesAction.Text: String;
begin
  Result := 'Manage'
end;

{ TOwnSystemAction }

function TOwnSystemAction.Allowed: Boolean;
begin
  Result := (PlayerSys = Cursor) and (PlayerSys.PopStatus = Own);
end;

function TOwnSystemAction.Visible: Boolean;
begin
  Result := (PlayerSys = Cursor) and (PlayerSys.PopStatus = Own);
end;

{ TJumpAction }

procedure TJumpAction.Execute;
var
  f: boolean;
begin
  NextTurn;
  if (Cursor <> PlayerSys) and (Cursor <> nil) then
  begin
    if Assigned(PlayerSys) then
      PlayerSys.State := Visited;
    PrevSystem := PlayerSys;
    PlayerSys := Cursor;
  end;
  f :=  FirstColony and (PlayerSys.VisitTime = 0) and (PlayerSys.PopStatus = Colonizable);
  PlayerSys.Enter;
  if f then
  begin
    FirstColony := False;
    PlayerSys.LogEvent('System has some sort of civilization that did''nt get ');
    LogEventRaw('   even to middle ages. We can colonize it easily without a shot.');
    ModalWindow := LogWindow;
  end;
  ScrollToCenter(PlayerSys.X, PlayerSys.Y);
end;

function TJumpAction.Allowed: Boolean;
begin
  Result := (Cursor = PlayerSys)or (Cursor = nil) or Cursor.Linked(PlayerSys);
end;

function TJumpAction.Visible: Boolean;
begin
  Result := True;
end;

function TJumpAction.Text: String;
begin
  if (Cursor = PlayerSys) or (Cursor = nil) then
    Text := 'Wait'
  else
    Text := 'Jump';
end;

end.

