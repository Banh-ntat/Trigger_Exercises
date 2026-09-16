USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 7: Sep phai duoc thue truoc nhan vien minh giam sat it nhat 1 nam
-- ==========================================

IF OBJECT_ID('trg_HireSupervisor','TR') IS NOT NULL
    DROP TRIGGER trg_HireSupervisor;
GO

CREATE TRIGGER trg_HireSupervisor
ON Employee
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted I
        JOIN Employee E
          ON ( I.SuperSSN = E.SSN AND DATEDIFF(YEAR, E.HireDate, I.HireDate) < 1 )
          OR ( E.SuperSSN = I.SSN AND DATEDIFF(YEAR, I.HireDate, E.HireDate) < 1 )
    )
    BEGIN
        RAISERROR('Constraint Violation: Supervisor must be hired at least 1 year before employee',16,1);
        ROLLBACK TRANSACTION;
    END
END
GO
