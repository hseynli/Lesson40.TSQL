/*İstifadəçi funksiyaları geriyə skalyar dəyər qaytarır*/
USE ShopDB
GO

CREATE FUNCTION Hello() -- funksiya yaratmaq
RETURNS varchar(30)     -- geriyə qayıdacaq tipi təyin edirik
AS
BEGIN --funskiyanın bədənin başlanğıcı
DECLARE @MyVar varchar(20) ='Hello World!';
RETURN @MyVar; --funksiyanın geriyə qaytardığı dəyər
END; -- funksiyanın bədəninin sonu
GO

PRINT dbo.Hello();

DROP TABLE TestTable;
GO

CREATE TABLE TestTable
(
	id int identity not null,
	name varchar(25) not null,
	CDate smalldatetime not null
)
GO

-------------------------------------------------------

DECLARE @MyVar int =1;
DECLARE @MyVcVar varchar(10);

WHILE @MyVar < 20
BEGIN
	SET @MyVcVar = 'Test ' + CAST(@MyVar as varchar);
	-- cədvələ məlumat yazırıq
	INSERT TestTable
	( name, CDate )
	VALUES (@MyVcVar, DATEADD(MI, @MyVar, GETDATE()));
	
	SET @MyVar = @MyVar + 1;
END
GO

/* bu select boş olacaq, çünki GETDATE() funskiyası təkcə tarix yox, 
 həm də zamanı qaytarır*/
SELECT * FROM TestTable
WHERE CDate = GETDATE(); 
GO
---------------------------------------------------------

CREATE FUNCTION DateOnly (@Date datetime) -- funksiyanın adını və arqumentini göstərərək onu yaradırıq
RETURNS date --geriyə qayıdacaq tipi təyin edirik
AS
BEGIN --funksiyanın bədəni
 RETURN CAST(@Date as date); -- geriyə qayıdacaq tipi date tipinə çeviririk
END
GO

SELECT * FROM TestTable -- cari select 19 sətir məlumat qaytaracaq
WHERE dbo.DateOnly(CDate)= dbo.DateOnly(GETDATE()); --istifadəçi funskiyasını yaradanda mütləq sxemin adını göstərmək lazımdır
----------------------------------------
USE AdventureWorks2012
GO

SELECT	Name,
		ListPrice,
		(SELECT AVG(ListPrice) FROM Production.Product WHERE ProductSubcategoryID = 1) as Average, -- daxili sorğu istifadə edirik, AVG funksiyası - orta dəyəri geriyə qaytarır
		ListPrice - (SELECT AVG(ListPrice) FROM Production.Product WHERE ProductSubcategoryID = 1) as DifferencePrice
FROM Production.Product 
WHERE ProductSubcategoryID = 1; -- Mountain Bikers üçün sorğu edirik
GO

DROP FUNCTION AvgPrice
DROP FUNCTION DfrncPrice
GO

-- daxili sorğu olan (SELECT AVG(ListPrice)FROM Production.Product) funskiya şəklində yaradırıq, 
-- çünki o ancaq bir dəyər geriyə qaytarır
CREATE FUNCTION AvgPrice()
RETURNS money
WITH SCHEMABINDING    -- ancaq sxemada olan obyektlərlə işləyir.
AS
BEGIN
	RETURN (SELECT AVG(ListPrice)FROM Production.Product WHERE ProductSubcategoryID = 1);
END
GO

--- Daxili funksiyalardan istifadə
CREATE FUNCTION DfrncPrice(@Price money)
RETURNS money
AS
BEGIN
	RETURN @Price - dbo.AvgPrice(); -- daxili funksiyalara müraciət etmək olar
END;
GO

-- həmin sorğunu hər bir dağ velosipedi üçün icra edək
SELECT  Name,
		ListPrice,
		dbo.AvgPrice() as AvgPrice,
		dbo.DfrncPrice(ListPrice) as DifferencePrice
FROM Production.Product
WHERE ProductSubcategoryID = 1;
GO

/*Cədvəl qaytaran istifadəçi funksiyaları*/

USE AdventureWorks2012;
GO

DROP FUNCTION fnContactList

CREATE FUNCTION fnContactList() -- funksiya yaradırıq
RETURNS TABLE -- geriyə qaytarılan tip TABLE onu göstərir ki geriyə cədvəl qaytarılacaq
AS
RETURN (SELECT LastName, FirstName, ModifiedDate 
		FROM Person.Person); 
GO

SELECT * FROM dbo.fnContactList(); -- funskiya tərəfindən geriyə qaytarılan məlumatı ekranda əks elətdiririk fnContactList();
GO

DROP FUNCTION fnContactSearch

CREATE FUNCTION fnContactSearch(@LastName varchar(30)) -- varchar tipində arqument qəbul edir (soyad və ya soyadın bir hissəsi)
RETURNS TABLE
AS
RETURN (SELECT FirstName , LastName, ModifiedDate 
		FROM Person.Person
		WHERE LastName LIKE @LastName + '%'); -- soyad üzrə axtarış
GO

SELECT * FROM dbo.fnContactSearch('Berry'); -- 'Berry' adı ilə təyin edilmiş bütün əməkdaşlar haqqında məlumatı funksiya ilə ekrana çıxarırıq fnContactSearch();

SELECT * FROM dbo.fnContactSearch('Ber'); -- başlanğıcı 'Ber' adı ilə təyin edilmiş bütün əməkdaşlar haqqında məlumatı funksiya ilə ekrana çıxarırıq fnContactSearch(); 