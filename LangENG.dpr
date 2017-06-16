library LangENG;

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
  Columns : array[0..4, 0..1] of string = (
  (('Surname'), ('Surnames')), {0}
  (('Forename'), ('Forenames')), {1}
  (('Payment'), ('Payments')), {2}
  (('Date of employment'), ('Dates of employment')), {3}
  (('All'), ('All')) {4}
  );

type
   langline = string[25];
   mbline = string[100];

{$R *.res}

function Form1Lang(index : byte) : langline; stdcall;
const
  Form1 : array[0..15] of langline = (
  ('Fields of a new record'), {0}
  ('Add'), {1}
  ('Edit'), {2}
  ('Filter'), {3}
  ('Search'), {4}
  ('Delete'), {5}
  ('Save'), {6}
  ('Options'), {7}
  ('Exit'), {8}
  ('Fields of a edit record'), {9}
  ('Overwrite'), {10}
  ('Cancel edit'), {11}
  ('End filtration'), {12}
  ('End search'), {13}
  ('Records:'), {14}
  ('Statistics') {15}
  );
begin
  if index in [0..15] then Result:=Form1[index]
    else if index in [16..19] then Result:=columns[index-16][0];
end;

function Form2Lang(index : byte) : langline; stdcall;
const
  Form2 : array[0..9] of langline = (
  ('Sorting'), {0}
  ('Maximum priority'), {1}
  ('Minimum priority'), {2}
  ('Order'), {3}
  ('Language'), {4}
  ('Increasing'), {5}
  ('Decreasing'), {6}
  ('English'), {7}
  ('Polish'), {8}
  ('BP v. 1.0 - options') {9}
  );
begin
  if index in [0..9] then Result:=Form2[index]
    else if index in [10..13] then Result:=Columns[index-10][0];
end;

function Form3Lang(index : byte) : mbline; stdcall;
const
  Form3 : array[0..7] of mbline = (
  ('Number of beginning for'), {0}
  ('Mostly first sign'), {1}
  ('Minimum'), {2}
  ('Maximum'), {3}
  ('Average'), {4}
  ('First'), {5}
  ('Last'), {6}
  ('BP v. 1.0 - satistics') {7}
  );
begin
  if index in [0..7] then Result:=Form3[index]
    else if index in [8..11] then Result:=Columns[index-8][1];
end;

function FindLang(index : byte) : langline; stdcall;
const
  Find : array[0..1] of langline = (
  ('Search'), {0}
  ('In column')  {1}
  );

begin
  if index in [0..1] then Result:=Find[index]
    else if index in [2..6] then Result:=Columns[index-2][0];
end;

function FilterLang(index : byte) : langline; stdcall;
const
  Filter : array[0..7] of langline = (
  ('Filtration'), {0}
  ('Is contain'), {1}
  ('Is equal to'), {2}
  ('Is greater than'), {3}
  ('Is greater than or equal'), {4}
  ('Is less than'), {5}
  ('Is less than or equal'), {6}
  ('Is between') {7}
  );
begin
  Result:=Filter[index];
end;

function MBForm1Lang(indexr, indexc : byte) : mbline; stdcall;
const
  MBForm1 : array[0..5, 0..1] of mbline = (
  (('Incorrect data has been writed. Could I clean fields of a new record?'), {0}
  ('Adding record - incorrect data')), {Błąd - niepoprawne dane w polach noweo rekordu}
  (('Could I delete this record?'), {1}
  ('Deleting record')), {Pytanie - usuwanie zaznaczonego rekordu}
  (('Empty field of search text'), {2}
  ('Searching - read error')), {Błąd - brak tekstu wyszukiwania}
  (('Lack of matching record to specified conditions.'), {3}
  ('Searching - lack of given sencence')), {Informacja - brak pasującego rekordu do kryteriów wyszukiwania}
  (('Could I close program?'), {4}
  ('Closing program')), {Pytanie - zamykanie programu głównego}
  (('Baza Pracowników v. 1.0 - main window'), {5}
  ('')) {Etykieta paska tytułu }
  );
begin
  Result:=MBForm1[indexr][indexc];
end;

function MBForm2Lang(index : byte) : mbline; stdcall;
const
  MBForm2 : array[0..1] of mbline = (
  ('Language will be changed in next start of program. Could I restart?'),
  ('Options - change language')
  );
begin
  Result:=MBForm2[index];
end;

exports
  Form1Lang,
  Form2Lang,
  Form3Lang,
  FindLang,
  FilterLang,
  MBForm1Lang,
  MBForm2Lang;

begin
end.
