USE Trigger_Exercise;
GO

-- Trường hợp SAI: nhân viên mới sinh năm nay (chưa đủ 18 tuổi) -> phải bị chặn
INSERT INTO Employee (FName, LName, SSN, BDate, Sex, Salary, DNo, HireDate)
VALUES ('Test','Minor','111111111', DATEADD(YEAR,-10,GETDATE()), 'M', 20000, 5, GETDATE());
GO

-- Trường hợp ĐÚNG: nhân viên đủ 18 tuổi -> phải insert thành công
INSERT INTO Employee (FName, LName, SSN, BDate, Sex, Salary, DNo, HireDate)
VALUES ('Test','Adult','111111112', '2000-01-01', 'M', 20000, 5, '2020-01-01');
GO

SELECT * FROM Employee WHERE SSN IN ('111111111','111111112');
GO
