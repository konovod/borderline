unit uGameUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uUI, ugameactions, uglobal, uGameTypes;

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
    procedure Close; virtual;
  private
    procedure addbutton(bt: TButton);
  end;

  TResearchWindow = class;

  { TSelectResearchButton }

  TSelectResearchButton = class(TButton)
    owner: TResearchWindow;
    res: THumanResearch;
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
    constructor Create(aX, aY, aW, aH: Single; aowner: TResearchWindow; ares: THumanResearch);
  end;

  { TResearchWindow }

  TResearchWindow = class(TGameWindow)
    cursor: THumanResearch;
    procedure Draw; override;
    constructor Create;
  end;

  TPriorityType = (prFree, prResearch, prShips, prMines);

  { TPriorityBar }

  TPrioritiesWindow = class;
  TPriorityBar = class(TButton)
    owner: TPrioritiesWindow;
    typ: TPriorityType;
    index: integer;
    function Visible: boolean;override;
    function MyText: string;
    function MyValue: TPriorityLevel;
    procedure ApplyValue(value: TPriorityLevel);
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
    constructor Create(aX, aY, aW, aH: Single; aowner: TPrioritiesWindow; atyp: TPriorityType; aindex: integer);
  end;

  { TPrioritiesWindow }

  TPrioritiesWindow = class(TGameWindow)
    procedure Draw; override;
    constructor Create;
    procedure Close; override;
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

uses ugame, uStaticData, uMap, zgl_mouse, math, zgl_text, zgl_math_2d, zgl_primitives_2d;

{ TPriorityBar }

function TPriorityBar.Visible: boolean;
begin
  Result := (typ <> prMines) or (index < length(PlayerSys.Mines));
end;

function TPriorityBar.MyText: string;
begin
  case typ of
    prFree: Result := 'Remaining points';
    prResearch: Result := 'Do research';
    prShips: Result := LowerCase(SHIP_NAMES[THumanShips(index)])+'s';
    prMines: Result := 'to '+PlayerSys.Links[index].Name;
  end;
end;

function TPriorityBar.MyValue: TPriorityLevel;
begin
  case typ of
    prFree: Result := FreePoints(PlayerSys.Priorities);
    prResearch: Result := PlayerSys.Priorities.Research + FreePoints(PlayerSys.Priorities);
    prShips: Result := PlayerSys.Priorities.Ships[THumanShips(index)];
    prMines: Result := PlayerSys.Priorities.Mines[index];
  end;
end;

procedure TPriorityBar.ApplyValue(value: TPriorityLevel);
begin
  case typ of
    prFree: exit;
    prResearch: exit;//PlayerSys.Priorities.Research := value;
    prShips: PlayerSys.Priorities.Ships[THumanShips(index)] := value;
    prMines: PlayerSys.Priorities.Mines[index] := value;
  end;
end;

procedure TPriorityBar.Draw;
var
  R: zglTRect;
begin
  //StdButton(MyText, X,Y,W,H,Normal);
  pr2d_Rect( X+W/2, Y, W/2, H, IntfBack, 255, PR2D_FILL or PR2D_SMOOTH );
  pr2d_Rect( X+W/2, Y, W/2, H, IntfText, 255, 0 );
  pr2d_Rect( X+W/2, Y, MyValue/100*W/2, H, IntfDark, 255, PR2D_FILL or PR2D_SMOOTH );
  R.X := X+W/2;
  R.Y := Y;
  R.W := W/2;
  R.H := H;
  text_DrawInRectEx(fntMain, R, 1, 0, IntToStr(MyValue)+'%', 255, IntfText, TEXT_VALIGN_BOTTOM + TEXT_HALIGN_LEFT);

	if mouse_Down(M_BLEFT) and InRect(mouseX, mouseY, R.X, R.Y, R.W, R.H) then
  	Click(LeftDown);


  R.X := X;
  R.Y := Y;
  R.W := W/2;
  R.H := H;
  text_DrawInRectEx(fntMain, R, 0.8, 0, MyText+': ', 255, IntfText, TEXT_VALIGN_BOTTOM + TEXT_HALIGN_RIGHT);
end;

procedure TPriorityBar.Click(event: TMouseEvent);
var
	ax: single;
  val: TPriorityLevel;
begin
	ax := (mouseX - X)/W;
  if ax < 0.4 then exit;
  val := EnsureRange(Trunc(200*(ax-0.5)), 0, MyValue + FreePoints(PlayerSys.Priorities));
  ApplyValue(val);
end;

constructor TPriorityBar.Create(aX, aY, aW, aH: Single;
  aowner: TPrioritiesWindow; atyp: TPriorityType; aindex: integer);
begin
  inherited Create(ax,ay,aw,ah);
  owner := aowner;
  typ := atyp;
  index := aindex;
end;

{ TSelectResearchButton }

procedure TSelectResearchButton.Draw;
var
  st: TInvertState;
begin
  if res = ResearchPriority then
    st := Active
  else if res = owner.cursor then
    st := Normal
  else
    st := Inactive;
  StdButton(RESEARCH_NAMES[res], X,Y,W,H,st);
end;

procedure TSelectResearchButton.Click(event: TMouseEvent);
begin
  owner.cursor := res;
  ResearchPriority := res;
end;

constructor TSelectResearchButton.Create(aX, aY, aW, aH: Single;
  aowner: TResearchWindow; ares: THumanResearch);
begin
  inherited Create(ax,ay,aw,ah);
  owner := aowner;
  res := ares;
end;

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

procedure draw_label(x,y: single; text: string);
var
  BASE_X, BASE_Y: single;
begin
  BASE_X := (0.5-MODAL_WIDTH/2)*SCREENX;
  BASE_Y := (0.5-MODAL_HEIGHT/2)*SCREENY;
  text_DrawEx(fntMain, BASE_X + x*SCREENX, BASE_Y + y*SCREENY,
  						0.8,0,text,255, IntfText, 0);
end;




begin
  inherited Draw;
  draw_label(0.02, 0.02, 'System will spend worktime to:');
  draw_label(0.12, 0.26, 'Build ships');
  draw_label(0.52, 0.26, 'Place mines at warp point');
end;

constructor TPrioritiesWindow.Create;
var
  i: integer;
  ship: THumanShips;
  cx, cy, hg, wd: single;
begin
  cy := 0.5-MODAL_HEIGHT/2 + 0.01;
  cx := 0.5-MODAL_WIDTH/2 + 0.02;
  wd := 0.42;
  hg := 0.07;
  cy := cy+hg+0.01;
  addbutton(TPriorityBar.Create(cx+0.1, cy, wd+0.2, hg, self, prResearch, 0));
  cx := 0.5-MODAL_WIDTH/2 + 0.02;
  cy := 0.5-MODAL_HEIGHT/2 + 0.22 - hg-0.01;
  cy := cy+hg+0.01;
  cy := cy+hg+0.01;
  for ship in THumanShips do
  begin
    addbutton(TPriorityBar.Create(cx, cy, wd, hg, self, prShips, ord(ship)));
    cy := cy+hg+0.01;
  end;
  cy := 0.5-MODAL_HEIGHT/2 + 0.22;
  cy := cy+hg+0.01;
  cx := 0.5-MODAL_WIDTH/2 + 0.45;
  for i := 0 to 100 do
  begin
    addbutton(TPriorityBar.Create(cx, cy, wd, hg, self, prMines, i));
    cy := cy+hg+0.01;
  end;
end;

procedure TPrioritiesWindow.Close;
var
  pt: TPriorityLevel;
begin
  pt := freepoints(PlayerSys.Priorities);
  if pt > 0 then
    PlayerSys.Priorities.Research := PlayerSys.Priorities.Research + pt;
end;

{ TResearchWindow }

procedure TResearchWindow.Draw;
var
  bt: TButton;
  descx, descy, wd, hg: single;
begin
  inherited Draw;
  for bt in buttons do
    if InRect(mouseX, mouseY, bt.X, bt.Y,bt.W,bt.H) then
      cursor := TSelectResearchButton(bt).res;

  descx := 0.4;
  descy := 0.3;
  wd := 0.5+MODAL_WIDTH/2 - descx;
  hg := 0.5+MODAL_HEIGHT/2 - descy;
  DrawPanelUI(descx, descy, wd,hg, 1);
  DrawSomeText(SCREENX*descx, SCREENY*descy, SCREENX*wd,SCREENY*hg,RESEARCH_NAMES[cursor],RESEARCH_DESC[cursor]);
end;

constructor TResearchWindow.Create;
var
  res: THumanResearch;
  cx, cy, hg, wd: single;
begin
  cy := 0.5-MODAL_HEIGHT/2 + 0.02;
  cx := 0.5-MODAL_WIDTH/2 + 0.02;
  wd := 0.25;
  hg := 0.07;
  for res in THumanResearch do
  begin
    addbutton(TSelectResearchButton.Create(cx, cy, wd, hg, self, res));
    cy := cy+hg+0.01;
  end;
end;

{ TGameWindow }

function TGameWindow.ProcessClick(x, y: Integer; event: TMouseEvent): Boolean;
var
  inner, closebt: boolean;
begin
  inner := InRect(x/SCREENX, y/SCREENY, 0.5-MODAL_WIDTH/2, 0.5-MODAL_HEIGHT/2, MODAL_WIDTH, MODAL_HEIGHT);
  closebt := InRect(x/SCREENX, y/SCREENY,
                 0.5+MODAL_WIDTH/2-CLOSE_WIDTH,
                 0.5-MODAL_HEIGHT/2,
                 CLOSE_WIDTH,
                 CLOSE_WIDTH);
  if closebt or not inner then
  begin
    Close;
    Result := True;
    ModalWindow := nil;
  end
  else
    Result := True;
end;

procedure TGameWindow.Draw;
begin
  DrawPanelUI(0.5-MODAL_WIDTH/2, 0.5-MODAL_HEIGHT/2, MODAL_WIDTH, MODAL_HEIGHT, 0.9);
  StdButton('X',
        SCREENX*(0.5+MODAL_WIDTH/2-CLOSE_WIDTH),
        SCREENY*(0.5-MODAL_HEIGHT/2),
        SCREENX*CLOSE_WIDTH,
        SCREENX*CLOSE_WIDTH);
end;

procedure TGameWindow.Close;
begin

end;

procedure TGameWindow.addbutton(bt: TButton);
begin
  SetLength(buttons, Length(buttons)+1);
  buttons[High(buttons)] := bt;
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
    if (ModalWindow = nil) and InRect(mouseX, mouseY, X, Y, W, H) then
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

var
  i: integer;
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

