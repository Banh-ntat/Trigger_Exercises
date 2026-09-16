USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 16
-- The supervision relationship in Employee.SuperSSN
-- must not be cyclic
--
-- Ky thuat:
-- Tinh quan he bac cau (transitive closure) cua quan he
-- Supervisor bang bang tam #Supervision.
-- Neu xuat hien dong co SSN = SuperSSN thi ton tai chu trinh.
-- ==========================================

CREATE OR ALTER TRIGGER noncyclic_subordinates
ON Employee
AFTER INSERT, UPDATE
AS
BEGIN

    -- Tao bang tam luu quan he Supervisor
    CREATE TABLE #Supervision
    (
        SSN CHAR(9),
        SuperSSN CHAR(9),
        PRIMARY KEY (SSN, SuperSSN)
    );

    -- Lay cac quan he Supervisor hien tai
    INSERT INTO #Supervision
    SELECT SSN, SuperSSN
    FROM Employee
    WHERE SuperSSN IS NOT NULL;

    -- Tinh quan he bac cau
    WHILE @@ROWCOUNT != 0
    BEGIN

        -- Neu mot nhan vien giam sat chinh no
        -- thi ton tai chu trinh
        IF EXISTS
        (
            SELECT *
            FROM #Supervision
            WHERE SSN = SuperSSN
        )
        BEGIN
            RAISERROR(
                'Constraint Violation: The supervision relationship is cyclic',
                16,
                1
            );

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Mo rong quan he Supervisor
        INSERT INTO #Supervision
        SELECT DISTINCT
            S1.SSN,
            S2.SuperSSN
        FROM #Supervision S1
        JOIN #Supervision S2
            ON S1.SuperSSN = S2.SSN
        WHERE NOT EXISTS
        (
            SELECT *
            FROM #Supervision S
            WHERE S.SSN = S1.SSN
              AND S.SuperSSN = S2.SuperSSN
        );

    END;

    DROP TABLE #Supervision;

END;
GO