unit uNameGen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  MARK_ORDER = 2;
  MAX_NAME_LEN = 12;


procedure InitNameGen;
function GenerateName: string;
implementation

uses uglobal, zgl_log;


//from https://en.wikipedia.org/wiki/Planets_in_science_fiction
//const RAW_NAMES: array[1..209] of string = (
//'Acheron',
//'Abydos',
//'Aegis',
//'Aldebaran',
//'Altair',
//'Amel',
//'Antar',
//'Anus',
//'Arieka',
//'Athena',
//'Athos',
//'Aurelia',
//'Avalon',
//'Balaho',
//'Ballybran',
//'Belzagor',
//'Big',
//'Botany',
//'Bronson',
//'Castiana',
//'Chiron',
//'Chorus',
//'Chthon',
//'Corneria',
//'Creck',
//'Cybertron',
//'Cyteen',
//'Darkover',
//'Darwin',
//'Demeter',
//'Deucalion',
//'Dosadi',
//'Downbelow',
//'Dragon',
//'Eayn',
//'Emm',
//'Erna',
//'Erythro',
//'Eternia',
//'Etheria',
//'Far',
//'Fhloston',
//'Finisterre',
//'Fiorina',
//'Fortuna',
//'Furya',
//'Gaia',
//'Gallifrey',
//'Gehenna',
//'Ghibalb',
//'Gor',
//'Gorta',
//'Gurun',
//'Halvmork',
//'He',
//'Helghan',
//'Helliconia',
//'Hesduros',
//'Hesikos',
//'Hiigara',
//'Hocotate',
//'Hydros',
//'Ireta',
//'Irk',
//'Ishtar',
//'Iszm',
//'Janjur',
//'Junk',
//'Kaelarot',
//'Karava',
//'Kerbin',
//'Kharak',
//'Kobaia',
//'Kobol',
//'K-PAX',
//'Krankor',
//'Kregen',
//'Krull',
//'Kulthea',
//'La',
//'Lagash',
//'Lamarckia',
//'Land',
//'Leera',
//'Lithia',
//'LittleBigPlanet',
//'Lumen',
//'LV',
//'Macbeth',
//'Maethrillian',
//'Magrathea',
//'Majipoor',
//'Malurok',
//'Medea',
//'Mejare',
//'Melancholia',
//'Metaluna',
//'Midkemia',
//'Millers',
//'Minerva',
//'Miron',
//'Mobius',
//'Mongo',
//'Mor-Tax',
//'Muloqt',
//'Nacre',
//'New',
//'New',
//'New',
//'Nidor',
//'Nihil',
//'Nirn',
//'Oa',
//'Omega',
//'Omicron',
//'Omicron',
//'Optera',
//'Orthe',
//'Palamok',
//'Pandarve',
//'Pandora',
//'Peaceland',
//'Perdide',
//'Pern',
//'Petaybee',
//'Pharagos',
//'Placet',
//'Planet',
//'Planet',
//'Planet',
//'Planet',
//'Planet',
//'Planet',
//'Polyphemus',
//'Prysmos',
//'Pyrrus',
//'Ragnarok',
//'Reach',
//'Rebirth',
//'Regis',
//'Remulak',
//'Requiem',
//'Reverie',
//'Riverworld',
//'Rocheworld',
//'Rosetta',
//'Rubanis',
//'Rylos',
//'Ryn',
//'Saeponkal',
//'Sanghelios',
//'Sangre',
//'Sartorias-deles',
//'Sauria',
//'Secilia',
//'Seiren',
//'Sera',
//'Shikasta',
//'Shora',
//'Skaro',
//'Smoke',
//'Solaris',
//'Soror',
//'Space',
//'Stroggos',
//'Takis',
//'Tallon',
//'Tanis',
//'Targ',
//'Te',
//'Tencton',
//'Terminus',
//'Thalassa',
//'The',
//'This',
//'Thra',
//'Thundera',
//'Tiamat',
//'Tirol',
//'Titan',
//'Tormance',
//'Tralfamadore',
//'Tran',
//'Tranai',
//'Trantor',
//'Troas',
//'Tschai',
//'T''vao',
//'Twinsun',
//'Ulgethon',
//'Valyanop',
//'Vegeta',
//'Vekta',
//'Venom',
//'Vhilinyar',
//'Vinea',
//'Wait-Your-Turn',
//'Water-O',
//'Worlorn',
//'Wormwood',
//'Zahir',
//'Zarathustra',
//'Zarkon',
//'Zavron',
//'Zebes',
//'Zeelich',
//'Zeist',
//'Zillikian',
//'Zyrgon'
//);

var
  already: TStringList;
  MarkData: TStringList;
  Starts: TStringList;

procedure InitNameGen;
var
  i, j: integer;
  s, sc, s1: string;
  c: char;
begin
  already := TStringList.Create;
  already.Sorted := True;
  MarkData := TStringList.Create;
  //MarkData.Sorted := True;
  MarkData.Duplicates := dupError;
  Starts := TStringList.Create;
  Starts.Sorted := True;
  Starts.Duplicates := dupError;
  for s in RAW_NAMES do
  begin
    //add starter
    s1 := LowerCase(LeftStr(s, MARK_ORDER));
    if Starts.Find(s1, i) then
      Starts.Objects[i] := TObject(integer(Starts.Objects[i])+1)
    else
      Starts.AddObject(s1, tobject(1));
    //add rest
    sc := LowerCase(s)+'!';
    for i := 1 to length(sc)-MARK_ORDER do
    begin
      s1 := copy(sc, i, MARK_ORDER);
      c := sc[i+MARK_ORDER];
      assert(c in ['a'..'z', '-', '''', '!'], sc);
      j := MarkData.IndexOfName(s1);
      if j >= 0 then
        MarkData.ValueFromIndex[j] := MarkData.ValueFromIndex[j]+c
      else
        MarkData.Add(s1+'='+c);
    end;
  end;
  for s in MarkData do
    log_Add(s);
end;

//stub version: just to test
function GenerateName: string;
var
  s, sfind, vars: string;
  c: char;
  i: integer;
begin
  repeat
    s := Starts[Random(Starts.Count)];
    repeat
      sfind := RightStr(s, MARK_ORDER);
      vars := MarkData.Values[sfind];
      c := vars[Rand(1, length(vars))];
      s := s+c;
    until (c = '!') or length(s) > MAX_NAME_LEN ;
    s := LeftStr(s, Length(s)-1);
  until (length(s) <= MAX_NAME_LEN) and not already.Find(s, i);
  if Length(s) < 3 then
    s := UpperCase(s)+'-'+IntToStr(Rand(10, 99))
  else
    s[1] := upCase(s[1]);
  Result := s;
  already.Add(s);
end;

end.

