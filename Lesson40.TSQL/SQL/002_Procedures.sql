USE AdventureWorks2012;
GO
-------------------------------------------------------------------

CREATE PROC spEmployee -- Prosedurun yaradılması.
AS
  SELECT * FROM HumanResources.Employee;
GO 

EXEC spEmployee; -- Prosedurun çağırılması.
GO
--------------------------------------------------------------------

ALTER PROC spEmployee -- Prosedurun dəyişdirilməsi
AS
  SELECT he.BirthDate,he.BusinessEntityID FROM HumanResources.Employee he; 
GO
  
EXEC spEmployee; -- Prosedurun çağırılması.
   
DROP PROC spEmployee; -- Prosedurun silinməsi.

EXEC spEmployee; -- XƏTA, çünki bu prosedur artıq silinib.
GO

----------------------------------------------------------------------

/*Paramterli prosedurlar*/

DROP PROC spEmployeeByName

CREATE PROC spEmployeeByName 
	@LastName nvarchar(25)   -- İnisalizasiya zamanı default dəyər verilməmişdir.
AS

	SELECT pc.BusinessEntityID, pc.FirstName, pc.LastName, pc.ModifiedDate 
	FROM Person.Person pc
	WHERE pc.LastName = @LastName;
GO


EXEC spEmployeeByName 'Abel' -- Prosedur mütləq dəyər veririk

EXEC spEmployeeByName -- Əgər dəyər veilməsə, onda - XƏTA

------------------------------------------------------------------------

DROP PROC spEmployeeByName;
GO

CREATE PROC spEmployeeByName
	@LastName nvarchar(25) = NULL 
AS
IF @LastName IS NOT NULL 
	SELECT pc.BusinessEntityID, pc.FirstName, pc.LastName, pc.ModifiedDate
	FROM Person.Person pc
	WHERE pc.LastName LIKE @LastName + '%'
ELSE				
	SELECT pc.BusinessEntityID, pc.FirstName, pc.LastName, pc.ModifiedDate
	FROM Person.Person pc;
GO

EXEC spEmployeeByName     -- paramtersiz çağırmaq.

EXEC spEmployeeByName 'Ca' -- paramterli çağırmaq

EXEC spEmployeeByName 'Cao' 
GO
------------------------------------------------------------------------------

/*Prosedurlarda çıxış dəyərlər*/
DROP PROC spEmployeeCount;
GO

CREATE PROC spEmployeeCount
	@Info int = null OUTPUT -- Çıxış parametrini qeyd etmək üçün OUTPUT açar sözündən istifadə olunur
AS
BEGIN
	SET @Info =(SELECT Count(*) From Person.Person);
END
GO

DECLARE @MyInfo int;

EXEC  spEmployeeCount @MyInfo OUTPUT; -- Proseduru çağıran zaman da OUTPUT açar sözü prosedur yaradılanda olduğu kimi qeyd olunmalıdır

PRINT CAST (@MyInfo as varchar);
GO
---------------------------------------------

---   Dəyərin geriyə qaytarılması operatoru RETURN   --- 

DROP PROC TestProc

CREATE PROC TestProc
AS
BEGIN
	DECLARE @MyVar int = 10;
	RETURN @MyVar; -- prosedurlarda RETURN açar sözü ancaq tam ədəd geriyə qaytarır!
END;
GO

DECLARE @MyRTN int;
EXEC @MyRTN = TestProc;
PRINT CAST(@MyRTN as varchar);
GO

-------------------------------------------
DROP PROC TestProc;
GO

CREATE PROC TestProc
AS
BEGIN
	DECLARE @MyVar int = 10;
	RETURN 'Done' -- prosedurlarda RETURN açar sözü ancaq tam ədəd geriyə qaytarır!
END;
GO

DECLARE @MyRTN2 varchar(5);
EXEC @MyRTN2 = TestProc;
PRINT @MyRTN2;
GO
-------------------------------------------
DROP PROC spTestProc
GO

CREATE PROC spTestProc
AS
BEGIN
	PRINT N'İndi birinci RETURN komandası işə düşəcək';
	RETURN; -- default olaraq RETURN operatoru 0 qaytarır
	PRINT N'İndi birinci RETURN komandası işə düşməyəcək';
	RETURN 5; -- birinci return açar sözündən sonra prosedur işini dayandırır
END;
GO

DECLARE @MyVar3 int;
EXEC @MyVar3 = spTestProc;
PRINT @MyVar3;
GO
------------------------------------------
--- Rekursiya ----
-- Rekursiyanın maksimal dərinliyi 32 səviyyədir

DROP PROC spFactorial

CREATE PROC spFactorial
@ValueIn int,
@ValueOut int OUTPUT
AS
BEGIN
	DECLARE @InWorking int;
	DECLARE @OutWorking int;
	IF (@ValueIn != 1)
	BEGIN
		SET @InWorking = @ValueIn -1;
		EXEC spFactorial @InWorking, @OutWorking OUTPUT; -- proseduru öz blokundan çağırmaq (rekursiya)
		SET @ValueOut = @ValueIn * @OutWorking;
	END
	ELSE
		SET @ValueOut = 1;
END;
GO
-------------------------------------------

DECLARE @MyVarOut int,
		@MyVARIn int;

SET @MyVARIn = 7;
EXEC spFactorial @MyVarIn, @MyVarOut OUTPUT; -- 7!= 1*2*3*4*5*6*7 
PRINT CAST(@MyVARIn as varchar) + ' faktorial: ' + CAST(@MyVarOut as varchar);
GO

----------------------
-- Xəta. Dəyişən üçün istifadə olunan diapazon çatmır!

DECLARE @MyVarOut int,
		@MyVARIn int;

SET @MyVARIn = 13;
EXEC spFactorial @MyVarIn, @MyVarOut OUTPUT; -- 13!= 1*2*3*4*5*6*7*8*9*10*11*12*13
PRINT CAST(@MyVARIn as varchar) + ' faktorial: ' + CAST(@MyVarOut as varchar);


----Cədvəldə olan xətaları qeyd etmək üçün olan prosedur -----
DROP PROC uspLogError;
GO

DROP TABLE ErrorLog2

CREATE TABLE ErrorLog2
(
	ErrorId int IDENTITY,
	ErrorLine int,
	ErrorMessage varchar(200)
)
GO

-- Xətaları qeyd edən prosedurun yaradılması

CREATE PROC uspLogError
	@ErrorLogId int = 0 OUTPUT
AS
BEGIN
	INSERT dbo.ErrorLog2 -- Xəta haqqında məlumatların yazılması.
		(
			ErrorLine,
			ErrorMessage
		)	
		VALUES
		(
			ERROR_LINE(),
			ERROR_MESSAGE()
		)
	SET @ErrorLogId = @@IDENTITY; -- @@IDENTITY cədvələ yazılan sonuncu identifikatoru qaytarır.
END;
------------------------------------------------

BEGIN TRY
	
	CREATE TABLE OurTest
	(
		col int
	)
	
END TRY
BEGIN CATCH
	
	DECLARE @OutIdError int;
	
	IF ERROR_NUMBER() = 2714
	BEGIN
		PRINT N'Mövcüd olan cədvəlin yaradılma cəhdi';
		EXEC uspLogError @OutIdError OUTPUT;
		PRINT N'Xəta cədvələ yazıldı: ' + CAST(@OutIdError as varchar);
	END
	
	ELSE
	  PRINT N'Bilinməyən xəta';
	  
END CATCH

SELECT * FROM ErrorLog2
GO
