USE narciarze
GO

-- #1
SELECT * FROM kraje
SELECT * FROM skocznie
SELECT * FROM trenerzy
SELECT * FROM zawodnicy
SELECT * FROM zawody
SELECT * FROM uczestnictwa_w_zawodach

-- #2
SELECT DISTINCT kraj
FROM kraje
WHERE id_kraju NOT IN (SELECT id_kraju FROM zawodnicy)

-- #3
SELECT kraj, COUNT (*) as "liczba"
FROM kraje, zawodnicy
WHERE kraje.id_kraju = zawodnicy.id_kraju
GROUP BY kraj

-- #4
SELECT nazwisko
FROM zawodnicy
WHERE id_skoczka NOT IN (SELECT DISTINCT id_skoczka FROM uczestnictwa_w_zawodach)

-- #5
SELECT nazwisko, COUNT (*) as "ile"
FROM zawodnicy, uczestnictwa_w_zawodach
WHERE zawodnicy.id_skoczka = uczestnictwa_w_zawodach.id_skoczka
GROUP BY nazwisko

-- #6
SELECT DISTINCT nazwisko, nazwa
FROM zawodnicy, skocznie, zawody, uczestnictwa_w_zawodach
WHERE zawodnicy.id_skoczka = uczestnictwa_w_zawodach.id_skoczka
	AND uczestnictwa_w_zawodach.id_zawodow = zawody.id_zawodow
	AND zawody.id_skoczni =  skocznie.id_skoczni

-- #7
SELECT nazwisko, (YEAR(GETDATE()) - YEAR(data_ur)) as "wiek"
FROM zawodnicy
ORDER BY wiek DESC

-- #8
SELECT nazwisko, MIN(YEAR(DATA) - YEAR(data_ur)) as "wiek"
FROM zawodnicy, zawody, uczestnictwa_w_zawodach
WHERE zawodnicy.id_skoczka = uczestnictwa_w_zawodach.id_skoczka
	AND uczestnictwa_w_zawodach.id_zawodow = zawody.id_zawodow
GROUP BY nazwisko

-- #9
SELECT nazwa, (sedz - k) as "odl"
FROM skocznie order by odl desc

-- #10
SELECT TOP 1 nazwa, k
FROM skocznie
ORDER BY k DESC

-- #11
SELECT DISTINCT kraj
FROM kraje, zawody, skocznie
WHERE kraje.id_kraju = skocznie.id_kraju
	AND skocznie.id_skoczni = zawody.id_skoczni
	
-- #12
SELECT nazwisko, kraj, COUNT (*) as "ile"
FROM zawodnicy, uczestnictwa_w_zawodach, zawody, skocznie, kraje
WHERE zawodnicy.id_skoczka = uczestnictwa_w_zawodach.id_skoczka
	AND uczestnictwa_w_zawodach.id_zawodow = zawody.id_zawodow
	AND zawody.id_skoczni = skocznie.id_skoczni
	AND skocznie.id_kraju = kraje.id_kraju
	AND zawodnicy.id_kraju = kraje.id_kraju
GROUP BY nazwisko, kraj

-- #13
INSERT INTO trenerzy VALUES (7, 'Corby', 'Fisher', '1975-07-20');

-- -- #14
ALTER TABLE zawodnicy
ADD trener INT
--
-- -- #15
UPDATE zawodnicy SET trener = id_kraju
--
-- -- #16
ALTER TABLE zawodnicy
ADD CONSTRAINT FKZawodnicyTrenerzy FOREIGN KEY (trener) REFERENCES Trenerzy(id_trenera)
--
-- -- #17

UPDATE trenerzy
SET data_ur_t=(SELECT TOP 1 DATEADD(year, -5, data_ur) FROM zawodnicy WHERE zawodnicy.trener='1' ORDER BY data_ur ASC)
WHERE data_ur_t IS NULL AND trenerzy.id_trenera='1'
UPDATE trenerzy
SET data_ur_t=(SELECT TOP 1 DATEADD(year, -5, data_ur) FROM zawodnicy WHERE zawodnicy.trener='2' ORDER BY data_ur ASC)
WHERE data_ur_t IS NULL AND trenerzy.id_trenera='2'
UPDATE trenerzy
SET data_ur_t=(SELECT TOP 1 DATEADD(year, -5, data_ur) FROM zawodnicy WHERE zawodnicy.trener='6' ORDER BY data_ur ASC)
WHERE data_ur_t IS NULL AND trenerzy.id_trenera='6'

