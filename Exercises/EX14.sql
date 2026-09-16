USE Trigger_Exercise;
GO

/* =========================================================
   EXERCISE 14

   The manager of a department must work at least 5 hours
   on all projects controlled by the department.
   ========================================================= */


/* =========================================================
   TRIGGER 1
   Khi INSERT hoặc UPDATE Department (đặc biệt là khi
   MgrSSN thay đổi hoặc phòng ban mới được thêm)

   Kiểm tra: manager mới của phòng ban đó có làm đủ
   >= 5 giờ trên TẤT CẢ project thuộc phòng ban không.

   Dùng LEFT OUTER JOIN với WorksOn để bắt cả 2 trường hợp:
   - Manager hoàn toàn CHƯA làm project đó (Hours IS NULL)
   - Manager có làm nhưng Hours < 5
   ========================================================= */

CREATE OR ALTER TRIGGER mgrProj_Department
ON Department
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM (Inserted I JOIN Project P ON I.DNumber = P.DNumber)
        LEFT OUTER JOIN WorksOn W
            ON I.MgrSSN = W.ESSN
            AND P.PNumber = W.PNo
        WHERE W.Hours IS NULL
           OR W.Hours < 5
    )
    BEGIN

        RAISERROR(
            'Constraint Violation: A manager must work at least 5 hours on all projects controlled by his/her department',
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
   Khi INSERT hoặc UPDATE Project (project mới được tạo,
   hoặc project được chuyển sang phòng ban khác)

   Kiểm tra: manager của phòng ban sở hữu project đó
   có làm đủ >= 5 giờ trên project (các) project vừa
   inserted/updated không.
   ========================================================= */

CREATE OR ALTER TRIGGER mgrProj_Project
ON Project
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM (Project P JOIN Department D ON D.DNumber = P.DNumber)
        LEFT OUTER JOIN WorksOn W
            ON D.MgrSSN = W.ESSN
            AND P.PNumber = W.PNo
        WHERE P.PNumber IN
        (
            SELECT PNumber
            FROM Inserted
        )
        AND (W.Hours IS NULL OR W.Hours < 5)
    )
    BEGIN

        RAISERROR(
            'Constraint Violation: A manager must work at least 5 hours on all projects controlled by his/her department',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;

    END

END;
GO


/* =========================================================
   TRIGGER 3
   Khi UPDATE hoặc DELETE WorksOn

   Nếu dòng WorksOn bị xóa hoặc giảm giờ xuống dưới 5
   thuộc về một người ĐANG LÀ MANAGER của một phòng ban,
   phải kiểm tra lại toàn bộ project của phòng ban đó xem
   manager còn đủ >= 5 giờ trên MỌI project hay không.

   Dùng Deleted để lấy ESSN liên quan đến thay đổi vừa xảy ra,
   sau đó so khớp với Department.MgrSSN để biết người đó có
   đang là manager hay không.
   ========================================================= */

CREATE OR ALTER TRIGGER mgrProj_WorksOn
ON WorksOn
AFTER UPDATE, DELETE
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM (Department D JOIN Project P ON D.DNumber = P.DNumber)
        LEFT OUTER JOIN WorksOn W
            ON D.MgrSSN = W.ESSN
            AND P.PNumber = W.PNo
        WHERE D.MgrSSN IN
        (
            SELECT ESSN
            FROM Deleted
        )
        AND (W.Hours IS NULL OR W.Hours < 5)
    )
    BEGIN

        RAISERROR(
            'Constraint Violation: A manager must work at least 5 hours on all projects controlled by his/her department',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;

    END

END;
GO