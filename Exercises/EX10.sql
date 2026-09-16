USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 10: Mot nhan vien lam tu 30h den 50h/tuan tren tat ca du an
-- Can kiem tra ca khi INSERT, UPDATE, DELETE (xoa co the lam tong gio < 30)
-- ==========================================

IF OBJECT_ID('trg_HoursRange','TR') IS NOT NULL
    DROP TRIGGER trg_HoursRange;
GO

CREATE TRIGGER trg_HoursRange
ON WorksOn
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM WorksOn
        WHERE ESSN IN (SELECT ESSN FROM Inserted UNION SELECT ESSN FROM Deleted)
        GROUP BY ESSN
        HAVING SUM(hours) < 30 OR SUM(hours) > 50
    )
    BEGIN
        RAISERROR('Constraint Violation: An employee must work between 30h and 50h per week',16,1);
        ROLLBACK TRANSACTION;
    END
END
GO
