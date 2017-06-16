library LangPOL;

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
  (('Nazwisko'), ('Nazwiska')), {0}
  (('Imię'), ('Imiona')), {1}
  (('Płaca'), ('Płace')), {2}
  (('Data zatrudnienia'), ('Daty zatrudnienia')), {3}
  (('Wszystko'), ('Wszystkie')) {4}
  );

type
   langline = string[25];
   mbline = string[100];

{$R *.res}

function Form1Lang(index : byte) : langline; stdcall;
const
  Form1 : array[0..15] of langline = (
  ('Pola nowego rekordu'), {0}
  ('Dodaj'), {1}
  ('Edytuj'), {2}
  ('Filtruj'), {3}
  ('Wyszukaj'), {4}
  ('Usuń'), {5}
  ('Zapisz'), {6}
  ('Opcje'), {7}
  ('Zamknij'), {8}
  ('Pola edytowanego rekordu'), {9}
  ('Nadpisz'), {10}
  ('Anuluj edycję'), {11}
  ('Zamknij fi..'), {12}
  ('Zamknij wy..'), {13}
  ('Rekordy:'), {14}
  ('Statystyka') {15}
  );
begin
  if index in [0..15] then Result:=Form1[index]
    else if index in [16..19] then Result:=Columns[index-16][0];
end;

function Form2Lang(index : byte) : langline; stdcall;
const
  Form2 : array[0..9] of langline = (
  ('Sortowanie'), {0}
  ('Najwyższy priorytet'), {1}
  ('Najniższy priorytet'), {2}
  ('Kolejność'), {3}
  ('Język'), {4}
  ('Rosnąco'), {5}
  ('Malejąco'), {6}
  ('Angielski'), {7}
  ('Polski'), {8}
  ('BP v. 1.0 - opcje') {9}
  );
begin
  if index in [0..9] then Result:=Form2[index]
    else if index in [10..14] then Result:=Columns[index-10][0];
end;

function Form3Lang(index : byte) : mbline; stdcall;
const
  Form3 : array[0..7] of mbline = (
  ('Ilość zaczynających się od'), {0}
  ('Najczęstsza pierwsza litera'), {1}
  ('Najmniejsza'), {2}
  ('Największa'), {3}
  ('Średnia'), {4}
  ('Pierwsza'), {5}
  ('Ostatnia'), {6}
  ('BP v. 1.0 - statystyka') {7}
  );
begin
  if index in [0..7] then Result:=Form3[index]
    else if index in [8..11] then Result:=Columns[index-8][1];
end;

function FindLang(index : byte) : langline; stdcall;
const
  Find : array[0..1] of langline = (
  ('Wyszukiwanie'), {0}
  ('W kolumnie')  {1}
  );

begin
  if index in [0..1] then Result:=Find[index]
    else if index in [2..6] then Result:=Columns[index-2][0];
end;

function FilterLang(index : byte) : langline; stdcall;
const
  Filter : array[0..7] of langline = (
  ('Filtrowanie'), {0}
  ('Zawiera'), {1}
  ('Równa się'), {2}
  ('Większy od'), {3}
  ('Większy lub równy'), {4}
  ('Mniejszy'), {5}
  ('Mniejszy lub równy'), {6}
  ('Pomiędzy') {7}
  );
begin
  Result:=Filter[index];
end;

function MBForm1Lang(indexr, indexc : byte) : mbline; stdcall;
const
  MBForm1 : array[0..5, 0..1] of mbline = (
  (('Wprowadzono niepoprawne dane. Wyczyścić pola nowego rekordu?'), {0}
  ('Dodawanie rekordu - błędne dane')), {Błąd - niepoprawne dane w polach noweo rekordu}
  (('Czy usunąć wskazany rekord?'), {1}
  ('Usuwanie rekordu')), {Pytanie - usuwanie zaznaczonego rekordu}
  (('Nie wprowadzono tekstu wyszukiwania.'), {2}
  ('Wyszukiwanie - błąd odczytu')), {Błąd - brak tekstu wyszukiwania}
  (('Brak pasującego rekordu do określonych kryteriów.'), {3}
  ('Wyszukiwanie - brak określonej frazy')), {Informacja - brak pasującego rekordu do kryteriów wyszukiwania}
  (('Czy zamknąć program?'), {4}
  ('Zamykanie programu')), {Pytanie - zamykanie programu głównego}
  (('Baza Pracowników v. 1.0 - okno główne'), {5}
  ('')) {Etykieta paska tytułu }
  );
begin
  Result:=MBForm1[indexr][indexc];
end;

function MBForm2Lang(index : byte) : mbline; stdcall;
const
  MBForm2 : array[0..1] of mbline = (
  ('Język zostanie zmieniony przy następnym uruchomieniu programu. Czy uruchomić ponownie?'),
  ('Opcje - zmiana języka')
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
