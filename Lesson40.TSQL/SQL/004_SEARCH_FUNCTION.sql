USE ShopDB
GO	
---------- Əməkdaşların cədvəlin yaradırıq. ----------
CREATE TABLE MyEmployee
(
  EmployeeID int NOT NULL,
  ManagerID int NULL REFERENCES MyEmployee(EmployeeID), -- Cari əməkdaşın kimə tabe olduğunu göstərir.
  JobTitle nvarchar(50) NOT NULL,
  LastName nvarchar(50) NOT NULL,
  FirstName nvarchar(50) NOT NULL,
    CONSTRAINT PK_Employee2_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);
GO

-- İerarxik məlumatlar (bu cədvəldə həm əməkdaşlar, həm də əməkdaşların kimə tabe olduğu göstəririlir)
INSERT INTO MyEmployee(EmployeeID, ManagerID, JobTitle, LastName, FirstName)
VALUES
  (1, NULL, 'Chief Executive Officer', 'Smith', 'Victor'),
  (2, 1, 'Chief Financial Officer', 'Johnson', 'Lyudmila'),
  (3, 1, 'HR Specialist', 'Stepanov', 'Grigory'),
  (4, 1, 'Chief Operating Officer', 'Samoylenko', 'Victor'),
  (5, 4, 'Engineer', 'Timchenko', 'Vitaly'),
  (8, 5, 'Engineer', 'Habib', 'Eldar'),
  (9, 5, 'Programmer', 'Dulev', 'Pavel'),
  (10, 5, 'Data Architect', 'Churchill', 'Robert'),
  (11, 5, 'Programmer', 'Zalozny', 'Mikhail'),
  (6, 4, 'Personal Secretary', 'Radchenko', 'Vika'),
  (7, 4, 'Security Chief', 'Stelmakh', 'Igor');	

SELECT * FROM MyEmployee;

-- Direktorda kimin tabe olduğunu öyrənirik.
SELECT  sub.EmployeeID,
		sub.FirstName,
		sub.LastName
FROM
	MyEmployee as boss
	JOIN
	MyEmployee as sub
	ON boss.EmployeeID = sub.ManagerID
WHERE boss.JobTitle LIKE 'Chief Operating Officer';
GO

-- Bütün tabe olan əməkdaşların rekursiv olaraq ekrana çıxarılması.

CREATE FUNCTION fnGetSub (@EmployeeId int) -- Bir arqument qəbul edən funksiya yaradırıq.
RETURNS @Sub TABLE  -- Geriyə qayıdan cədvəli təyin edirik.
		(
			EmployeeId int,
			SubId int,
			Name varchar (90)
		)
AS
BEGIN
	DECLARE @EmpId int;

INSERT @Sub -- Rəhbər haqqında məlumatı geriyə qayıdan cədvələ yazırıq.
	SELECT EmployeeID, ManagerID ,FirstName+' '+LastName
	FROM MyEmployee
	WHERE EmployeeID = @EmployeeId;

SET @EmpId = (SELECT MIN(EmployeeID) -- Birinci tabe olanı müəyyən edirik.
			  FROM MyEmployee
			  WHERE ManagerID = @EmployeeId);
			  
-- Əgər beləsi aşkarlansa, onda WHILE dövrünə daxil oluruq
WHILE @EmpId IS NOT NULL -- Tabe olanlar mövcüd olana kimi dövrü davam edirik.
BEGIN
	INSERT @Sub -- Tabe olan şəxslər haqqında məlumatı seçilən müdirdən yuxarıya əlavə edirik.
		SELECT * FROM dbo.fnGetSub(@EmpId) -- Rekursiya.

	SET @EmpId =(SELECT MIN(EmployeeID) -- Növbəti tabe olanı müəyyən edirik.
				 FROM MyEmployee
				 WHERE EmployeeID > @EmpId
					   AND
					   ManagerID = @EmployeeId);
END;
RETURN; -- Əgər biz geriyə qayıdan cədvəli təyin etmişiksə, onda RETURN-da heç bir dəyər qoymuruq, əks halda xəta yaranacaqdır.
END;
GO

SELECT * FROM dbo.fnGetSub(4); -- Axtarış üçün fnGetSub funskiyasından istifadə edirik.
SELECT * FROM MyEmployee;
drop function fnGetSub 