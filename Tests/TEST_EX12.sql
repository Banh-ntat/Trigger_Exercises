USE Trigger_Exercise;
GO

/* =========================================================
   TEST EXERCISE 12
   Only department managers can work less than 5 hours
   on a project.
   ========================================================= */


/* =========================================================
   TEST 1
   Xem danh sách Department Manager
   ========================================================= */

PRINT '========== TEST 1: DEPARTMENT MANAGERS ==========';

SELECT
    D.DNumber,
    D.DName,
    D.MgrSSN,
    E.FName,
    E.LName
FROM Department D
LEFT JOIN Employee E
    ON D.MgrSSN = E.SSN
ORDER BY D.DNumber;
GO


/* =========================================================
   TEST 2
   Xem các Project
   ========================================================= */

PRINT '========== TEST 2: PROJECTS ==========';

SELECT
    P.PNumber,
    P.PName,
    P.DNumber
FROM Project P
ORDER BY P.PNumber;
GO


/* =========================================================
   TEST 3
   Xem WorksOn hiện tại
   ========================================================= */

PRINT '========== TEST 3: CURRENT WORKSON ==========';

SELECT
    W.ESSN,
    E.FName,
    E.LName,
    W.PNo,
    P.PName,
    W.Hours
FROM WorksOn W
JOIN Employee E
    ON W.ESSN = E.SSN
JOIN Project P
    ON W.PNo = P.PNumber
ORDER BY W.ESSN, W.PNo;
GO


/* =========================================================
   TEST 4
   NON-MANAGER WORKS LESS THAN 5 HOURS
   =========================================================

   Mục đích:
   Chọn một Employee KHÔNG phải manager
   và một Project mà Employee đó CHƯA làm.

   Sau đó thử INSERT Hours = 3.

   KẾT QUẢ MONG ĐỢI:
   Constraint Violation
   INSERT bị ROLLBACK.
   ========================================================= */

PRINT '========== TEST 4: NON-MANAGER < 5 HOURS ==========';

DECLARE @EmployeeSSN CHAR(9);
DECLARE @ProjectNo INT;


/* Tìm một nhân viên không phải manager
   + project mà nhân viên đó chưa làm */

SELECT TOP 1
    @EmployeeSSN = E.SSN,
    @ProjectNo = P.PNumber
FROM Employee E
CROSS JOIN Project P
LEFT JOIN WorksOn W
    ON W.ESSN = E.SSN
    AND W.PNo = P.PNumber
WHERE E.SSN NOT IN
(
    SELECT MgrSSN
    FROM Department
    WHERE MgrSSN IS NOT NULL
)
AND W.ESSN IS NULL
ORDER BY E.SSN, P.PNumber;


/* Kiểm tra cặp Employee + Project được chọn */

SELECT
    @EmployeeSSN AS TestEmployeeSSN,
    @ProjectNo AS TestProjectNo;


/* Thử cho nhân viên không phải manager
   làm 3 giờ */

PRINT 'Attempting to insert 3 hours...';

INSERT INTO WorksOn
(
    ESSN,
    PNo,
    Hours
)
VALUES
(
    @EmployeeSSN,
    @ProjectNo,
    3
);
GO


/* =========================================================
   TEST 5
   Kiểm tra xem INSERT ở TEST 4 có được lưu hay không.
   Nếu trigger hoạt động đúng -> không có dòng tương ứng.
   ========================================================= */

PRINT '========== TEST 5: VERIFY ROLLBACK ==========';

SELECT
    W.ESSN,
    E.FName,
    E.LName,
    W.PNo,
    P.PName,
    W.Hours
FROM WorksOn W
JOIN Employee E
    ON W.ESSN = E.SSN
JOIN Project P
    ON W.PNo = P.PNumber
WHERE W.Hours < 5;
GO


/* =========================================================
   TEST 6
   MANAGER WORKS LESS THAN 5 HOURS -> PHAI DUOC PHEP
   =========================================================

   Mục đích:
   Chọn một Employee LÀ department manager
   và một Project mà manager đó CHƯA làm.

   Sau đó thử INSERT Hours = 3.

   KẾT QUẢ MONG ĐỢI:
   INSERT thành công, KHÔNG bị chặn,
   vì luật chỉ cấm non-manager làm dưới 5 giờ.
   ========================================================= */

PRINT '========== TEST 6: MANAGER < 5 HOURS (SHOULD SUCCEED) ==========';

DECLARE @MgrSSN CHAR(9);
DECLARE @MgrProjectNo INT;

/* Tìm một manager + project mà manager đó chưa làm */

SELECT TOP 1
    @MgrSSN = D.MgrSSN,
    @MgrProjectNo = P.PNumber
FROM Department D
CROSS JOIN Project P
LEFT JOIN WorksOn W
    ON W.ESSN = D.MgrSSN
    AND W.PNo = P.PNumber
WHERE D.MgrSSN IS NOT NULL
AND W.ESSN IS NULL
ORDER BY D.MgrSSN, P.PNumber;

SELECT
    @MgrSSN AS TestManagerSSN,
    @MgrProjectNo AS TestProjectNo;

PRINT 'Attempting to insert 3 hours for a manager...';

INSERT INTO WorksOn
(
    ESSN,
    PNo,
    Hours
)
VALUES
(
    @MgrSSN,
    @MgrProjectNo,
    3
);

/* Xác nhận dòng đã được lưu thành công */

PRINT 'Verify insert succeeded:';

SELECT
    W.ESSN,
    E.FName,
    E.LName,
    W.PNo,
    W.Hours
FROM WorksOn W
JOIN Employee E ON W.ESSN = E.SSN
WHERE W.ESSN = @MgrSSN
  AND W.PNo = @MgrProjectNo;

/* Dọn dẹp dữ liệu test để không ảnh hưởng các bài khác */

DELETE FROM WorksOn
WHERE ESSN = @MgrSSN
  AND PNo = @MgrProjectNo
  AND Hours = 3;

PRINT 'Test data cleaned up.';
GO


/* =========================================================
   TEST 7
   MAT CHUC MANAGER TRONG KHI VAN LAM DUOI 5 GIO
   =========================================================

   Mục đích:
   Giả lập tình huống: một manager đang có sẵn dòng
   WorksOn với Hours < 5, sau đó phòng ban đổi sang
   manager khác. Người cũ lúc này không còn là manager
   nữa nhưng vẫn đang làm dưới 5 giờ.

   Toàn bộ test chạy trong 1 transaction và ROLLBACK
   ở cuối để không làm thay đổi dữ liệu gốc.

   KẾT QUẢ MONG ĐỢI:
   Câu UPDATE Department (đổi manager) bị chặn bởi
   trigger worksonLess5h_Department.
   ========================================================= */

PRINT '========== TEST 7: MANAGER LOSES ROLE WHILE < 5H (SHOULD FAIL) ==========';

BEGIN TRAN;

    -- Jennifer Wallace (987654321) đang là manager Dept 4
    -- Đưa giờ làm của bà xuống dưới 5 để tạo tình huống vi phạm
    UPDATE WorksOn
    SET Hours = 3
    WHERE ESSN = '987654321'
      AND PNo = 10;

    PRINT 'Attempting to change manager of Department 4...';

    -- Đổi manager Dept 4 sang người khác
    -- -> Jennifer không còn là manager nhưng vẫn có Hours < 5
    UPDATE Department
    SET MgrSSN = '999887777'
    WHERE DNumber = 4;

    PRINT 'If you see this line, the trigger did NOT block the update (unexpected).';

ROLLBACK TRAN;

PRINT 'Transaction rolled back. Original data restored.';
GO


/* =========================================================
   TEST 8
   XAC NHAN DU LIEU GOC KHONG BI ANH HUONG
   ========================================================= */

PRINT '========== TEST 8: VERIFY DATA UNCHANGED AFTER TEST 6 & 7 ==========';

SELECT COUNT(*) AS TotalWorksOnRows FROM WorksOn;
-- kỳ vọng: vẫn là 16 dòng như dữ liệu gốc

SELECT MgrSSN FROM Department WHERE DNumber = 4;
-- kỳ vọng: vẫn là 987654321
GO