USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 3: Luong nhan vien khong duoc lon hon luong sep
-- ==========================================

IF OBJECT_ID('trg_SupervisorSalary','TR') IS NOT NULL
    DROP TRIGGER trg_SupervisorSalary;
GO

CREATE TRIGGER trg_SupervisorSalary
ON Employee
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted I
        JOIN Employee E
          ON ( I.SuperSSN = E.SSN AND I.Salary > E.Salary )
          OR ( E.SuperSSN = I.SSN AND E.Salary > I.Salary )
    )
    BEGIN
        RAISERROR('Constraint Violation: Employee salary cannot exceed supervisor salary',16,1);
        ROLLBACK TRANSACTION;
    END
END
GO
