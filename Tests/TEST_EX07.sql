USE Trigger_Exercise;
GO

-- John Smith (123456789) co sep Franklin Wong (333445555, HireDate 01-01-1982)
-- SAI: doi HireDate cua John thanh 1982 (cung nam voi sep) -> vi pham (<1 nam)
UPDATE Employee SET HireDate = '1982-06-01' WHERE SSN = '123456789';
GO

-- DUNG
UPDATE Employee SET HireDate = '1985-01-01' WHERE SSN = '123456789';
GO

SELECT SSN, FName, HireDate, SuperSSN FROM Employee WHERE SSN = '123456789';
GO
