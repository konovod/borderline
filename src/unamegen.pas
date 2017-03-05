unit uNameGen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  MARK_ORDER = 2;
  MAX_NAME_LEN = 12;


procedure InitNameGen;
procedure ParseNameData;
procedure LoadNameData;
function GenerateName: string;
implementation

uses uglobal, zgl_log;


//from https://en.wikipedia.org/wiki/Planets_in_science_fiction
const RAW_NAMES: array[1..210] of string = (
'Acheron',
'Abydos',
'Aegis',
'Aldebaran',
'Altair',
'Amel',
'Antar',
'Anus',
'Arieka',
'Athena',
'Athos',
'Aurelia',
'Avalon',
'Balaho',
'Ballybran',
'Belzagor',
'Big',
'Botany',
'Bronson',
'Castiana',
'Chiron',
'Chorus',
'Chthon',
'Corneria',
'Creck',
'Cybertron',
'Cyteen',
'Darkover',
'Darwin',
'Demeter',
'Deucalion',
'Dosadi',
'Downbelow',
'Dragon',
'Eayn',
'Emm',
'Erna',
'Erythro',
'Eternia',
'Etheria',
'Far',
'Fhloston',
'Finisterre',
'Fiorina',
'Fortuna',
'Furya',
'Gaia',
'Gallifrey',
'Gehenna',
'Ghibalb',
'Gor',
'Gorta',
'Gurun',
'Halvmork',
'He',
'Helghan',
'Helliconia',
'Hesduros',
'Hesikos',
'Hiigara',
'Hocotate',
'Hydros',
'Ireta',
'Irk',
'Ishtar',
'Iszm',
'Janjur',
'Junk',
'Kaelarot',
'Karava',
'Kerbin',
'Kharak',
'Kobaia',
'Kobol',
'K-PAX',
'Krankor',
'Kregen',
'Krull',
'Kulthea',
'La',
'Lagash',
'Lamarckia',
'Land',
'Leera',
'Lithia',
'LittleBigPlanet',
'Lumen',
'LV',
'Macbeth',
'Maethrillian',
'Magrathea',
'Majipoor',
'Malurok',
'Medea',
'Mejare',
'Melancholia',
'Metaluna',
'Midkemia',
'Millers',
'Minerva',
'Miron',
'Mobius',
'Mongo',
'Mor-Tax',
'Muloqt',
'Nacre',
'New',
'New',
'New',
'Nidor',
'Nihil',
'Nirn',
'Oa',
'Omega',
'Omicron',
'Omicron',
'Optera',
'Orthe',
'Palamok',
'Pandarve',
'Pandora',
'Peaceland',
'Perdide',
'Pern',
'Petaybee',
'Pharagos',
'Placet',
'Planet',
'Planet',
'Planet',
'Planet',
'Planet',
'Planet',
'Polyphemus',
'Prysmos',
'Pyrrus',
'Ragnarok',
'Reach',
'Rebirth',
'Regis',
'Remulak',
'Requiem',
'Reverie',
'Riverworld',
'Rocheworld',
'Rosetta',
'Rubanis',
'Rylos',
'Ryn',
'Saeponkal',
'Sanghelios',
'Sangre',
'Sartorias-deles',
'Sauria',
'Secilia',
'Seiren',
'Sera',
'Shikasta',
'Shora',
'Skaro',
'Smoke',
'Solaris',
'Soror',
'Space',
'Stroggos',
'Takis',
'Tallon',
'Tanis',
'Targ',
'Te',
'Tencton',
'Terminus',
'Thalassa',
'The',
'This',
'Thra',
'Thundera',
'Tiamat',
'Tirol',
'Titan',
'Tormance',
'Tralfamadore',
'Tran',
'Tranai',
'Trantor',
'Troas',
'Tschai',
'T''vao',
'Twinsun',
'Ulgethon',
'Valyanop',
'Vegeta',
'Vekta',
'Venom',
'Vhilinyar',
'Vinea',
'Wait-Your-Turn',
'Water-O',
'Worlorn',
'Wormwood',
'Zahir',
'Zarathustra',
'Zarkon',
'Zavron',
'Zebes',
'Zeelich',
'Zeist',
'Zillikian',
'Zyrgon',
'Earth'
);

//parsed to mark chain
const MARK_DATA: array[1..272] of string = (
'ab=y',
'ac=hbreehe',
'ad=io',
'ae=gltp',
'ag=ooaron',
'ah=oi',
'ai=raa!!t',
'aj=i',
'ak=!!i',
'al=dtoalilbvuua!lafy',
'am=eaoaa',
'an=!tu!ya!jkde!cdddeeeeeeiggi!c!ato!',
'ao=!',
'ar=a!ikw!a!oaacevaotoig!akt',
'as=th-ts!',
'at=hheh!eh',
'au=rr',
'av=aar',
'ax=!!',
'ay=nb',
'ba=rlllin',
'be=lrltes',
'bi=gngur',
'bo=tl',
'br=ao',
'by=d',
'ca=sl',
'cb=e',
'ce=lt!!',
'ch=eioto!ea!',
'ci=l',
'ck=!i',
'co=rnt',
'cr=eeoo',
'ct=o',
'cy=bt',
'-d=e',
'da=rrr',
'de=bmua!lr',
'di=!d',
'dk=e',
'do=sswrrr',
'dr=ao',
'du=r',
'ea=y!!!cc!r',
'eb=aiie',
'ec=ki',
'ed=e',
'ee=nr!l',
'eg=ieaie',
'eh=e',
'ei=rs',
'ej=a',
'ek=at',
'el=!izoglaaaiei',
'em=emiuu!',
'en=a!n!!!co',
'ep=o',
'eq=u',
'er=oit!!nynirbasvadniwama-',
'es=di!!',
'et=eeha!hhaa!!!!!!!tha',
'eu=c',
'ev=e',
'ew=!!!o',
'ey=!',
'fa=rm',
'fh=l',
'fi=no',
'fo=r',
'fr=e',
'fu=r',
'ga=ilrs!',
'ge=hntt',
'gg=o',
'gh=iae',
'gi=ss',
'gn=a',
'go=rnrr!ssn',
'gp=l',
'gr=ae',
'gu=r',
'ha=lnrrli',
'he=rnrn!llssaa!mwl!',
'hi=rbialkslr',
'hl=o',
'ho=s!rnclrn',
'hr=oia',
'ht=ha',
'hu=ns',
'hy=d',
'ia=!n!!!!!!!!n!!s!!mn',
'ib=a',
'ic=orrh',
'id=koe',
'ie=km!',
'if=r',
'ig=!ap',
'ih=i',
'ii=g',
'ik=oai',
'il=ll!iil',
'in=!ia!eusye',
'io=nrs',
'ip=o',
'ir=!oekonteo!',
'is=!thz!!!!!!t',
'it=hta-',
'iu=s',
'iv=e',
'ja=nr',
'ji=p',
'ju=rn',
'k-=p',
'ka=!erlsr',
'ke=rm!',
'kh=a',
'ki=asa',
'ko=vsbbrn',
'kr=aeu',
'kt=a',
'ku=l',
'la=hr!gmnnnmncnnnnnnkrs',
'lb=!',
'ld=e!!',
'le=ebrs',
'lf=a',
'lg=he',
'li=aofcttaaoanck',
'll=yii!ieoi',
'lo=nwsqsnr',
'lt=ah',
'lu=mrn',
'lv=m!',
'ly=bpa',
'lz=a',
'ma=rcegjltnd',
'me=ltndjltg',
'mi=dalnrccn',
'mm=!',
'mo=rbnrksk',
'mu=lsl',
'mw=o',
'na=!!!!!!!cri',
'nb=e',
'nc=hte',
'nd=!ao!e',
'ne=rtrwwwtttttta',
'ng=ohr',
'ni=asadhrss',
'nj=u',
'nk=!oa',
'nn=a',
'no=pm',
'ns=ou',
'nt=ao',
'nu=ss',
'ny=!a',
'-o=!',
'oa=!s',
'ob=aoi',
'oc=oh',
'od=!',
'og=g',
'ok=!!!e',
'ol=!iya!',
'om=eii!',
'on=!!s!!!!!!!i!g!!k!!!!!!',
'oo=rd',
'op=t!',
'oq=t',
'or=!unit!tk!!-!talliao!me!lnm',
'os=!!at!!!!!e!!!',
'ot=aa!',
'ou=r',
'ov=e',
'ow=n!',
'-p=a',
'pa=xlnnc',
'pe=arrt',
'ph=ae',
'pl=aaaaaaaa',
'po=oln',
'pr=y',
'pt=e',
'py=r',
'qt=!',
'qu=i',
'r-=tto',
'ra=nng!vkn!t!!gg!!!!lnnnt!',
'rb=i',
'rc=k',
'rd=i',
're=lc!ytg!!abgmqv!n!',
'rg=!o',
'ri=eaanlevaas',
'rk=o!!o',
'rl=ddo',
'rm=iaw',
'rn=eai!!!!',
'ro=nnnn!sstknnnkcs!rglan',
'rr=eu',
'rs=!',
'rt=ruahhoh',
'ru=snlsb',
'rv=ae',
'rw=io',
'ry=tasln',
's-=d',
'sa=dennru!',
'sc=h',
'sd=u',
'se=tcir',
'sh=t!io',
'si=k',
'sk=a',
'sm=oo',
'so=nlr',
'sp=a',
'ss=a',
'st=ioearr!',
'su=n',
'sz=m',
'-t=au',
't''=v',
't-=y',
'ta=irn!t!rlxy!!klnrn!!',
'te=errr!r!nrr',
'th=eooreei!ree!aeiruou!',
'ti=aart',
'tl=e',
'to=nrnrr',
'tr=ooaaaaoa',
'ts=c',
'tt=la',
'tu=nr',
'tw=i',
'ub=a',
'uc=a',
'ui=e',
'ul=ltoag',
'um=e',
'un=a!kad!',
'ur=eyuo!oi-n',
'us=!!!!!!t',
'''v=a',
'va=l!!ol',
've=r!rrgkn',
'vh=i',
'vi=n',
'vm=o',
'vr=o',
'wa=it',
'wi=nn',
'wn=b',
'wo=rrrro',
'-y=o',
'ya=!nr',
'yb=ree',
'yd=or',
'yl=o',
'yn=!!',
'yo=u',
'yp=h',
'yr=rg',
'ys=m',
'yt=eh',
'za=ghrrv',
'ze=bei',
'zi=l',
'zm=!',
'zy=r'
);


const STARTERS: array[1..112] of string = (
'ab',
'ac',
'ae',
'al',
'am',
'an',
'ar',
'at',
'au',
'av',
'ba',
'be',
'bi',
'bo',
'br',
'ca',
'ch',
'co',
'cr',
'cy',
'da',
'de',
'do',
'dr',
'ea',
'em',
'er',
'et',
'fa',
'fh',
'fi',
'fo',
'fu',
'ga',
'ge',
'gh',
'go',
'gu',
'ha',
'he',
'hi',
'ho',
'hy',
'ir',
'is',
'ja',
'ju',
'k-',
'ka',
'ke',
'kh',
'ko',
'kr',
'ku',
'la',
'le',
'li',
'lu',
'lv',
'ma',
'me',
'mi',
'mo',
'mu',
'na',
'ne',
'ni',
'oa',
'om',
'op',
'or',
'pa',
'pe',
'ph',
'pl',
'po',
'pr',
'py',
'ra',
're',
'ri',
'ro',
'ru',
'ry',
'sa',
'se',
'sh',
'sk',
'sm',
'so',
'sp',
'st',
't''',
'ta',
'te',
'th',
'ti',
'to',
'tr',
'ts',
'tw',
'ul',
'va',
've',
'vh',
'vi',
'wa',
'wo',
'za',
'ze',
'zi',
'zy'
);

var
  already: TStringList;
  MarkData: TStringList;
  Starts: TStringList;

procedure InitNameGen;
begin
  already := TStringList.Create;
  already.Sorted := True;
  MarkData := TStringList.Create;
  MarkData.Sorted := True;
  MarkData.Duplicates := dupError;
  Starts := TStringList.Create;
  Starts.Sorted := True;
  Starts.Duplicates := dupError;
  //ParseNameData;
  LoadNameData;
end;

procedure ParseNameData;
var
  i, j: integer;
  s, sc, s1: string;
  c: char;
begin
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
  log_Add('************');
  for s in Starts do
    log_Add(s);
  log_Add('************');
  for s in MarkData do
    log_Add(s);
  log_Add('************');
end;

procedure LoadNameData;
var
  i: integer;
begin
  for i := 1 to Length(STARTERS) do
    Starts.Add(STARTERS[i]);
  for i := 1 to Length(MARK_DATA) do
    MarkData.Add(MARK_DATA[i]);
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
    until (c = '!') or (length(s) > MAX_NAME_LEN);
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

