USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 11: Trong 1 du an, toi da 2 nguoi duoc lam duoi 10h
-- ==========================================

IF OBJECT_ID('trg_MaxUnder10h','TR') IS NOT NULL
    DROP TRIGGER trg_MaxUnder10h;
GO

CREATE TRIGGER trg_MaxUnder10h
ON WorksOn
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM WorksOn
        WHERE hours < 10
          AND PNo IN (SELECT PNo FROM Inserted)
        GROUP BY PNo
        HAVING COUNT(*) > 2
    )
    BEGIN
        RAISERROR('Constraint Violation: At most 2 employees can work less than 10h on a project',16,1);
        ROLLBACK TRANSACTION;
    END
END
GO
