USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 6: HireDate phai lon hon BDate
-- ==========================================

ALTER TABLE Employee
ADD CONSTRAINT CK_Employee_HireDate_BDate
CHECK (HireDate > BDate);
GO
