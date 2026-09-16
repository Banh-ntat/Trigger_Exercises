USE Trigger_Exercise;
GO

-- SAI: nang luong John (123456789, sep la Franklin 333445555 luong 40000) len 50000 -> vuot luong sep
UPDATE Employee SET Salary = 50000 WHERE SSN = '123456789';
GO

-- DUNG
UPDATE Employee SET Salary = 30000 WHERE SSN = '123456789';
GO

SELECT SSN, FName, Salary, SuperSSN FROM Employee WHERE SSN = '123456789';
GO
