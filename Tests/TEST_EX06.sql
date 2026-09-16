USE Trigger_Exercise;
GO

-- SAI: HireDate truoc BDate
INSERT INTO Employee (FName, LName, SSN, BDate, Sex, Salary, DNo, HireDate)
VALUES ('Test','BadHire','111111113', '2000-01-01', 'M', 20000, 5, '1999-01-01');
GO

-- DUNG
INSERT INTO Employee (FName, LName, SSN, BDate, Sex, Salary, DNo, HireDate)
VALUES ('Test','GoodHire','111111114', '2000-01-01', 'M', 20000, 5, '2020-01-01');
GO

SELECT * FROM Employee WHERE SSN IN ('111111113','111111114');
GO
