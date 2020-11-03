---- z którego wiersza zostaną przypisane dane? ----
declare @imieP varchar(20), @nazwiskoP varchar(20)
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka..pracownicy
print @imieP+' '+@nazwiskoP
-- ODP: Z wiersza ostatniej osoby w bazie [S0001] Anna Michalak

---- co zostanie zwrócone? ----
---- 1.
declare @imieP1 varchar(20), @nazwiskoP1 varchar(20)
set @imieP1='Teofil'
set @nazwiskoP1='Szczerbaty'
select @imieP1=imie, @nazwiskoP1=nazwisko from biblioteka..pracownicy where id=1
print @imieP1+' '+@nazwiskoP1
-- ODP: Dane 1 osoby [S0001] Jan Borsuk
---- 2.
declare @imieP2 varchar(20), @nazwiskoP2 varchar(20)
set @imieP2='Teofil'
set @nazwiskoP2='Szczerbaty'
select @imieP2=imie, @nazwiskoP2=nazwisko from biblioteka..pracownicy where id=20
print @imieP2+' '+@nazwiskoP2
-- ODP: Brak 20 osoby, wiec zostanie wypisane "Teofil Szczerbaty"

-- IF..ELSE
if EXISTS (select * from biblioteka..wypozyczenia) print('Byly wypozyczenia')
else print ('Nie bylo wypozyczen')
-- Odp: Byly wypozyczenia

--while
declare @y int
set @y=0;
while (@y<10)
begin
	print @y
	if(@y=5) break
	set @y=@y+1
end
-- Petla wyswietla liczby od 0-5

--CASE
select tytul as tytulK, cena as cenaK, [cena jest]=CASE
	when cena<20.00 then 'Niska'
	when cena between 20.00 and 40.00 then 'Przystepna'
	when cena>40 then 'Wysoka'
	else 'Nieznana'
	end
from biblioteka..ksiazki
-- Odp: Przypisuje odpowiednie wartości w zależnosci od ceny ksiazki

-- NULLIF
-- pomijamy nulle w średniej ilosci stron
SELECT AVG( NULLIF (strony, 0)) AS [Średnia ilość stron]
FROM biblioteka..ksiazki
-- ODP: 206

-- ISNULL
SELECT tytul, ISNULL(cena, (SELECT MIN(CENA) FROM biblioteka..ksiazki))
FROM biblioteka..ksiazki
-- ODP: Nadajemy wartość domyślną tam gdzie jest null

-- 1 --
-- DROP FUNCTION fn_srednia
GO
CREATE FUNCTION fn_srednia (@rodzaj varchar(20))
RETURNS int
BEGIN
	RETURN (SELECT AVG(strony) FROM biblioteka..ksiazki WHERE gatunek=@rodzaj)
END
GO

SELECT dbo.fn_srednia('powieść')
DROP FUNCTION fn_srednia

-- 2 --
-- DROP FUNCTION funkcja
GO
CREATE FUNCTION funkcja (@max int) RETURNS table
	RETURN (SELECT * FROM biblioteka..ksiazki WHERE strony<=@max)
GO

SELECT * FROM funkcja(200)


