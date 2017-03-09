unit ugameactions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

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
implementation

uses ugame, uMap, uMain, uGameUI, uUI;

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
  ActiveActions := AllActions;
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
  //TODO
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
  Result := (PlayerSys = Cursor);//TODO: check planet ownership
end;

function TOwnSystemAction.Visible: Boolean;
begin
  Result := (PlayerSys = Cursor);//TODO: check planet ownership
end;

{ TJumpAction }

procedure TJumpAction.Execute;
begin
  NextTurn;
  if (Cursor <> PlayerSys) and (Cursor <> nil) then
  begin
    if Assigned(PlayerSys) then
      PlayerSys.State := Visited;
    PlayerSys := Cursor;
  end;
  PlayerSys.Enter;
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

