USE test_pracownicy

-- #1
CREATE TABLE test_pracownicy.dbo.dziennik(
tabela 	VARCHAR(15) NOT NULL,
ddata SMALLDATETIME NOT NULL,
l_wierszy INT NOT NULL,
komunikat VARCHAR(300) NOT NULL
);
GO

-- #2
SELECT nr_akt, placa FROM pracownicy WHERE nr_akt IN (SELECT DISTINCT kierownik FROM pracownicy)

DECLARE Kursor CURSOR FOR
SELECT nr_akt FROM pracownicy

DECLARE @premia int, @nr INT, @iterator INT
SET @premia = 500
SET @iterator = 0

OPEN Kursor
FETCH NEXT FROM Kursor INTO @nr

WHILE @@FETCH_STATUS = 0
BEGIN
	IF (@nr IN (SELECT DISTINCT kierownik FROM pracownicy))
		BEGIN
		UPDATE pracownicy SET placa = placa + @premia WHERE nr_akt = @nr
		SET @iterator = @iterator + 1 
		END
	FETCH NEXT FROM Kursor INTO @nr
END
INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @iterator, 'Wprowadzono dodatek funkcyjny w wysokosci ' + CONVERT(varchar(4), @premia) + ' dla ' +  CONVERT(varchar(4), @iterator) + ' pracowników.' );

CLOSE Kursor
DEALLOCATE Kursor

-- #3
DECLARE @rok INT, @lprac INT
SET @rok = 1989
BEGIN
	SET @lprac = (SELECT COUNT (*) FROM pracownicy WHERE YEAR(data_zatr) = @rok)
	IF (@lprac != 0)
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @lprac, 'Zatrudniono ' + CONVERT(varchar(4), @lprac) + ' pracowników w roku ' + CONVERT(varchar(4), @rok))
	ELSE
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @lprac, 'Nikogo nie zatrudniono w ' + CONVERT(varchar(4), @rok))
END
SELECT * FROM dziennik
GO

-- #4
DECLARE @numer INT
SET @numer = 8902
BEGIN
	IF (15 > YEAR(GETDATE()) - (SELECT YEAR(data_zatr) FROM pracownicy WHERE nr_akt = @numer))
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), '1', 'Pracownik ' + CONVERT(varchar(4), @numer) + ' jest zatrudniony krócej niż 15 lat.')
	ELSE
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), '1', 'Pracownik ' + CONVERT(varchar(4), @numer) + ' jest zatrudniony dłużej niż 15 lat.')
END
SELECT * FROM dziennik
GO

-- #5
CREATE PROCEDURE PIERWSZA @Paramter INT
AS
	PRINT 'Wartośc parametru wynosiła: ' + CONVERT(varchar(1), @Paramter)
GO

EXEC PIERWSZA 4
GO


-- #6
CREATE PROCEDURE DRUGA
(
	@wej VARCHAR(50) NULL,
	@wyj VARCHAR(100) output, 
	@num INT = 1
)
AS
	DECLARE @lok VARCHAR(10) --NOT NULL
	SET @lok = 'DRUGA'
	SET @wyj = @lok + @wej + CONVERT(varchar(10), @num)
GO

DECLARE @wyj VARCHAR(100) 
EXEC DRUGA 'Napis ', @wyj OUTPUT, 6
SELECT @wyj
GO


--#7
CREATE PROCEDURE PODWYZKA
(
	@dzial INT = 0,
	@procent INT = 5
)
AS
  BEGIN
	DECLARE @suma INT, @podwyzka DECIMAL(3,2)
	SET @podwyzka = @procent * 0.01

	IF (@dzial = 0)
	BEGIN
		UPDATE pracownicy SET placa = placa + placa * @procent	
		SET @suma = (SELECT COUNT(*) FROM pracownicy)
	END
	ELSE
	BEGIN
		SET @suma = (SELECT COUNT(*) FROM pracownicy WHERE id_dzialu = @dzial)
		UPDATE pracownicy SET placa = placa + placa * @procent WHERE id_dzialu = @dzial
	END

	IF (@suma <> 0)
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @suma, 'Wprowadzono podwyzke o ' + CONVERT(varchar(4), @procent) + ' procent');
  END
GO

EXEC PODWYZKA 20, 7


-- #8
CREATE FUNCTION UDZIAL (@dzial INT)
RETURNS DECIMAL(5,2)
AS
 BEGIN
	DECLARE @sumaD INT, @sumaW INT, @suma DECIMAL(5,2)
	SET @sumaD = (SELECT SUM(placa) FROM test_pracownicy.dbo.pracownicy WHERE id_dzialu = @dzial)
	SET @sumaW = (SELECT SUM(placa) FROM test_pracownicy.dbo.pracownicy)
	SET @suma = @sumaD * 10000 / @sumaW * 0.01
	RETURN @suma
 END
GO

SELECT DISTINCT id_dzialu, dbo.UDZIAL(id_dzialu) FROM test_pracownicy.dbo.pracownicy
GO

-- #9
CREATE TRIGGER do_archiwum
ON pracownicy
FOR DELETE
AS
BEGIN
	ROLLBACK
	INSERT INTO prac_archiw
	SELECT nr_akt, nazwisko, stanowisko, kierownik, data_zatr, data_zwol, placa, dod_funkcyjny, prowizja, id_dzialu
	FROM deleted

	INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), 1, 'Zwolniono pracownika numer: ' + CONVERT(varchar(4), (SELECT nr_akt FROM deleted)));
END
GO
