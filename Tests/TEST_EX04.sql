USE Trigger_Exercise;
GO

-- SAI: gan mot MgrSSN khong thuoc phong ban do
-- Vi du Ahmad Jabbar (987987987) thuoc DNo=4, thu lam manager cho Dept 5 (Research)
UPDATE Department SET MgrSSN = '987987987' WHERE DNumber = 5;
GO

-- DUNG: gan lai dung nguoi cua phong 5
UPDATE Department SET MgrSSN = '333445555' WHERE DNumber = 5;
GO

SELECT * FROM Department WHERE DNumber = 5;
GO
