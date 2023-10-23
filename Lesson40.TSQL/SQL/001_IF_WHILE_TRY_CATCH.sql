/*İcraolunmanın idarə edilməsi operatorları*/
USE AdventureWorks2012;

--------------------------------------------------------------------------
--                   IF..ELSE şərt operatorları
--------------------------------------------------------------------------

DECLARE @myVar varchar(10); 

--SET @myVar = 'Hello World!!!'

-- IF şərt operatorunda : @myVar is NULL şərtini yoxlayırıq
IF @myVar is NULL 
	PRINT ('значение myVar не задано');   -- Əgər şərt həqiqəti əks elətdirsə.
ELSE				
	PRINT @myVar;                         -- ƏKS HALDA şərt həqiqəti əks elətdirmir.


--------------------------------------------------------------------------
--                        EXISTS operatoru
--------------------------------------------------------------------------
-- EXISTS operatoru SELECT-ə əsasən məlumatın olub-olmamasından asılı olar TRUE və ya FALSE qaytarır.

IF EXISTS (SELECT * FROM Person.Address WHERE City = 'Kyiv') -- Cədvəlin adında sxemin adını göstəririk (namespace analoqu)
	PRINT 'We have staff from the city Seattle'
ELSE
	PRINT 'We have no employees of the city Seattle'
	
----------------------------------------------------------------------------
USE ShopDB;

-- sys.schemas, sys.tables adlı sistem cədvəlləri

-- sys.schemas cədvəli cari bazada olan sxemlər haqqında məlumat saxlayır

SELECT * FROM sys.schemas 

-- sys.tables cədvəli cari bazada olan cədvəllər haqqında məlumat saxlayır

SELECT * FROM sys.tables 

----------------------------------------------------------------------------

-- TestTable cədvəlinin yaradılmasından əvvəl yoxlanılması (yaradılıb ya yox).
IF NOT EXISTS (    
				SELECT s.name,t.name
				FROM sys.schemas AS s					-- schemas - sxemlər haqqında məlumatı özündə saxlayan sistem cədvəli
					JOIN sys.tables AS t				-- tables - cədvəlləri özündə saxlayan sistem cədvəlidir
					 ON s.schema_id = t.schema_id	-- sxemə aid olan cədvəllərin seçilməsi
				WHERE s.name = 'dbo'				-- hardakı sxem dbo-dır
					AND t.name = 'TestTable'		-- və cədvəl TestTable-dır
				)				
	CREATE TABLE TestTable -- əgər cədvəl yoxdursa onu yaratmaq
		(
			Col1 int,
			Col2 varchar(20)
		)	
ELSE
	PRINT 'Таблица TestTable уже существует!' -- əgər cədvəl mövcüddursa ekrana məlumat çıxarmaq
----------------------------------------------------------------------------
		
----- operatorlar qrupu və bloklar -----

DROP TABLE TestTable;
-- Əgər bir neçə operatoru icra etmək lazımdırsa, onda onları BEGIN ... END blokuna salmaq lazımdır
IF NOT EXISTS (    
				SELECT s.name,t.name
				FROM sys.schemas s 
				JOIN sys.tables t  
					ON s.schema_id=t.schema_id 
				WHERE s.name = 'dbo' 
					AND t.name = 'TestTable' 
				)	
				
	BEGIN   -- Blokun başlanğıcı
		PRINT N'TestTable cədvəli aşkar edilmədi';
		PRINT N'TestTable adlı cədvəl yaradıram';
		CREATE TABLE TestTable   -- Əgər cədvəl yoxdursa onu yaratmaq
			(
				Col1 int,
				Col2 varchar(20)
			)
	END   -- Blokun sonu
	
ELSE
	BEGIN
		PRINT N'TestTable adlı cədvəl mövcüddur!'; 
		PRINT N'TestTable adlı cədvəli silirəm';
		DROP TABLE TestTable;
		PRINT N'TestTable cədvəli silindi';
	END;
GO
----------------------------------------------------------------------------
--                            CASE operatoru
----------------------------------------------------------------------------
-- Sadə CASE operatoru

DECLARE @myTinyVar TinyInt = 3;
	
PRINT CASE @myTinyVar          -- CASE üçün giriş dəyəri
		WHEN 0 THEN 'zero'     -- əgər @myIntVar = 0 olarsa, onda ekranda 'zero' əks elətdiririk
		WHEN 1 THEN 'One'      -- əgər @myIntVar = 1 olarsa, onda ekranda 'One' əks elətdiririk
		WHEN 2 THEN 'Two'      -- əgər @myIntVar = 2 olarsa, onda ekranda 'Two' əks elətdiririk
		WHEN 3 THEN 'Three'    -- əgər @myIntVar = 3 olarsa, onda ekranda 'Three' əks elətdiririk
		ELSE 'More than three' -- əgər şərtlərdən heç bir doğru olmarsa, onda ekranda 'More than three' yazırıq	
	  END                      -- CASE operatorunun sonu
GO 

----------------------------------------------------------------------------
-- CASE axtarış operatoru
DECLARE @MyIntVar int;
	
SET @MyIntVar = 0;

PRINT CASE -- giriş dəyər mövcüd deyil
		WHEN @MyIntVar IS NULL THEN N'@MyIntVar boşdur'  -- WHEN blokunda olan şərt boolean dəyər qəbul etməlidir
		WHEN @MyIntVar < 0 THEN N'@MyIntVar dəyişəni sıfırdan kiçikdir'
		WHEN @MyIntVar > 0 THEN N'@MyIntVar dəyişəni sıfırdan bpyükdür'
		WHEN @MyIntVar > 3 THEN N'@MyIntVar dəyişəni üçdən böyükdür' -- bu sətir heç vaxt icra olunmayacaq, çünki yuxarıda olan şərt sıfırdan böyük olduğunu yoxlayır,
			--üçdən böyük olan ədəd isə həmişə sıfırdan da böyükdür
		ELSE N'Naməlum situasiya'
	  END
GO

----------------------------------------------------------------------------
-- WHILE operatoru. Dövlərin yaradılması

DECLARE @myVar int;
SET @myVar = 0;

	WHILE (@myVar < 21) -- şərt həqiqəti əks elətdirənə kimi dövrü icra etmək.
	BEGIN
		PRINT N'Cari dəyər ' + CAST (@myVar as varchar);
		SET @myVar = @myVar + 1;
	END
GO
----------------------------------------------------------------------------

DECLARE @myVar int;
SET @myVar =0;

	WHILE @myVar < 21 
	BEGIN
		PRINT N'Cari dəyər ' + CAST (@myVar as varchar);
		IF @myVar = 5
			BEGIN
				SET @myVar = @myVar + 2;
				CONTINUE; -- Cari iterasiyanın davam etməsini dayandırır və WHILE dövrünün əvvəlinə qaytarır
			END; 
		SET @myVar = @myVar + 1;
	END	
GO	
----------------------------------------------------------------------------

DECLARE @myVar int;
SET @myVar = 0;

	WHILE @myVar < 21 
	BEGIN
		PRINT N'Cari dəyər ' + CAST (@myVar as varchar);	
		IF @myVar = 7 
		BEGIN
			PRINT N'@myVar = 7! Dövrün dayandırılması!' 
			BREAK; -- Dövrün dayandırılması operatoru
		END
		SET @myVar = @myVar + 1;
	END	
GO	

----------------------------------------------------------------------------
--------------------------- WAITFOR opertoru -------------------------------

WAITFOR DELAY '00:00:10'; -- Qeyd olunan vaxt ərzində icranı dayandırmaq. Mümkün olan dəyərlər: saat:dəqiqə:saniyə

PRINT N'10 saniyə keçdi';

WAITFOR TIME '15:20:20'; -- Qeyd olunan vaxta kimi icranı dayandırmaq. Mümkün olan dəyərlər: saat:dəqiqə:saniyə

PRINT N' davam emtmək vaxtıdır';		
	
----------------------------------------------------------------------------
--------------------------- TRY və CATCH blokları------------------------------
-- xətaları emal etmək üçün nəzərdə tutulub
 
BEGIN TRY -- Kodu icra etmə cəhdi, əgər xəta yaransa onda kodun icrasını CATCH blokuna atırıq, əks halda kodun icrasını CATCH bloku olmadan icra edirik. 

	CREATE TABLE TestTable 
		(
			col1 int,
			col2 varchar(10)	
		);
		
END TRY
BEGIN CATCH -- CATCH bloku - xətaların emalı bloku

	DECLARE @ErrorNo  int,
			@Message  nvarchar(4000);

	SELECT
		@ErrorNo = ERROR_NUMBER(),		--cari xətanın kodu haqqında məlumat qaytaran sistem funskiyası
		@Message = ERROR_MESSAGE();		--cari xətanın məlumatını qaytaran sistem funskiyası

	IF @ErrorNo = 2714
		PRINT N'Cari cədvəl artıq mövcüddur!'
	ELSE
		PRINT CAST(@ErrorNo as varchar)+' '+@Message;
END CATCH
GO


----------------------------------------------------------------------------

BEGIN TRY -- Kodu icra etmə cəhdi, əgər xəta yaransa onda kodun icrasını CATCH blokuna atırıq, əks halda kodun icrasını CATCH bloku olmadan icra edirik. 
	
	DROP TABLE TestTable;

END TRY

BEGIN CATCH -- CATCH bloku - xətaların emalı bloku

	DECLARE @ErrorNo  int,
			@Message  nvarchar(4000);

	SELECT
		@ErrorNo = ERROR_NUMBER(),		--cari xətanın kodu haqqında məlumat qaytaran sistem funskiyası
		@Message = ERROR_MESSAGE();		--cari xətanın məlumatını qaytaran sistem funskiyası

	IF @ErrorNo = 3701
		PRINT N'Cari cədvəl artıq silinib!'
	ELSE
		PRINT CAST(@ErrorNo as varchar)+' '+@Message;
END CATCH
GO

----------------------------------------------------------------------------
--                 Avtomatik olaraq xətanın yaradılması
IF NOT EXISTS (    
				SELECT s.name,t.name
				FROM sys.schemas as s 
				JOIN sys.tables t  
					ON s.schema_id = t.schema_id 
				WHERE s.name = 'dbo' 
					AND t.name = 'TestTable' 
				)
				
	BEGIN   -- blokun başlanğıcı
		PRINT N'TestTable cədvəli tapılmadı';
		PRINT N'TestTable adlı yeni cədvəl yaradıram';
		CREATE TABLE TestTable -- əgər cədvəl yoxdursa onu yaratmaq
			(
				Col1 int,
				Col2 varchar(10)
			)
	END   -- blokun sonu
	
ELSE
	BEGIN
		RAISERROR(N'Cari cədvəl artıq mövcüddur', 11, 238) -- İstifadəçi tərəfindən yaradılmış xəta				
		-- RAISERROR (məktub, xətanın ciddiliyinin səviyyəsi, cari vəziyyət)
	END;
GO

----------------------------------------------------------------------------