USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 9: Mot nhan vien lam viec toi da 4 du an
-- ==========================================

IF OBJECT_ID('trg_MaxProjects','TR') IS NOT NULL
    DROP TRIGGER trg_MaxProjects;
GO

CREATE TRIGGER trg_MaxProjects
ON WorksOn
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM WorksOn
        WHERE ESSN IN (SELECT ESSN FROM Inserted)
        GROUP BY ESSN
        HAVING COUNT(*) > 4
    )
    BEGIN
        RAISERROR('Constraint Violation: An employee works in at most 4 projects',16,1);
        ROLLBACK TRANSACTION;
    END
END
GO
