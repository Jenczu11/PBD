USE biuro
GO

-- #1
CREATE PROCEDURE NowyWlasciciel
(
	@imie VARCHAR(20),
	@nazwisko VARCHAR(20),
	@adres VARCHAR(50),
	@telefon VARCHAR(20)
)
AS
  BEGIN
	DECLARE @numer INT
	SET @numer = 01

	WHILE(CONCAT('CO', CONVERT(VARCHAR(2), @numer)) IN (SELECT wlascicielnr FROM wlasciciele))
	  BEGIN
		set	@numer = @numer +1;
	  END
	
	INSERT INTO wlasciciele VALUES (CONCAT('CO', CONVERT(VARCHAR(2), @numer)),
				@imie, @nazwisko, @adres, @telefon)
  END
GO

NowyWlasciciel 'Jan', 'Kowalski', '95-050 Konstantynow, Lodzka 6', '0-99-999 9999'
SELECT * FROM wlasciciele
GO


-- #2
CREATE FUNCTION PrzychodyWynajem()
RETURNS @UDZIAL TABLE (biuroNr VARCHAR(4), udzial FLOAT)
AS
 BEGIN
	INSERT INTO @udzial
	SELECT biuroNr, SUM(czynsz) AS udzial FROM nieruchomosci GROUP BY biuroNr
	RETURN
 END
GO

SELECT * FROM PrzychodyWynajem()
GO


-- #3
CREATE TRIGGER CzynszOverflow ON wynajecia
FOR INSERT
AS
 BEGIN
	DECLARE @max_czynsz SMALLINT
	SET @max_czynsz = (SELECT k.max_czynsz FROM klienci AS k, inserted AS i WHERE k.klientnr = i.klientnr)
	
	IF ((SELECT czynsz FROM inserted) > @max_czynsz)
	 BEGIN
		PRINT 'Poprawiam czynsz'
		UPDATE wynajecia SET czynsz = @max_czynsz WHERE umowanr = (SELECT umowanr FROM inserted)
	 END
 END
GO

INSERT INTO wynajecia
VALUES(1111, 'A14', 'CO16', 500, 'gotówka', 500, 0, GETDATE(), GETDATE())
SELECT * FROM wynajecia WHERE umowanr = 1111
GO


-- #4
CREATE TRIGGER RejestracjaNowegoKlienta ON klienci
FOR INSERT
AS
 BEGIN
	DECLARE @numer VARCHAR(4)
	SET @numer = (SELECT TOP 1 personelnr FROM personel ORDER BY NEWID())
	
	INSERT INTO rejestracje
	SELECT klientnr, biuronr, @numer, GETDATE() FROM inserted, personel WHERE personelNr = @numer
 END
GO


INSERT INTO klienci
VALUES('CO15', 'Kamil', 'Chrabaszcz', 'NieWiadomoGdzie', '1-23-456 7890', 'dom', 500)

SELECT * FROM rejestracje
GO


-- #5
CREATE FUNCTION Prowizja (@data_od DATETIME, @data_do DATETIME)
RETURNS @Tabela TABLE(pracownik VARCHAR(4), prowizja FLOAT)
AS
 BEGIN
	INSERT INTO @Tabela
	SELECT	personel.personelnr, COUNT(umowanr) * 0.10 * pensja + COUNT(data_wizyty) * 0.02 * pensja
	FROM	personel, wynajecia, nieruchomosci, wizyty
	WHERE	nieruchomosci.personelNr = personel.personelNr AND
			wizyty.nieruchomoscnr = nieruchomosci.nieruchomoscnr AND
			data_wizyty <= @data_do AND data_wizyty >= @data_od AND
			wynajecia.nieruchomoscNr = nieruchomosci.nieruchomoscnr AND
			wynajecia.od_kiedy <= @data_do AND wynajecia.od_kiedy >= @data_od
	GROUP BY personel.personelNr, personel.pensja

	RETURN
 END
GO

SELECT * FROM Prowizja('2000-01-01', '2003-12-31')
GO


-- #6
CREATE PROCEDURE NiezaplaconeRachunki
AS
  BEGIN
	SELECT 'Brak wplaty od ' + kli.nazwisko + ' za nieruchomosc nr ' + wynaj.nieruchomoscNr + ' za okres ' + CONVERT(VARCHAR(2), DATEDIFF(MONTH, wynaj.od_kiedy, wynaj.do_kiedy) + 1) + ' mies.'
	FROM klienci AS kli, (SELECT * FROM wynajecia where wynajecia.zaplacona = 0) AS wynaj
	WHERE wynaj.klientnr = kli.klientnr
	ORDER BY wynaj.od_kiedy ASC
  END
GO

EXEC NiezaplaconeRachunki
GO
