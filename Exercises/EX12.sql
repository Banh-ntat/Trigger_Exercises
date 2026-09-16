USE Trigger_Exercise;
GO

/* =========================================================
   EXERCISE 12
   Only department managers can work less than 5 hours
   on a project.
   ========================================================= */


/* =========================================================
   Trigger 1
   Khi INSERT hoặc UPDATE WorksOn:
   Nếu nhân viên làm dưới 5 giờ nhưng không phải
   department manager -> từ chối.
   ========================================================= */

CREATE OR ALTER TRIGGER worksonLess5h_WorksOn
ON WorksOn
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM Inserted
        WHERE Hours < 5
          AND ESSN NOT IN
          (
              SELECT MgrSSN
              FROM Department
              WHERE MgrSSN IS NOT NULL
          )
    )
    BEGIN

        RAISERROR(
            'Constraint Violation: Only department managers can work less than 5 hours on a project',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;

    END

END;
GO


/* =========================================================
   Trigger 2
   Khi UPDATE hoặc DELETE Department:
   Nếu một người không còn là department manager nhưng
   người đó đang làm project dưới 5 giờ -> từ chối.
   ========================================================= */

CREATE OR ALTER TRIGGER worksonLess5h_Department
ON Department
AFTER UPDATE, DELETE
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM Deleted
        WHERE MgrSSN NOT IN
        (
            SELECT MgrSSN
            FROM Department
            WHERE MgrSSN IS NOT NULL
        )
        AND MgrSSN IN
        (
            SELECT ESSN
            FROM WorksOn
            WHERE Hours < 5
        )
    )
    BEGIN

        RAISERROR(
            'Constraint Violation: Only department managers can work less than 5 hours on a project',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;

    END

END;
GO