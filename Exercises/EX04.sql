USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 4: Manager cua phong ban phai la nhan vien CUA phong ban do
-- Dung UNIQUE (SSN, DNo) + FK composite tren Department -> khong can trigger
-- ==========================================

ALTER TABLE Employee
ADD CONSTRAINT UQ_Employee_SSN_DNo UNIQUE (SSN, DNo);
GO

ALTER TABLE Department
ADD CONSTRAINT FK_Department_MgrSSN_DNo
FOREIGN KEY (MgrSSN, DNumber)
REFERENCES Employee (SSN, DNo);
GO
