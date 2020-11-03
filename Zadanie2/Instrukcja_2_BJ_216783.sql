USE biuro
GO

-- #1
SELECT nieruchomoscnr,
	(SELECT COUNT (*) FROM wizyty WHERE wizyty.nieruchomoscnr = n.nieruchomoscnr ) as "ile_wizyt",
	(SELECT COUNT (*) FROM wynajecia WHERE wynajecia.nieruchomoscNr = n.nieruchomoscnr ) as "ile_wynajmow"
 FROM nieruchomosci as n

-- #2
SELECT nieruchomoscnr, ( CONVERT(VARCHAR(3), (czynsz * 100 / (SELECT TOP 1 czynsz
FROM wynajecia WHERE wynajecia.nieruchomoscNr = nieruchomosci.nieruchomoscnr
ORDER BY od_kiedy) - 100)) + ' %') AS "podwyzka"
FROM nieruchomosci

-- #3
SELECT n.nieruchomoscnr, SUM(w.czynsz * (1 + DATEDIFF(mm, od_kiedy ,do_kiedy))) AS "ile"
FROM nieruchomosci AS n, wynajecia AS w
WHERE w.nieruchomoscNr = n.nieruchomoscnr
GROUP BY n.nieruchomoscnr

-- #4
SELECT DISTINCT biuroNr, (SELECT SUM(0.3 * w.czynsz * (1 + DATEDIFF(mm, od_kiedy ,do_kiedy))) AS suma
FROM wynajecia AS w, nieruchomosci AS n WHERE w.nieruchomoscNr = n.nieruchomoscnr AND n.biuroNr = b.biuroNr) AS "ile"
FROM nieruchomosci AS b

-- #5a
SELECT TOP 1 miasto, COUNT (*)
FROM nieruchomosci, wynajecia
WHERE nieruchomosci.nieruchomoscnr = wynajecia.nieruchomoscNr
GROUP BY miasto
ORDER BY COUNT (*) DESC

-- #5b
SELECT TOP 1 miasto, SUM(w.czynsz * (1 + DATEDIFF(mm, od_kiedy ,do_kiedy)))
FROM nieruchomosci AS n, wynajecia AS w
WHERE w.nieruchomoscNr = n.nieruchomoscnr
GROUP BY miasto
ORDER BY SUM(w.czynsz * (1 + DATEDIFF(mm, od_kiedy ,do_kiedy))) DESC

-- #6
SELECT DISTINCT klienci.klientnr, wynajecia.nieruchomoscnr
FROM klienci, wynajecia, wizyty
WHERE klienci.klientnr = wynajecia.klientnr AND klienci.klientnr=wizyty.klientnr
AND wynajecia.nieruchomoscNr = wizyty.nieruchomoscnr

-- #7
SELECT DISTINCT wynajecia.klientnr, COUNT (DISTINCT wizyty.nieruchomoscNr)
FROM wynajecia, wizyty
WHERE wizyty.klientnr = wynajecia.klientnr AND data_wizyty < od_kiedy AND wizyty.nieruchomoscnr <> wynajecia.nieruchomoscNr
GROUP BY wynajecia.klientnr

-- #8
SELECT DISTINCT klienci.klientnr
FROM klienci, wynajecia
WHERE klienci.max_czynsz < wynajecia.czynsz AND wynajecia.klientnr = klienci.klientnr

-- #9
SELECT biuroNr
FROM biura
WHERE biuroNr NOT IN (SELECT biuroNr FROM nieruchomosci)

-- #11a
SELECT (SELECT COUNT (*) FROM personel WHERE plec='K') AS "panie",
	(SELECT COUNT (*) FROM personel WHERE plec='M') AS "panowie"

-- #11b
SELECT biuroNr, (SELECT COUNT (*) FROM personel WHERE plec='K' AND personel.biuroNr = biura.biuroNr) AS "panie",
	(SELECT COUNT (*) FROM personel WHERE plec='M' AND personel.biuroNr = biura.biuroNr) AS "panowie"
FROM biura
WHERE biuroNr IN (SELECT DISTINCT biuroNr FROM personel)

-- #11c
SELECT DISTINCT miasto, (SELECT COUNT (*) FROM personel, biura WHERE plec='K' AND
biura.miasto = b.miasto AND personel.biuroNr = biura.biuroNr) AS "panie",
(SELECT COUNT (*) FROM personel, biura WHERE plec='M' AND
biura.miasto = b.miasto AND personel.biuroNr = biura.biuroNr) AS" panowie"
FROM biura as b
WHERE biuroNr IN (SELECT DISTINCT biuroNr FROM personel)

-- #11d
SELECT DISTINCT stanowisko, (SELECT COUNT (*) FROM personel WHERE plec='K' AND personel.stanowisko = p.stanowisko) AS "panie",
	(SELECT COUNT (*) FROM personel WHERE plec='M'  AND personel.stanowisko = p.stanowisko) AS "panowie"
FROM personel AS p
