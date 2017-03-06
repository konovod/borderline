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

procedure InitActions;

var
  ActiveActions, AllActions: array of TAction;
implementation

uses ugame, uMap, uMain;

procedure InitActions;
  procedure adda(act: TAction);
  begin
    SetLength(AllActions, Length(AllActions)+1);
    AllActions[Length(AllActions)-1] := act;
  end;
begin
  adda(TJumpAction.Create);



  ActiveActions := AllActions;
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
    PlayerSys.Enter;
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

