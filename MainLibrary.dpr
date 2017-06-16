library MainLibrary;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes;

const
  surnamel = 20;
  forenamel = 20;
  recfilename = 'records.dat';
  optionsfilename = 'options.ini';
  highsigns = ['A'..'Z'];
  lowsigns = ['a'..'z'];
  allsigns = ['a'..'z', 'A'..'Z'];

type
  surnames = string[surnamel];
  forenames = string[forenamel];
  plist = ^list;
  list = record
    surname : surnames;
    forename : forenames;
    pay : integer;
    date : TDateTime;
    id : integer;
    next : plist;
  end;

  recfile = file of list;
  sortarray = array[0..1] of byte;
{
    sortarray[0] - sortowanie wysokiego priorytetu
    sortarray[1] - sortowanie niskiego priorytetu
}

  charnumbers = array[0..34] of byte;
{$R *.res}

(*

    Rzutowania/funkcje różne

*)

function MyBoolToByte(value : boolean) : byte; stdcall;
{Zamienia typ boolean na byte
value:
  False: Result:= 0
  True: Result:=1}
begin
  if value = False then Result:=0
  else Result:=1;
end;

function MyIntToBool(value : integer) : boolean; stdcall;
{Zamienia typ byte na boolean
value:
  0: Result:= False
  not 0: Result:=True}
begin
  if value = 0 then Result:=False
  else Result:=True;
end;

function String0(count : byte) : string; stdcall;
{Zwraca ciąg zer w formacie string w ilości zawartej w argumencie}
var
  i : byte;
begin
  Result:='';
  for i := 1 to count do
    Result:=Result+'0';
end;

function StrToSortid(value : string) : byte; stdcall;
{Zmienia typ danych ze stringa (słowne sortid) na liczbę całkowitą}
begin
    if value = 'sur' then Result:=0
    else if value = 'for' then Result:=1
    else if value = 'pay' then Result:=2
    else if value = 'dat' then Result:=3
    else result:=0;
end;

function SortidToStr(value : byte) : string; stdcall;
{Zmienia typ danych z liczby całkowitej na stringa (słowne sortid)}
begin
    case value of
    0: Result:='surname';
    1: Result:='forename';
    2: Result:='pay';
    3: Result:='date';
    else Result:='surname';
    end;
end;

function SortorderToStr(value : boolean) : string; stdcall;
{Zmienia typ danych z wartości logicznej na stringa (słowne sortowanie)}
begin
  if value then Result:='dec'
  else Result:='inc';
end;

function StrToSortorder(value : string) : boolean; stdcall;
{Zmienia typ danych ze stringa (słowne sortowanie) na wartość logiczną}
begin
  if value='dec' then Result:=True
  else Result:=False;
end;

function LangToStr(value : byte) : string; stdcall;
{Zmienia typ danych z wartości logicznej na stringa (słowny język)}
begin
  case value of
  0: Result:='eng';
  1: Result:='pol';
  else Result:='end';
  end;
end;

function StrToLang(value : string) : byte; stdcall;
{Zmienia typ danych ze stringa (słowny język) na wartość logiczną}
begin
  if value='eng' then Result:=0
  else if value='pol' then Result:=1
  else Result:=0;
end;

function DateToStr(date : TDateTime) : string; stdcall;
{Zamienia format daty na string w formacie rrrr-mm-dd}
var
  year, month, day : word;
  tempstr : string;
begin
  DecodeDate(date, year, month, day);
  tempstr:=IntToStr(year);
  Result:=String0(4-Length(tempstr))+tempstr+'-';
  tempstr:=IntToStr(month);
  Result:=Result+String0(2-Length(tempstr))+tempstr+'-';
  tempstr:=IntToStr(day);
  Result:=Result+String0(2-Length(tempstr))+tempstr;
end;

function StrToDate(datestr : string) : TDateTime; stdcall;
{Zamienia string w formacie rrrr-mm-dd na format daty}
begin
  try
    Result:=EncodeDate(StrToInt(Copy(datestr, 1, 4)),StrToInt(Copy(datestr, 6, 2)), StrToInt(Copy(datestr, 9, 2)));
  finally

  end;
end;

function LowPL(sign : WideChar) : boolean; stdcall;
begin
  case sign of
  'ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż': Result:=True;
  else Result:=False;
  end;
end;

function HighPL(sign : WideChar) : boolean; stdcall;
begin
  case sign of
  'Ą': Result:=True;
  'Ć': Result:=True;
  'Ę': Result:=True;
  'Ł': Result:=True;
  'Ń': Result:=True;
  'Ó': Result:=True;
  'Ś': Result:=True;
  'Ź': Result:=True;
  'Ż': Result:=True;
  else Result:=False;
  end;
end;

function AllPL(sign : WideChar) : boolean; stdcall;
begin
  if LowPL(sign) OR HighPL(sign) then Result:=True
  else Result:=False;
end;

function IsKeyPressed(sign : Widechar) : boolean; stdcall;
begin
  if LowPL(sign) OR HighPL(sign) OR CharInSet(sign, allsigns) OR
    CharInSet(sign, ['0'..'9', ' ', '-', '=', '\', '[', ']', ';', ',', '.', '.']) then Result:=True
  else Result:=False;
end;

function TextControl(var text : string; issurname : boolean; upsigns : boolean; var cursorpos : integer) : boolean; stdcall;
{Sprawdza poprawność ostatniego znaku pól surname i forename}
var
  sign : WideChar;
  strlength, firstlength : byte;
  lstr, rstr, finalstr : string;
begin
  firstlength:=Length(text);
  lstr:=Copy(text, 1, cursorpos);
  rstr:=Copy(text, cursorpos+1, Length(text) - cursorpos+1);
  strlength:=Length(lstr);
  //Result:=text;
  //ShowMessage(lstr);
  //ShowMessage(rstr);
  if strlength > 0 then
  begin
    sign:=WideChar(lstr[strlength]);
    finalstr:='';
    if strlength > 1 then finalstr:=Copy(lstr, 1, strlength-1);

    if (strlength = 1) AND (CharInSet(sign, allsigns) OR AllPL(sign)) then
    begin
      if upsigns then sign:=AnsiUpperCase(sign)[1];
      finalstr:=finalstr+sign;
    end
    else if (strlength > 1) AND ((CharInSet(sign, allsigns) OR AllPL(sign)) OR (sign = ' ')) AND (lstr[strlength - 1] <> ' ') AND (lstr[strlength - 1] <> '-')then
    begin
      if upsigns then sign:=AnsiLowerCase(sign)[1];
      finalstr:=finalstr+sign;
    end
    else if issurname then
    begin
      if (strlength > 1) AND (sign = '-') AND (lstr[strlength - 1] = ' ') then finalstr:=finalstr+sign
      else if (strlength > 1) AND (sign = ' ') AND (lstr[strlength - 1] = '-') then finalstr:=finalstr+sign
      else if (strlength > 2) AND (lstr[strlength - 1] = ' ') AND (lstr[strlength - 2] = '-') AND (CharInSet(sign, allsigns) OR AllPL(sign)) then
        begin
          if upsigns then sign:=AnsiUpperCase(sign)[1];
          finalstr:=finalstr+sign;
        end;
    end
    else begin
      if (strlength > 1) AND (lstr[strlength - 1] = ' ') AND (CharInSet(sign, allsigns) OR AllPL(sign)) then
      begin
        if upsigns then sign:=AnsiUpperCase(sign)[1];
        finalstr:=finalstr+sign;
      end;
    end;
  end;
  finalstr:=finalstr+rstr;
  strlength:=Length(finalstr);
  if Length(text) > strlength then
    begin
      cursorpos:=cursorpos-1;
      Result:=False;
    end
    else Result:=True;
  text:=finalstr;
end;

function FirstCharToInt(sign : WideChar) : byte; stdcall;
begin
  case sign of
  'A'..'Z': Result:=Ord(sign)-65;
  'Ą': Result:=26;
  'Ć': Result:=27;
  'Ę': Result:=28;
  'Ł': Result:=29;
  'Ń': Result:=30;
  'Ó': Result:=31;
  'Ś': Result:=32;
  'Ź': Result:=33;
  'Ż': Result:=34;
  else Result:=0;
  end;
end;

function IntToFirstChar(value : byte) : WideChar; stdcall;
begin
  case value of
  0..25: Result:=Chr(value+65);
  26: Result:='Ą';
  27: Result:='Ć';
  28: Result:='Ę';
  29: Result:='Ł';
  30: Result:='Ń';
  31: Result:='Ó';
  32: Result:='Ś';
  33: Result:='Ź';
  34: Result:='Ż';
  else Result:='A';
  end;
end;

function FirstCharTab(first : plist; issurname : boolean) : charnumbers; stdcall;
var
  i : byte;
  prev : plist;
begin
  for i := 0 to 34 do
  begin
    prev:=first;
    Result[i]:=0;
    if issurname then
    begin
      while prev <> nil do
      begin
        if CompareStr(IntToFirstChar(i),  prev^.surname[1]) = 0 then Result[i]:=Result[i]+1;
        prev:=prev^.next;
      end;
    end
    else begin
      while prev <> nil do
      begin
        if CompareStr(IntToFirstChar(i), prev^.forename[1]) = 0 then Result[i]:=Result[i]+1;
        prev:=prev^.next;
      end;
    end;
  end;

end;

procedure MaxValue(out maxvalue : byte; table : charnumbers); stdcall;
var
  i : byte;
begin
  maxvalue:=table[0];
  for i := 1 to 34 do
  begin
    if maxvalue < table[i] then maxvalue:=table[i];
  end;
end;

function MostlyLetter(table : charnumbers) : string; stdcall;
var
  max, i : byte;
begin
  MaxValue(max, table);
  Result:='';
  for i := 0 to 34 do
  begin
    if table[i] = max then
    begin
      if Length(Result) < 13 then
      begin
        if Result = '' then Result:=IntToFirstChar(i)
          else Result:=Result+', '+IntToFirstChar(i);
      end
      else if Length(Result) = 13 then Result:=Result+'...';

    end;

  end;
  Result:=AnsiUpperCase(Result);
end;

procedure PayDateCalc(first : plist; out minpay : integer; out maxpay : integer; out averagepay : integer; out mindate : TDateTime; out maxdate : TDateTime); stdcall;
var
  prev : plist;
  sum : int64;
  count : integer;
begin
if first <> nil then
  begin
    prev:=first;
    minpay:=prev^.pay;
    maxpay:=prev^.pay;
    mindate:=prev^.date;
    maxdate:=prev^.date;
    sum:=prev^.pay;
    count:=1;
    prev:=prev^.next;
    while prev <> nil do
    begin
      if minpay > prev^.pay then minpay:=prev^.pay;
      if maxpay < prev^.pay then maxpay:=prev^.pay;
      if mindate > prev^.date then mindate:=prev^.date;
      if maxdate < prev^.date then maxdate:=prev^.date;
      sum:=sum+prev^.pay;
      Inc(count);
      prev:=prev^.next;
    end;
    averagepay:=sum div count;
  end;
end;

(*

    obsługa kolejki

*)

procedure AddRecQ(var first : plist; newrec : list); stdcall;
{Dodaje rekord na koniec kolejki}
var
  prev, next : plist;
begin
  prev:=first;
  if prev = nil then
  begin
    New(first);
    first^:=newrec;
    first^.next:=nil;
  end else
  begin
    while prev^.next <> nil do
      prev:=prev^.next;
    New(next);
    next^:=newrec;
    next^.next:=nil;
    prev^.next:=next;
  end;
end;

function ReadRecQ(first : plist; id : integer) : list; stdcall;
{Zwraca rekord o wskazanym id}
var
  prev : plist;
begin
  prev:= first;
  //for i := 0 to id do
  while prev^.id <> id do
      prev:=prev^.next;
  Result:=prev^;
end;

procedure DeleteRecQ(var first : plist; id : integer); stdcall;
{Usuwa rekord o wskazanym id}
var
  prev, next : plist;
begin
  prev := first;
  if (id = first^.id) then
  begin
    next := first^.next;
    Dispose(first);
    first := next;
  end
  else
  begin
    while prev^.next^.id <> id do
      prev := prev^.next;
      next := prev^.next^.next;
      Dispose(prev^.next);
      prev^.next := next;
  end;
end;

procedure EditRecQ(first : plist; editrec : list); stdcall;
{Nadpisuje rekord o wskazanym id}
var
  prev, next : plist;
begin
  prev:=first;
  while prev^.id <> editrec.id do
    prev:=prev^.next;
  next:=prev^.next;
  prev^:=editrec;
  prev^.next:=next;
end;

(*

    obsługa pliku rekordowego

*)

procedure SaveRecQToFile(first : plist); stdcall;
{Zapisuje całą kolejkę do pliku}
var
  file0 : recfile;
  prev : plist;
begin
  AssignFile(file0, recfilename);
  Rewrite(file0);
  prev:=first;
  while (prev <> nil) do
  begin
    write(file0, prev^);
    prev:=prev^.next;
  end;
  CloseFile(file0);
end;

procedure ReadRecQFromFile(out first : plist; out recqcount : integer; out maxid : integer);  stdcall;
{Odczytuje całą kolejkę z pliku}
var
  i : integer;
  file0 : recfile;
  temprow : list;
begin
  first:=nil;
  AssignFile(file0, recfilename);
  maxid:=0;
  recqcount:=0;
  if Fileexists(recfilename) then
  begin
    try
      Reset(file0);
      for i := 0 to FileSize(file0) - 1 do
      begin
        System.read(file0, temprow);
        AddRecQ(first, temprow);
        maxid:=temprow.id;
        Int(recqcount);
      end;
    finally
      CloseFile(file0);
    end;
  end;

end;

(*

    obsługa pliku z opcjami

*)

procedure SaveOptionsToFile(sortid : sortarray; sortorder : boolean; lang : byte); stdcall;
{Zapisuje plik z opcjami do pliku}
var
  file0: textfile;
  newline : string;
begin
  try
  newline:=#13#10;
  AssignFile(file0, optionsfilename);
  Rewrite(file0);
  System.writeln(file0, 'sorthighpriority='+SortidToStr(sortid[0]));
  System.writeln(file0, 'sortlowpriority='+SortidToStr(sortid[1]));
  System.writeln(file0, 'sortorder='+SortorderToStr(sortorder));
  System.writeln(file0, 'lang='+LangToStr(lang));
  System.Writeln(file0, newline+'*sort={surname, forename, pay, date}');
  System.Writeln(file0, '*sortorder={inc, dec}');
  System.Writeln(file0, '*lang={eng, pol}');
  finally
    CloseFile(file0);
  end;

end;

procedure ReadOptionsFromFile(out sortid : sortarray; out sortorder : boolean; out lang : byte); stdcall;
{Odczytuje plik z opcjami z pliku}
var
  tempstr: string;
  file0: textfile;
  templength : byte;
begin
  tempstr:=' ';
  sortid[0]:=0;
  sortid[1]:=1;
  sortorder:=False;
  lang:=0;
  if FileExists(optionsfilename) then
  begin
    try
      AssignFile(file0, optionsfilename);
      Reset(file0);
      while (not Eof(file0)) do
      begin
        System.readln(file0, tempstr);
        templength:=Length(tempstr);
        if (templength > 0) AND (tempstr[1] = '*') then break;
        if (templength >= 20) AND (Copy(tempstr, 1, 17)='sorthighpriority=') then sortid[0]:=StrToSortid(Copy(tempstr, 18, 3));
        if (templength >= 19) AND (Copy(tempstr, 1, 16)='sortlowpriority=') then sortid[1]:=StrToSortid(Copy(tempstr, 17, 3));
        if (templength >= 13) AND (Copy(tempstr, 1, 10)='sortorder=') then sortorder:=StrToSortorder(Copy(tempstr, 11, 3));
        if (templength >= 8) AND (Copy(tempstr, 1, 5)='lang=') then lang:=StrToLang(Copy(tempstr, 6, 3));
      end;
    finally
      CloseFile(file0);
    end;
  end;
end;


exports
  MyBoolToByte,
  MyIntToBool,
  DateToStr,
  StrToDate,
  IsKeyPressed,
  TextControl,
  FirstCharToInt,
  FirstCharTab,
  MostlyLetter,
  PayDateCalc,
  AddRecQ,
  ReadRecQ,
  DeleteRecQ,
  EditRecQ,
  SaveRecQToFile,
  ReadRecQFromFile,
  SaveOptionsToFile,
  ReadOptionsFromFile;
begin
end.
