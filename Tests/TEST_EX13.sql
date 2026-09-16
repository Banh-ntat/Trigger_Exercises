USE Trigger_Exercise;
GO

/* =========================================================
   TEST EXERCISE 13

   Employees that are not supervisors must work
   at least 10 hours on every project they work.
   ========================================================= */


/* =========================================================
   TEST 1
   Xem nhân viên và xác định supervisor
   ========================================================= */

PRINT '========== TEST 1: EMPLOYEES / SUPERVISORS ==========';

SELECT
    E.SSN,
    E.FName,
    E.LName,
    E.SuperSSN,

    CASE
        WHEN E.SSN IN
        (
            SELECT SuperSSN
            FROM Employee
            WHERE SuperSSN IS NOT NULL
        )
        THEN 'SUPERVISOR'
        ELSE 'NOT SUPERVISOR'
    END AS EmployeeType

FROM Employee E
ORDER BY E.SSN;
GO


/* =========================================================
   TEST 2
   Xem WorksOn hiện tại
   ========================================================= */

PRINT '========== TEST 2: CURRENT WORKSON ==========';

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
   TEST 3 + TEST 4 + TEST 5

   Tất cả nằm trong cùng một batch để biến không bị mất.
   ========================================================= */

PRINT '========== TEST 3: FIND NON-SUPERVISOR ==========';

DECLARE @TestEmployeeSSN CHAR(9);
DECLARE @TestProjectNo INT;


/* Tìm nhân viên KHÔNG phải supervisor
   và project mà người đó chưa làm */

SELECT TOP 1
    @TestEmployeeSSN = E.SSN,
    @TestProjectNo = P.PNumber
FROM Employee E
CROSS JOIN Project P
LEFT JOIN WorksOn W
    ON W.ESSN = E.SSN
    AND W.PNo = P.PNumber
WHERE E.SSN NOT IN
(
    SELECT SuperSSN
    FROM Employee
    WHERE SuperSSN IS NOT NULL
)
AND W.ESSN IS NULL
ORDER BY E.SSN, P.PNumber;


/* Hiển thị đối tượng test */

SELECT
    @TestEmployeeSSN AS TestEmployeeSSN,
    @TestProjectNo AS TestProjectNo;


/* =========================================================
   TEST 4
   Thử cho nhân viên không phải supervisor làm 5 giờ
   ========================================================= */

PRINT '========== TEST 4: NON-SUPERVISOR < 10 HOURS ==========';

PRINT 'Employee selected: ' + @TestEmployeeSSN;
PRINT 'Project selected: ' + CAST(@TestProjectNo AS VARCHAR(10));

PRINT 'Attempting to insert 5 hours...';


INSERT INTO WorksOn
(
    ESSN,
    PNo,
    Hours
)
VALUES
(
    @TestEmployeeSSN,
    @TestProjectNo,
    5
);


/* =========================================================
   TEST 5
   Chỉ chạy được nếu INSERT ở TEST 4 không bị rollback.

   Nếu trigger hoạt động đúng, INSERT ở trên đã rollback
   nên SELECT này không được thực hiện sau lỗi.
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
WHERE W.ESSN = @TestEmployeeSSN
  AND W.PNo = @TestProjectNo;
GO


/* =========================================================
   TEST 6
   NON-SUPERVISOR LAM >= 10 GIO -> PHAI DUOC PHEP
   =========================================================

   Mục đích:
   Chọn một Employee KHÔNG phải supervisor
   và một Project mà người đó chưa làm.
   Insert đúng biên Hours = 10 (không nhỏ hơn 10).

   KẾT QUẢ MONG ĐỢI:
   INSERT thành công, KHÔNG bị chặn.
   ========================================================= */

PRINT '========== TEST 6: NON-SUPERVISOR >= 10 HOURS (SHOULD SUCCEED) ==========';

DECLARE @NsSSN CHAR(9);
DECLARE @NsProjectNo INT;

SELECT TOP 1
    @NsSSN = E.SSN,
    @NsProjectNo = P.PNumber
FROM Employee E
CROSS JOIN Project P
LEFT JOIN WorksOn W
    ON W.ESSN = E.SSN
    AND W.PNo = P.PNumber
WHERE E.SSN NOT IN
(
    SELECT SuperSSN
    FROM Employee
    WHERE SuperSSN IS NOT NULL
)
AND W.ESSN IS NULL
ORDER BY E.SSN, P.PNumber;

SELECT
    @NsSSN AS TestEmployeeSSN,
    @NsProjectNo AS TestProjectNo;

PRINT 'Attempting to insert 10 hours (boundary value)...';

INSERT INTO WorksOn
(
    ESSN,
    PNo,
    Hours
)
VALUES
(
    @NsSSN,
    @NsProjectNo,
    10
);

PRINT 'Verify insert succeeded:';

SELECT
    W.ESSN,
    E.FName,
    E.LName,
    W.PNo,
    W.Hours
FROM WorksOn W
JOIN Employee E ON W.ESSN = E.SSN
WHERE W.ESSN = @NsSSN
  AND W.PNo = @NsProjectNo;

/* Dọn dẹp dữ liệu test */

DELETE FROM WorksOn
WHERE ESSN = @NsSSN
  AND PNo = @NsProjectNo
  AND Hours = 10;

PRINT 'Test data cleaned up.';
GO


/* =========================================================
   TEST 7
   SUPERVISOR LAM DUOI 10 GIO -> PHAI DUOC PHEP
   =========================================================

   Mục đích:
   Luật chỉ áp dụng cho nhân viên KHÔNG phải supervisor.
   Chọn một supervisor thực sự (Franklin Wong) và một
   project anh chưa làm, insert 3 giờ.

   KẾT QUẢ MONG ĐỢI:
   INSERT thành công, KHÔNG bị chặn.
   ========================================================= */

PRINT '========== TEST 7: SUPERVISOR < 10 HOURS (SHOULD SUCCEED) ==========';

DECLARE @SupSSN CHAR(9) = '333445555'; -- Franklin Wong, supervisor của John/Ramesh/Joyce
DECLARE @SupProjectNo INT;

SELECT TOP 1
    @SupProjectNo = P.PNumber
FROM Project P
LEFT JOIN WorksOn W
    ON W.ESSN = @SupSSN
    AND W.PNo = P.PNumber
WHERE W.ESSN IS NULL
ORDER BY P.PNumber;

SELECT
    @SupSSN AS TestSupervisorSSN,
    @SupProjectNo AS TestProjectNo;

PRINT 'Attempting to insert 3 hours for a supervisor...';

INSERT INTO WorksOn
(
    ESSN,
    PNo,
    Hours
)
VALUES
(
    @SupSSN,
    @SupProjectNo,
    3
);

PRINT 'Verify insert succeeded:';

SELECT
    W.ESSN,
    E.FName,
    E.LName,
    W.PNo,
    W.Hours
FROM WorksOn W
JOIN Employee E ON W.ESSN = E.SSN
WHERE W.ESSN = @SupSSN
  AND W.PNo = @SupProjectNo;

/* Dọn dẹp dữ liệu test */

DELETE FROM WorksOn
WHERE ESSN = @SupSSN
  AND PNo = @SupProjectNo
  AND Hours = 3;

PRINT 'Test data cleaned up.';
GO


/* =========================================================
   TEST 8
   MAT CHUC SUPERVISOR TRONG KHI DANG LAM DUOI 10 GIO
   =========================================================

   Mục đích:
   Jennifer Wallace (987654321) hiện là supervisor của
   Alicia Zelaya (999887777) và Ahmad Jabbar (987987987).
   Wallace đã có sẵn WorksOn (PNo=10, Hours=5.0) < 10 giờ,
   điều này hợp lệ CHỈ VÌ bà đang là supervisor.

   Nếu đổi SuperSSN của CẢ HAI người bà giám sát sang
   người khác, Wallace sẽ mất chức supervisor trong khi
   vẫn đang có dòng WorksOn với Hours < 10.

   Toàn bộ chạy trong 1 transaction và ROLLBACK cuối cùng
   để không ảnh hưởng dữ liệu gốc.

   KẾT QUẢ MONG ĐỢI:
   Câu UPDATE thứ hai (khi Wallace không còn ai để giám
   sát) phải bị chặn bởi trigger workson10h_Employee.
   ========================================================= */

PRINT '========== TEST 8: SUPERVISOR LOSES ROLE WHILE < 10H (SHOULD FAIL) ==========';

-- Xác nhận tiền đề: Wallace đang có Hours < 10 và đang là supervisor
SELECT
    W.ESSN, E.FName, E.LName, W.PNo, W.Hours
FROM WorksOn W
JOIN Employee E ON E.SSN = W.ESSN
WHERE W.ESSN = '987654321';

BEGIN TRAN;

    PRINT 'Step 1: chuyen Alicia sang giam sat boi nguoi khac (Wallace van con Ahmad)...';

    UPDATE Employee
    SET SuperSSN = '888665555'
    WHERE SSN = '999887777'; -- Alicia: 987654321 -> 888665555

    PRINT 'Step 1 OK (Wallace vAn con supervisor vi Ahmad chua doi).';

    PRINT 'Step 2: chuyen not Ahmad -> Wallace mat het nguoi giam sat...';

    UPDATE Employee
    SET SuperSSN = '888665555'
    WHERE SSN = '987987987'; -- Ahmad: 987654321 -> 888665555

    PRINT 'If you see this line, the trigger did NOT block the update (unexpected).';

ROLLBACK TRAN;

PRINT 'Transaction rolled back. Original data restored.';
GO


/* =========================================================
   TEST 9
   XAC NHAN DU LIEU GOC KHONG BI ANH HUONG
   ========================================================= */

PRINT '========== TEST 9: VERIFY DATA UNCHANGED AFTER TEST 6, 7 & 8 ==========';

SELECT COUNT(*) AS TotalWorksOnRows FROM WorksOn;
-- kỳ vọng: vẫn là 16 dòng như dữ liệu gốc

SELECT SSN, SuperSSN FROM Employee
WHERE SSN IN ('999887777', '987987987');
-- kỳ vọng: cả hai vẫn có SuperSSN = 987654321
GO