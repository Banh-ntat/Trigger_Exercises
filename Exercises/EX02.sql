USE Trigger_Exercise;
GO

IF OBJECT_ID('trg_SupervisorAge','TR') IS NOT NULL
    DROP TRIGGER trg_SupervisorAge;
GO

CREATE TRIGGER trg_SupervisorAge
ON Employee
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted I
        JOIN Employee E
          ON ( I.SuperSSN = E.SSN AND I.BDate < E.BDate )   -- I la nhan vien, E la sep -> I phai gia hon E
          OR ( E.SuperSSN = I.SSN AND E.BDate < I.BDate )   -- I la sep, E la nhan vien -> I phai gia hon E
    )
    BEGIN
        RAISERROR('Constraint Violation: The supervisor must be older than the employee',16,1);
        ROLLBACK TRANSACTION;
    END
END
GO
