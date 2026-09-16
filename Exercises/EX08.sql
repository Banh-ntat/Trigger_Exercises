USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 8: Department.nbrEmployees la thuoc tinh dan xuat tu Employee.DNo
-- Cap nhat tu dong nbrEmployees moi khi Employee insert/update/delete
-- ==========================================

IF OBJECT_ID('trg_Derive_NbrEmployees','TR') IS NOT NULL
    DROP TRIGGER trg_Derive_NbrEmployees;
GO

CREATE TRIGGER trg_Derive_NbrEmployees
ON Employee
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE D
    SET nbrEmployees = (
        SELECT COUNT(*) FROM Employee E WHERE E.DNo = D.DNumber
    )
    FROM Department D
    WHERE D.DNumber IN (SELECT DISTINCT DNo FROM Inserted)
       OR D.DNumber IN (SELECT DISTINCT DNo FROM Deleted);
END
GO

-- Chay 1 lan de dong bo lai gia tri ban dau cho du lieu da co san
UPDATE Department
SET nbrEmployees = (
    SELECT COUNT(*) FROM Employee E WHERE E.DNo = Department.DNumber
);
GO
