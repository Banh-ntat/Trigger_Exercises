USE Trigger_Exercise;
GO

/* =========================================================
   EXERCISE 13

   Employees that are not supervisors must work
   at least 10 hours on every project they work.
   ========================================================= */


/* =========================================================
   TRIGGER 1
   Khi INSERT hoặc UPDATE WorksOn

   Nếu Hours < 10
   và nhân viên đó không phải supervisor
   -> báo lỗi và rollback.
   ========================================================= */

CREATE OR ALTER TRIGGER workson10h_WorksOn
ON WorksOn
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM Inserted
        WHERE Hours < 10
          AND ESSN NOT IN
          (
              SELECT SuperSSN
              FROM Employee
              WHERE SuperSSN IS NOT NULL
          )
    )
    BEGIN

        RAISERROR(
            'Constraint Violation: Employees that are not supervisors must work at least 10 hours on every project they work',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;

    END

END;
GO


/* =========================================================
   TRIGGER 2
   Khi UPDATE hoặc DELETE Employee

   Nếu một người trước đây là supervisor
   nhưng sau UPDATE/DELETE không còn là supervisor nữa,
   trong khi người đó đang làm project < 10 giờ
   -> báo lỗi và rollback.
   ========================================================= */

CREATE OR ALTER TRIGGER workson10h_Employee
ON Employee
AFTER UPDATE, DELETE
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM Deleted
        WHERE SuperSSN NOT IN
        (
            SELECT SuperSSN
            FROM Employee
            WHERE SuperSSN IS NOT NULL
        )
        AND SuperSSN IN
        (
            SELECT ESSN
            FROM WorksOn
            WHERE Hours < 10
        )
    )
    BEGIN

        RAISERROR(
            'Constraint Violation: Employees that are not supervisors must work at least 10 hours on every project they work',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;

    END

END;
GO