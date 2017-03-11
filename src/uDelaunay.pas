//Credit to Paul Bourke (pbourke@swin.edu.au) for the original Fortran 77 Program :))
//Conversion to Visual Basic by EluZioN (EluZioN@casesladder.com)
//Conversion from VB to Delphi6 by Dr Steve Evans (steve@lociuk.com)
///////////////////////////////////////////////////////////////////////////////
//June 2002 Update by Dr Steve Evans (steve@lociuk.com): Heap memory allocation
//added to prevent stack overflow when MaxVertices and MaxTriangles are very large.
//Additional Updates in June 2002:
//Bug in InCircle function fixed. Radius r := Sqrt(rsqr).
//Check for duplicate points added when inserting new point.
//For speed, all points pre-sorted in x direction using quicksort algorithm and
//triangles flagged when no longer needed. The circumcircle centre and radius of
//the triangles are now stored to improve calculation time.

//June 2005 (More) Dynamic memory allocation and a few optimizations added by
//Gunnar Blumert (gunnar@blumert.de)
///////////////////////////////////////////////////////////////////////////////
//You can use this code however you like providing the above credits remain in tact

unit uDelaunay;

interface

uses SysUtils,
{$IFDEF DEBUG}
  Windows, Classes,
{$ENDIF}
  Types, Math;

type
  DelaunayFloat = single;

// Set these values as appropriate for your application
// If these values are not sufficient, more memory will
// be allocated as needed
const
  InitialVertexCount = 10000;
  Vertex_Increment = 1000;
  ExPtTolerance = 0.000001;

//Points (Vertices)
type
  dVertex = record
    x, y :DelaunayFloat;
    Original :integer;
  end;

//Created Triangles, vv# are the vertex pointers
type
  dTriangle = record
    vv0 :longint;
    vv1 :longint;
    vv2 :longint;
    PreCalc :integer;
    xc, yc, r :DelaunayFloat;
  end;

type
  TDVertex = array of dVertex;

  TDVertexClass = class
  private
    fData :TDVertex;
    procedure SetItem(Index :integer; Value :dVertex);
    function GetItem(Index :integer) :dVertex;
  public
    constructor Create(Capacity :integer);
    property Items[index :integer] :dVertex read getitem write setitem; default;
  end;

type
  TDTriangle = array of dTriangle;

  TDTriangleClass = class
  private
    fData :TDTriangle;
    procedure SetItem(Index :integer; Value :dTriangle);
    function GetItem(Index :integer) :dTriangle;
  public
    constructor Create(Capacity :integer);
    property Items[index :integer] :dTriangle read getitem write setitem; default;
  end;

  TByteArray = array of byte;

  TBoolArrayClass = class
  private
    fData :TByteArray;
    function GetItem(Index :integer) :boolean;
    procedure SetItem(Index :integer; Value :boolean);
    function ByteIndex(Index :integer) :integer;
    function BitMask(Index :integer) :byte;
  public
    constructor Create(Capacity :integer);
    property Items[index :integer] :boolean read GetItem write Setitem; default;
  end;

  TIntArray = array of integer;

  TIntArrayClass = class
  private
    fData :TIntArray;
    function GetItem(Index :integer) :integer;
    procedure SetItem(Index :integer; Value :integer);
  public
    constructor Create(Capacity :integer);
    property Items[index :integer] :integer read getitem write setitem; default;
  end;

  TDEdges = array[0..2] of TIntArrayClass;

type
  TDelaunay = class
  private
    { Private declarations }
    function InCircle(xp, yp, x1, y1, x2, y2, x3, y3 :DelaunayFloat;
      var xc :DelaunayFloat; var yc :DelaunayFloat; var r :DelaunayFloat;
      j :integer) :boolean;
    //    Function WhichSide(xp, yp, x1, y1, x2, y2: DelaunayFloat): Integer;
    function Triangulate(nvert :integer) :integer;
    function FindPoint(_x, _y :DelaunayFloat; out index :integer) :boolean;
  public
    { Public declarations }
    Vertex :TDVertexClass;
    Triangle :TDTriangleClass;
    HowMany :integer;
    tPoints :integer; //Variable for total number of points (vertices)
    constructor Create;
    destructor Destroy; override;
    procedure Mesh;
    procedure AddPoint(x, y :DelaunayFloat);
    procedure QuickSort(Low, High :integer);
  end;

implementation

constructor TDVertexClass.Create(Capacity :integer);
begin
  inherited Create;
  SetLength(fData, Capacity);
end;

function TDVertexClass.GetItem(Index :integer) :dVertex;
begin
  if High(fData) < Index then
    SetLength(fData, Index + Vertex_Increment);
  Result := fData[Index];
end;

procedure TDVertexClass.SetItem(Index :integer; Value :dVertex);
begin
  if High(fData) < Index then
    SetLength(fData, Index + Vertex_Increment);
  fData[Index] := Value;
end;

constructor TDTriangleClass.Create(Capacity :integer);
begin
  inherited Create;
  SetLength(fData, Capacity);
end;

function TDTriangleClass.GetItem(Index :integer) :dTriangle;
begin
  if High(fData) < Index then
    SetLength(fData, Index + Vertex_Increment * 2);
  Result := fData[index];
end;

procedure TDTriangleClass.SetItem(Index :integer; Value :dTriangle);
begin
  if High(fData) < Index then
    SetLength(fData, Index + Vertex_Increment * 2);
  fData[index] := Value;
end;

constructor TBoolArrayClass.Create(Capacity :integer);
begin
  inherited Create;
  SetLength(fData, Capacity shr 3);
end;

function TBoolArrayClass.ByteIndex(Index :integer) :integer;
begin
  Result := index shr 3;
end;

function TBoolArrayClass.BitMask(Index :integer) :byte;
begin
  Result := 1 shl (Index and $7);
end;

function TBoolArrayClass.GetItem(Index :integer) :boolean;
begin
  Result := fData[ByteIndex(Index)] and BitMask(Index) <> 0;
end;

procedure TBoolArrayClass.SetItem(Index :integer; Value :boolean);
var
  bi :integer;
begin
  bi := ByteIndex(Index);
  if bi > High(fData) then
    SetLength(fData, bi + (Vertex_Increment shr 3));
  if Value then
    fData[bi] := fData[bi] or BitMask(Index)
  else
    fData[bi] := fData[bi] and (not BitMask(Index));
end;

constructor TIntArrayClass.Create(Capacity :integer);
begin
  inherited Create;
  SetLength(fData, Capacity);
end;

function TIntArrayClass.GetItem(Index :integer) :integer;
begin
  if High(fData) < Index then
    SetLength(fDAta, Index + Vertex_Increment);
  Result := fData[index];
end;

procedure TIntArrayClass.SetItem(Index :integer; Value :integer);
begin
  if High(fData) < Index then
    SetLength(fData, Index + Vertex_Increment);
  fData[Index] := Value;
end;

constructor TDelaunay.Create;
begin
  inherited;
  //Initiate total points to 1, using base 0 causes problems in the functions
  tPoints := 1;
  HowMany := 0;
  Vertex := TDVertexClass.Create(InitialVertexCount);
  Triangle := TDTriangleClass.Create(InitialVertexCount * 2);
end;

destructor TDelaunay.Destroy;
begin
  FreeAndNil(Vertex);
  FreeAndNil(Triangle);
  inherited;
end;

function TDelaunay.FindPoint(_x, _y :DelaunayFloat; out index :integer) :boolean;
var
  i :integer;
  dx, dy :DelaunayFloat;
begin
  Result := False;
  for i := 1 to pred(tPoints) do
    with Vertex[i] do
    begin
      dx := _x - x;
      dy := _y - y;
      if IsZero(dx, ExPtTolerance) and IsZero(dy, ExPtTolerance) then
      begin
        Result := True;
        index := i;
        exit;
      end
      else if x > _x then
        exit;
    end;
end;

function TDelaunay.InCircle(xp, yp, x1, y1, x2, y2, x3, y3 :DelaunayFloat;
  var xc :DelaunayFloat; var yc :DelaunayFloat; var r :DelaunayFloat;
  j :integer) :boolean;
  //Return TRUE if the point (xp,yp) lies inside the circumcircle
  //made up by points (x1,y1) (x2,y2) (x3,y3)
  //The circumcircle centre is returned in (xc,yc) and the radius r
  //NOTE: A point on the edge is inside the circumcircle
var
  eps :DelaunayFloat;
  m1 :DelaunayFloat;
  m2 :DelaunayFloat;
  mx1 :DelaunayFloat;
  mx2 :DelaunayFloat;
  my1 :DelaunayFloat;
  my2 :DelaunayFloat;
  dx :DelaunayFloat;
  dy :DelaunayFloat;
  rsqr :DelaunayFloat;
  drsqr :DelaunayFloat;
  T :dTriangle;
begin
  eps := 0.000001;
  InCircle := False;

  //Check if xc,yc and r have already been calculated
  if Triangle[j].PreCalc = 1 then
  begin
    xc := Triangle[j].xc;
    yc := Triangle[j].yc;
    r := Triangle[j].r;
    rsqr := sqr(r);
    dx := xp - xc;
    dy := yp - yc;
    drsqr := sqr(dx) + sqr(dy);
  end
  else
  begin

    if (Abs(y1 - y2) < eps) and (Abs(y2 - y3) < eps) then
    begin
{$IFDEF DEBUG}
      raise Exception.Create('INCIRCUM - F - Points are coincident !!');
{$ENDIF}
      Exit;
    end;

    if Abs(y2 - y1) < eps then
    begin
      m2 := -(x3 - x2) / (y3 - y2);
      mx2 := (x2 + x3) / 2;
      my2 := (y2 + y3) / 2;
      xc := (x2 + x1) / 2;
      yc := m2 * (xc - mx2) + my2;
    end
    else if Abs(y3 - y2) < eps then
    begin
      m1 := -(x2 - x1) / (y2 - y1);
      mx1 := (x1 + x2) / 2;
      my1 := (y1 + y2) / 2;
      xc := (x3 + x2) / 2;
      yc := m1 * (xc - mx1) + my1;
    end
    else
    begin
      m1 := -(x2 - x1) / (y2 - y1);
      m2 := -(x3 - x2) / (y3 - y2);
      mx1 := (x1 + x2) / 2;
      mx2 := (x2 + x3) / 2;
      my1 := (y1 + y2) / 2;
      my2 := (y2 + y3) / 2;
      if abs(m1 - m2) > eps then  //se
      begin
        xc := (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
        yc := m1 * (xc - mx1) + my1;
      end
      else
      begin
        xc := (x1 + x2 + x3) / 3;
        yc := (y1 + y2 + y3) / 3;
      end;

    end;

    dx := x2 - xc;
    dy := y2 - yc;
    rsqr := dx * dx + dy * dy;
    r := Sqrt(rsqr);
    dx := xp - xc;
    dy := yp - yc;
    drsqr := sqr(dx) + sqr(dy);
    //store the xc,yc and r for later use
    T := Triangle[j];
    T.PreCalc := 1;
    T.xc := xc;
    T.yc := yc;
    T.r := r;
    Triangle[j] := T;

  end;

  if drsqr <= rsqr then
    InCircle := True;

end;



{Function TDelaunay.WhichSide(xp, yp, x1, y1, x2, y2: DelaunayFloat): Integer;
//Determines which side of a line the point (xp,yp) lies.
//The line goes from (x1,y1) to (x2,y2)
//Returns -1 for a point to the left
//         0 for a point on the line
//        +1 for a point to the right
var
 equation: DelaunayFloat;
begin
  equation := ((yp - y1) * (x2 - x1)) - ((y2 - y1) * (xp - x1));

  if IsZero(Equation) then Result := 0 else
  if Equation > 0 then Result := -1
  else Result := 1;

(*
  If equation > 0 Then
     WhichSide := -1
  Else If equation = 0 Then
     WhichSide := 0
  Else
     WhichSide := 1;
*)
End;
 }


function TDelaunay.Triangulate(nvert :integer) :integer;
  //Takes as input NVERT vertices in arrays Vertex()
  //Returned is a list of NTRI triangular faces in the array
  //Triangle(). These triangles are arranged in clockwise order.
var

  //  Complete: TDComplete;
  Complete :TBoolArrayClass;
  Edges :TDEdges;
  Nedge :longint;

  //For Super Triangle
  xmin :DelaunayFloat;
  xmax :DelaunayFloat;
  ymin :DelaunayFloat;
  ymax :DelaunayFloat;
  xmid :DelaunayFloat;
  ymid :DelaunayFloat;
  dx :DelaunayFloat;
  dy :DelaunayFloat;
  dmax :DelaunayFloat;

  //General Variables
  i :integer;
  j :integer;
  k :integer;
  ntri :integer;
  xc :DelaunayFloat;
  yc :DelaunayFloat;
  r :DelaunayFloat;
  Inc :boolean;

  dv :DVertex;
  dt :dTriangle;
begin

  //Allocate memory
  Complete := TBoolArrayClass.Create(tPoints shr 3);
  try
    for i := 0 to 2 do
      Edges[i] := TIntArrayClass.Create(tPoints);
    try
      //Find the maximum and minimum vertex bounds.
      //This is to allow calculation of the bounding triangle
      xmin := Vertex[1].x;
      ymin := Vertex[1].y;
      xmax := xmin;
      ymax := ymin;
      for i := 2 to nvert do
      begin
        if Vertex[i].x < xmin then
          xmin := Vertex[i].x;
        if Vertex[i].x > xmax then
          xmax := Vertex[i].x;
        if Vertex[i].y < ymin then
          ymin := Vertex[i].y;
        if Vertex[i].y > ymax then
          ymax := Vertex[i].y;
      end;

      dx := xmax - xmin;
      dy := ymax - ymin;
      if dx > dy then
        dmax := dx
      else
        dmax := dy;

      xmid := Trunc((xmax + xmin) / 2);
      ymid := Trunc((ymax + ymin) / 2);

      //Set up the supertriangle
      //This is a triangle which encompasses all the sample points.
      //The supertriangle coordinates are added to the end of the
      //vertex list. The supertriangle is the first triangle in
      //the triangle list.
      dv.x := round(xmid - 2 * dmax);
      dv.y := round(ymid - dmax);
      dv.Original := nvert + 1;
      Vertex[nvert + 1] := dv;
      dv.x := round(xmid);
      dv.y := round(ymid + 2 * dmax);
      dv.Original := nvert + 2;
      Vertex[nvert + 2] := dv;
      dv.x := round(xmid + 2 * dmax);
      dv.y := round(ymid - dmax);
      dv.Original := nvert + 3;
      Vertex[nvert + 3] := dv;

      dt := Triangle[1];
      with dt do
      begin
        vv0 := nvert + 1;
        vv1 := nvert + 2;
        vv2 := nvert + 3;
        Precalc := 0;
      end;
      Triangle[1] := dt;

      Complete[1] := False;
      ntri := 1;

      //Include each point one at a time into the existing mesh
      for i := 1 to nvert do
      begin
        Nedge := 0;
        //Set up the edge buffer.
        //If the point (Vertex(i).x,Vertex(i).y) lies inside the circumcircle then the
        //three edges of that triangle are added to the edge buffer.
        j := 0;
        repeat
          j := j + 1;
          if Complete[j] <> True then
          begin
            Inc := InCircle(Vertex[i].x, Vertex[i].y,
              Vertex[Triangle[j].vv0].x, Vertex[Triangle[j].vv0].y,
              Vertex[Triangle[j].vv1].x, Vertex[Triangle[j].vv1].y,
              Vertex[Triangle[j].vv2].x, Vertex[Triangle[j].vv2].y,
              xc, yc, r, j);
            //Include this if points are sorted by X
            if (xc + r) < Vertex[i].x then
              complete[j] := True
            else
            if Inc then
            begin
              Edges[1][Nedge + 1] := Triangle[j].vv0;
              Edges[1][Nedge + 1] := Triangle[j].vv0;
              Edges[2][Nedge + 1] := Triangle[j].vv1;
              Edges[1][Nedge + 2] := Triangle[j].vv1;
              Edges[2][Nedge + 2] := Triangle[j].vv2;
              Edges[1][Nedge + 3] := Triangle[j].vv2;
              Edges[2][Nedge + 3] := Triangle[j].vv0;
              Nedge := Nedge + 3;
              Triangle[j] := Triangle[ntri];
              dt := Triangle[ntri];
              dt.PreCalc := 0;
              Triangle[ntri] := dt;
              Complete[j] := Complete[ntri];
              j := j - 1;
              ntri := ntri - 1;
            end;
          end;
        until j >= ntri;

        // Tag multiple edges
        // Note: if all triangles are specified anticlockwise then all
        // interior edges are opposite pointing in direction.
        for j := 1 to Nedge - 1 do
        begin
          //              If Not (Edges[1][j] = 0) And Not (Edges[2][j] = 0) Then
          if (Edges[1][j] <> 0) or (Edges[2][j] <> 0) then
          begin
            for k := j + 1 to Nedge do
            begin
              //                      If Not (Edges[1][k] = 0) And Not (Edges[2][k] = 0) Then
              if (Edges[1][k] <> 0) or (Edges[2][k] <> 0) then
              begin
                if Edges[1][j] = Edges[2][k] then
                begin
                  if Edges[2][j] = Edges[1][k] then
                  begin
                    Edges[1][j] := 0;
                    Edges[2][j] := 0;
                    Edges[1][k] := 0;
                    Edges[2][k] := 0;
                  end;
                end;
              end;
            end;
          end;
        end;

        //  Form new triangles for the current point
        //  Skipping over any tagged edges.
        //  All edges are arranged in clockwise order.
        for j := 1 to Nedge do
        begin
          //                  If Not (Edges[1][j] = 0) And Not (Edges[2][j] = 0) Then
          if (Edges[1][j] <> 0) or (Edges[2][j] <> 0) then
          begin
            ntri := ntri + 1;
            dt := Triangle[ntri];
            with dt do
            begin
              vv0 := Edges[1][j];
              vv1 := Edges[2][j];
              vv2 := i;
              Precalc := 0;
            end;
            Triangle[ntri] := dt;
            Complete[ntri] := False;
          end;
        end;
      end;

      //Remove triangles with supertriangle vertices
      //These are triangles which have a vertex number greater than NVERT
 {     i:= 0;
      repeat
        i := i + 1;
        If (Triangle[i].vv0 > nvert) Or (Triangle[i].vv1 > nvert) Or (Triangle[i].vv2 > nvert) Then
        begin
          dt := Triangle[i];
          dt.vv0 := Triangle[ntri].vv0;
          dt.vv1 := Triangle[ntri].vv1;
          dt.vv2 := Triangle[ntri].vv2;
          Triangle[i] := dt;
           i := i - 1;
           ntri := ntri - 1;
        End;
      until i>=ntri; }

      Triangulate := ntri;
    finally
      for i := 0 to 2 do
        FreeAndNil(Edges[i]);
    end
  finally
    FreeAndNil(Complete);
  end;
end;


procedure TDelaunay.Mesh;
begin
  QuickSort(1, pred(tPoints));
  if tPoints > 3 then
    HowMany := Triangulate(tPoints - 1); //'Returns number of triangles created.
end;

procedure TDelaunay.AddPoint(x, y :DelaunayFloat);
var
  dv :DVertex;
  i :integer;
begin
  if FindPoint(x, y, i) then
    exit;
  dv.x := x;
  dv.y := -y;
  dv.Original := tPoints;
  Vertex[tPoints] := dv;
  Inc(tPoints);
end;

procedure TDelaunay.QuickSort(Low, High :integer);
//Sort all points by x
  procedure DoQuickSort(iLo, iHi :integer);
  var
    Lo, Hi :integer;
    Mid :DelaunayFloat;
    T :dVertex;
    A :TDVertex;
  begin
    A := Vertex.fData;
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2].x;
    repeat
      while A[Lo].x < Mid do
        Inc(Lo);
      while A[Hi].x > Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      DoQuickSort(iLo, Hi);
    if Lo < iHi then
      DoQuickSort(Lo, iHi);
  end;

begin
  DoQuickSort(Low, High);
end;

end.
