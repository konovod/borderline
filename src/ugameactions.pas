unit ugameactions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uGameTypes;

type
  TAction = class
    procedure Execute; virtual; abstract;
    function Allowed: boolean; virtual; abstract;
    function Visible: boolean; virtual; abstract;
    function Text: string; virtual; abstract;
    //TODO: hotkey
  end;

  { TJumpAction }
  TJumpAction = class(TAction)
    is_retreat: boolean;
    procedure Execute; override;
    function Allowed: boolean; override;
    function Visible: boolean; override;
    function Text: string; override;
  end;

  { TColonizeAction }

  TColonizeAction = class(TAction)
    procedure Execute; override;
    function Allowed: boolean; override;
    function Visible: boolean; override;
    function Text: string; override;
  end;

  { TAssaultAction }

  TAssaultAction = class(TAction)
    procedure Execute; override;
    function Allowed: boolean; override;
    function Visible: boolean; override;
    function Text: string; override;
  end;

  { TOwnSystemAction }

  TOwnSystemAction = class(TAction)
    function Allowed: boolean; override;
    function Visible: boolean; override;
  end;

  { TPrioritiesAction }

  TPrioritiesAction = class(TOwnSystemAction)
    procedure Execute; override;
    function Text: string; override;
  end;

  { TResearchAction }

  TResearchAction = class(TAction)
    procedure Execute; override;
    function Allowed: boolean; override;
    function Visible: boolean; override;
    function Text: string; override;
  end;

  { TCheckLogAction }

  TCheckLogAction = class(TAction)
    function Allowed: boolean; override;
    function Visible: boolean; override;
    procedure Execute; override;
    function Text: string; override;
  end;

procedure InitActions;

var
  ActiveActions, AllActions: array of TAction;

  FirstCapture: boolean = True;
  FirstColony: boolean = True;
  FirstBurned: boolean = True;

implementation

uses ugame, uMap, uMain, uGameUI, uUI, ubattle;

procedure InitActions;

  procedure adda(act: TAction);
  begin
    SetLength(AllActions, Length(AllActions) + 1);
    AllActions[Length(AllActions) - 1] := act;
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
    end;
  end
  else
    StartBattle(False);
end;

function TAssaultAction.Allowed: boolean;
begin
  Result := (PlayerSys.PopStatus = Alien) and (BattleResult in [SpaceWon, GroundWon]);
end;

function TAssaultAction.Visible: boolean;
begin
  Result := (PlayerSys.PopStatus = Alien);
end;

function TAssaultAction.Text: string;
begin
  Result := 'Capture';
end;

{ TColonizeAction }

procedure TColonizeAction.Execute;
begin
  PlayerSys.Colonize;
  Dec(PlayerFleet[Colonizer][1]);
end;

function TColonizeAction.Allowed: boolean;
begin
  Result := (PlayerSys.PopStatus = Colonizable) and
    (TotalCount(PlayerFleet[Colonizer]) > 0);
end;

function TColonizeAction.Visible: boolean;
begin
  Result := (PlayerSys.PopStatus = Colonizable);
end;

function TColonizeAction.Text: string;
begin
  Result := 'Colonize';
end;

{ TCheckLogAction }

function TCheckLogAction.Allowed: boolean;
begin
  Result := True;
end;

function TCheckLogAction.Visible: boolean;
begin
  Result := True;
end;

procedure TCheckLogAction.Execute;
begin
  ModalWindow := LogWindow;
end;

function TCheckLogAction.Text: string;
begin
  Result := 'Check log';
end;

{ TResearchAction }

procedure TResearchAction.Execute;
begin
  ModalWindow := ResearchWindow;
end;

function TResearchAction.Allowed: boolean;
begin
  Result := True;
end;

function TResearchAction.Visible: boolean;
begin
  Result := True;
end;

function TResearchAction.Text: string;
begin
  Result := 'Research';
end;

{ TPrioritiesAction }

procedure TPrioritiesAction.Execute;
begin
  PlayerSys.Priorities.Research := 0;
  ModalWindow := PrioritiesWindow;
end;

function TPrioritiesAction.Text: string;
begin
  Result := 'Manage';
end;

{ TOwnSystemAction }

function TOwnSystemAction.Allowed: boolean;
begin
  Result := (PlayerSys = Cursor) and (PlayerSys.PopStatus = Own);
end;

function TOwnSystemAction.Visible: boolean;
begin
  Result := (PlayerSys = Cursor) and (PlayerSys.PopStatus = Own);
end;

{ TJumpAction }

procedure TJumpAction.Execute;
var
  f: boolean;
begin
  if not is_retreat then
    NRetreats := 0;
  if (Cursor <> PlayerSys) and (Cursor <> nil) then
    JumpTarget := Cursor
  else
    JumpTarget := PlayerSys;
  NextTurn;
  if (Cursor <> PlayerSys) and (Cursor <> nil) then
  begin
    if Assigned(PlayerSys) then
      PlayerSys.State := Visited;
    PrevSystem := PlayerSys;
    PlayerSys := Cursor;
    TriggerMines(True, PrevSystem, PlayerSys);
  end;
  f := FirstColony and (PlayerSys.VisitTime = 0) and
    (PlayerSys.PopStatus = Colonizable);
  PlayerSys.Enter;
  if f then
  begin
    FirstColony := False;
    PlayerSys.LogEvent('System has some sort of civilization that did''nt get even to middle ages. ');
    LogEventRaw('   We can colonize it easily without a shot.');
    ModalWindow := LogWindow;
  end;
  if (PlayerSys.PopStatus = WipedOut) and FirstBurned then
  begin
    PlayerSys.LogEvent('All planets of system was turned into sort of grey goo.');
    LogEventRaw('   perhaps it was the nanoreplicating weapon.');
    FirstBurned := False;
    ModalWindow := LogWindow;
  end;
  ScrollToCenter(PlayerSys.X, PlayerSys.Y);
end;

function TJumpAction.Allowed: boolean;
begin
  Result := (Cursor = PlayerSys) or (Cursor = nil) or Cursor.Linked(PlayerSys);
end;

function TJumpAction.Visible: boolean;
begin
  Result := True;
end;

function TJumpAction.Text: string;
begin
  if (Cursor = PlayerSys) or (Cursor = nil) then
    Text := 'Wait'
  else
    Text := 'Jump';
end;

end.
