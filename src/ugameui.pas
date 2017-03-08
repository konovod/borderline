unit uGameUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uUI, ugameactions, uglobal;

type

  { TDateButton }

  TDateButton = class(TButton)
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
  end;

  { TActionButton }

  TActionButton = class(TButton)
    index: integer;
    function Visible: Boolean;override;
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
    constructor Create(aX, aY, aW, aH: Single; aindex: integer);
    function MyAction: TAction;
  end;

  { TGameWindow }

  TGameWindow = class(TModalWindow)
    function ProcessClick(x, y: Integer; event: TMouseEvent): Boolean;override;
    procedure Draw; override;
  end;

  { TResearchWindow }

  TResearchWindow = class(TGameWindow)
    procedure Draw; override;
  end;

  { TPrioritiesWindow }

  TPrioritiesWindow = class(TGameWindow)
    procedure Draw; override;
  end;

  { TLogWindow }

  TLogWindow = class(TGameWindow)
    procedure Draw; override;
  end;

  { TBattleWindow }

  TBattleWindow = class(TGameWindow)
    procedure Draw; override;
  end;

var
  ResearchWindow: TResearchWindow;
  PrioritiesWindow: TPrioritiesWindow;
  LogWindow: TLogWindow;
  BattleWindow: TBattleWindow;

procedure InitUI;


implementation

uses ugame, zgl_mouse, math;

{ TBattleWindow }

procedure TBattleWindow.Draw;
begin
  inherited Draw;
end;

{ TLogWindow }

procedure TLogWindow.Draw;
begin
  inherited Draw;
end;

{ TPrioritiesWindow }

procedure TPrioritiesWindow.Draw;
begin
  inherited Draw;
end;

{ TResearchWindow }

procedure TResearchWindow.Draw;
begin
  inherited Draw;
end;

{ TGameWindow }

function TGameWindow.ProcessClick(x, y: Integer; event: TMouseEvent): Boolean;
begin
  if not InRange(x/SCREENX, 0.5-MODAL_WIDTH/2, 0.5+MODAL_WIDTH/2) or
     not InRange(y/SCREENY, 0.5-MODAL_HEIGHT/2, 0.5+MODAL_HEIGHT/2) then
  begin
    Result := True;
    ModalWindow := nil;
  end
  else
    Result := True;
end;

procedure TGameWindow.Draw;
begin
  DrawPanelUI(0.5-MODAL_WIDTH/2, 0.5-MODAL_HEIGHT/2, MODAL_WIDTH, MODAL_HEIGHT, 0.9);
end;

{ TActionButton }

function TActionButton.Visible: Boolean;
begin
  Result := index < Length(ActiveActions);
end;

procedure TActionButton.Draw;
begin
  if MyAction.Allowed then
  begin
    if InRange(mouseX, X, X+W) and InRange(mouseY, Y, Y+H) then
      StdButton(MyAction.Text, X, Y, W, H, Active)
    else
      StdButton(MyAction.Text, X, Y, W, H, Normal)
  end
  else
    StdButton(MyAction.Text, X, Y, W, H, Inactive);
end;

procedure TActionButton.Click(event: TMouseEvent);
begin
  if MyAction.Allowed then MyAction.Execute;
end;

constructor TActionButton.Create(aX, aY, aW, aH: Single; aindex: integer);
begin
  inherited Create(ax,ay,aw,ah);
  index := aindex;
end;

function TActionButton.MyAction: TAction;
begin
  Result := ActiveActions[index];
end;

{ TDateButton }

procedure TDateButton.Draw;
begin
  StdButton(MyDateToStr(StarDate), X,Y,W,H,Inactive);
end;

procedure TDateButton.Click(event: TMouseEvent);
begin

end;

procedure InitUI;

procedure add(bt: TButton);
begin
  SetLength(IngameButtons, Length(IngameButtons)+1);
  IngameButtons[High(IngameButtons)] := bt;
end;

procedure addmodal(win: TModalWindow; bt: TButton);
begin
  SetLength(win.buttons, Length(win.buttons)+1);
  win.buttons[High(win.buttons)] := bt;
end;

var
  i, j: integer;
  cx, cy: single;
begin
  //game buttons: date and actions
  add(TDateButton.Create(0.40,0.01,0.2,0.06));
  cy := 0.1;
  cx := 0;
  for i := 1 to 15 do
  begin
    add(TActionButton.Create(TOPPANEL_LEFT+cx, cy, ACTIONBTN_WIDTH-0.02, 0.05, i-1));
    cx := cx+ACTIONBTN_WIDTH;
    if cx > TOPPANEL_WIDTH - ACTIONBTN_WIDTH then
    begin
      cx := 0;
      cy := cy+0.07;
    end;
  end;
  //modal windows:
  ResearchWindow := TResearchWindow.Create;
  LogWindow := TLogWindow.Create;
  BattleWindow := TBattleWindow.Create;
  PrioritiesWindow := TPrioritiesWindow.Create;
end;



end.

