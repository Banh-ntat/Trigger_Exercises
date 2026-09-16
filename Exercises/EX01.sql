USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 1: Tuổi nhân viên phải > 18
-- Chỉ so sánh trong cùng 1 dòng -> dùng CHECK constraint
-- ==========================================

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Employee_Age18'
)
BEGIN
    ALTER TABLE Employee
    ADD CONSTRAINT CK_Employee_Age18
    CHECK ( DATEADD(YEAR, 18, BDate) <= GETDATE() );
END
GO
