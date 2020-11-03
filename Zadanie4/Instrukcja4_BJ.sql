-- #1
declare @s1 varchar(20)
set @s1 = 'Czesc, to ja'
print @s1

-- #2
declare @i2 int
set @i2 = 5
print 'ZMIENNA = ' + CONVERT(varchar(20), @i2)

-- #3
declare @i3 int
set @i3 = 26
if (@i3 = 26) print 'i3 = 26'
else print 'i3 != 26'

-- #4
declare @i4 int
set @i4 = 1
while ( @i4 <= 4)
begin
	print 'zmienna ma wartosc ' + CONVERT(varchar(1), @i4)
	set @i4 = @i4 + 1
end

-- #5
declare @i5 int
set @i5 = 3
while ( @i5 <= 7)
begin
	if (@i5 = 3) print 'poczatek'
	if (@i5 = 5) print 'srodek'
	if (@i5 = 7) print 'koniec'
	print @i5
	set @i5 = @i5 + 1
end

-- #6
if exists(select 1 from master.dbo.sysdatabases where name = 'test') drop database test
GO
CREATE DATABASE test
GO

CREATE TABLE test.dbo.oddzialy(
NR_ODD INT,
NAZWA_ODD VARCHAR(30)
);

-- #7
INSERT INTO test.dbo.oddzialy VALUES(1,'KSIEGOWOSC');

declare @i7 int, @s7 VARCHAR(30)
set @i7 = 1
BEGIN
	SELECT @s7 = NAZWA_ODD FROM test.dbo.oddzialy WHERE NR_ODD = @i7
	PRINT 'Nazwa oddziału to: '+CONVERT(varchar(20),@s7)
END

-- #8
declare @i8 INT, @s8 VARCHAR(30)
set @i8 = 0
WHILE EXISTS (SELECT * FROM test.dbo.oddzialy WHERE NR_ODD > @i8)
BEGIN
	set @i8 = @i8 + 1
	IF EXISTS (SELECT * FROM test.dbo.oddzialy WHERE NR_ODD = @i8)
	BEGIN
		SELECT @s8 = NAZWA_ODD FROM test.dbo.oddzialy WHERE NR_ODD = @i8
		print 'NUMER ODDZIALU TO: ' + CONVERT(varchar(4), @i8) + ', NAZWA ODDZIALU TO: ' + @s8
	END
END

-- #9
declare @i9 INT, @n9 INT
set @i9 = 2
set @n9 = 2
BEGIN
	WHILE EXISTS (SELECT * FROM test.dbo.oddzialy WHERE NR_ODD > @i9)
	BEGIN
		set @n9 = @n9 + 1
		DELETE FROM test.dbo.oddzialy WHERE NR_ODD = @n9
	END
	print 'Liczba usuniętych rekordow to: ' + CONVERT(varchar(4),(@n9 - @i9))
END

-- #10
declare @i10 INT
set @i10 = 3
BEGIN
	IF EXISTS (SELECT * FROM test.dbo.oddzialy WHERE NR_ODD = @i10)
		UPDATE test.dbo.oddzialy SET NAZWA_ODD = 'IT' WHERE  NR_ODD = @i10
	ELSE
		INSERT INTO test.dbo.oddzialy VALUES(3,'PRODUKCJA');
END