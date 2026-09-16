USE Trigger_Exercise;
GO

SELECT DNumber, nbrEmployees FROM Department;
GO

-- Them 1 nhan vien vao phong 5 -> nbrEmployees phong 5 phai tang len 1
INSERT INTO Employee (FName, LName, SSN, BDate, Sex, Salary, DNo, HireDate)
VALUES ('Test','Emp8', '111111115', '1990-01-01', 'M', 20000, 5, '2020-01-01');
GO

SELECT DNumber, nbrEmployees FROM Department WHERE DNumber = 5;
GO

-- Xoa nhan vien do -> nbrEmployees phai giam lai
DELETE FROM Employee WHERE SSN = '111111115';
GO

SELECT DNumber, nbrEmployees FROM Department WHERE DNumber = 5;
GO
