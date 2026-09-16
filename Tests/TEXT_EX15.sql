USE Trigger_Exercise;
GO

/* =========================================================
   TẠM TẮT TRIGGER CỦA EXERCISE 14 (nếu đã tích hợp)
   =========================================================

   File test này chỉ tập trung kiểm tra RIÊNG Exercise 15
   (derive SuperSSN). Nếu trigger mgrProj_Department của
   Exercise 14 đang bật, việc đổi Department.MgrSSN ở Test 2
   và Test 3 sẽ bị trigger đó chặn (vì manager mới thường
   chưa kịp có đủ giờ trên MỌI project của phòng ban) - đây
   là tương tác ĐÚNG giữa 2 bài, không phải lỗi của bài 15.

   Tắt tạm thời (KHÔNG xoá trigger) để test bài 15 độc lập,
   sau đó bật lại ở cuối file.
   ========================================================= */

IF OBJECT_ID('mgrProj_Department', 'TR') IS NOT NULL
    DISABLE TRIGGER mgrProj_Department ON Department;
GO


/* =========================================================
   TEST EXERCISE 15

   Employee.SuperSSN phải luôn khớp với công thức derive:
   - Manager của Dept khác 1 -> giám sát bởi manager Dept 1
   - Nhân viên thường -> giám sát bởi manager phòng ban mình
   - Manager của Dept 1 -> SuperSSN = NULL
   ========================================================= */


/* =========================================================
   TEST 1
   XÁC NHẬN BASELINE: dữ liệu gốc đã khớp công thức derive
   =========================================================

   Cột ExpectedSuperSSN được tính thủ công bằng CASE, so
   sánh với cột SuperSSN thực tế đang lưu trong bảng.
   Cột Match phải là 'OK' ở TẤT CẢ các dòng.
   ========================================================= */

PRINT '========== TEST 1: BASELINE COMPLIANCE CHECK ==========';

SELECT
    E.SSN,
    E.FName,
    E.LName,
    E.DNo,
    E.SuperSSN AS ActualSuperSSN,
    CASE
        WHEN E.SSN <> D.MgrSSN THEN D.MgrSSN
        WHEN E.SSN = D.MgrSSN AND E.DNo <> 1
            THEN (SELECT MgrSSN FROM Department WHERE DNumber = 1)
        ELSE NULL
    END AS ExpectedSuperSSN,
    CASE
        WHEN E.SuperSSN = CASE
                WHEN E.SSN <> D.MgrSSN THEN D.MgrSSN
                WHEN E.SSN = D.MgrSSN AND E.DNo <> 1
                    THEN (SELECT MgrSSN FROM Department WHERE DNumber = 1)
                ELSE NULL
             END
          OR (E.SuperSSN IS NULL AND CASE
                WHEN E.SSN <> D.MgrSSN THEN D.MgrSSN
                WHEN E.SSN = D.MgrSSN AND E.DNo <> 1
                    THEN (SELECT MgrSSN FROM Department WHERE DNumber = 1)
                ELSE NULL
             END IS NULL)
        THEN 'OK'
        ELSE 'MISMATCH'
    END AS MatchStatus
FROM Employee E
JOIN Department D ON D.DNumber = E.DNo
ORDER BY E.SSN;
-- kỳ vọng: cột MatchStatus toàn bộ là 'OK'
GO


/* =========================================================
   TEST 2  (TRIGGER 1)
   ĐỔI MANAGER CỦA PHÒNG BAN THƯỜNG (Dept 5)
   =========================================================

   Đổi manager Dept 5 từ Franklin Wong (333445555)
   sang Ramesh Narayan (666884444).

   KẾT QUẢ MONG ĐỢI (tự động, không cần UPDATE tay):
   - Ramesh (manager mới, không phải Dept 1)
     -> SuperSSN = manager Headquarters = 888665555 (Borg)
   - Wong, John, Joyce (các nhân viên còn lại của Dept 5)
     -> SuperSSN = manager mới = 666884444 (Ramesh)
   ========================================================= */

PRINT '========== TEST 2: CHANGE MANAGER OF A REGULAR DEPARTMENT ==========';

BEGIN TRAN;

    UPDATE Department
    SET MgrSSN = '666884444'
    WHERE DNumber = 5;

    SELECT
        SSN, FName, LName, DNo, SuperSSN
    FROM Employee
    WHERE DNo = 5
    ORDER BY SSN;
    -- kỳ vọng:
    --   123456789 (John)    -> SuperSSN = 666884444
    --   333445555 (Wong)    -> SuperSSN = 666884444
    --   453453453 (Joyce)   -> SuperSSN = 666884444
    --   666884444 (Ramesh)  -> SuperSSN = 888665555

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 3  (TRIGGER 1 - trường hợp đặc biệt)
   ĐỔI MANAGER CỦA HEADQUARTERS (Dept 1)
   =========================================================

   Đổi manager Dept 1 từ James Borg (888665555)
   sang John Smith (123456789). Di chuyển John sang Dept 1
   trước để tránh xung đột với constraint của Exercise 4
   (nếu đang được bật).

   KẾT QUẢ MONG ĐỢI:
   - John (manager mới của Dept 1) -> SuperSSN = NULL
   - Wallace (987654321, manager Dept 4) -> SuperSSN = 123456789
   - Wong (333445555, manager Dept 5)    -> SuperSSN = 123456789
   - Borg (888665555, không còn là manager, vẫn thuộc Dept 1)
     -> SuperSSN = 123456789 (giám sát bởi manager mới của
     chính phòng ban mình, đúng theo nghĩa đen của luật)
   ========================================================= */

PRINT '========== TEST 3: CHANGE MANAGER OF HEADQUARTERS (CASCADE TO ALL MANAGERS) ==========';

BEGIN TRAN;

    PRINT 'Step 1: chuyen John Smith sang Dept 1...';

    UPDATE Employee
    SET DNo = 1
    WHERE SSN = '123456789';

    PRINT 'Step 2: dat John Smith lam manager cua Dept 1...';

    UPDATE Department
    SET MgrSSN = '123456789'
    WHERE DNumber = 1;

    SELECT
        SSN, FName, LName, DNo, SuperSSN
    FROM Employee
    WHERE SSN IN ('123456789', '987654321', '333445555', '888665555')
    ORDER BY SSN;
    -- kỳ vọng:
    --   123456789 (John, manager Dept 1)   -> SuperSSN = NULL
    --   333445555 (Wong, manager Dept 5)   -> SuperSSN = 123456789
    --   888665555 (Borg, nay là nhân viên) -> SuperSSN = 123456789
    --   987654321 (Wallace, manager Dept4) -> SuperSSN = 123456789

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 4  (TRIGGER 2)
   NHÂN VIÊN THƯỜNG CHUYỂN SANG PHÒNG BAN KHÁC
   =========================================================

   Chuyển Ramesh Narayan (666884444, hiện là nhân viên
   thường của Dept 5) sang Dept 4.

   KẾT QUẢ MONG ĐỢI:
   Ramesh không phải manager của Dept 4
   -> SuperSSN = manager Dept 4 = 987654321 (Wallace)
   ========================================================= */

PRINT '========== TEST 4: EMPLOYEE MOVES TO ANOTHER DEPARTMENT ==========';

BEGIN TRAN;

    UPDATE Employee
    SET DNo = 4
    WHERE SSN = '666884444';

    SELECT SSN, FName, LName, DNo, SuperSSN
    FROM Employee
    WHERE SSN = '666884444';
    -- kỳ vọng: DNo = 4, SuperSSN = 987654321

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 5  (TRIGGER 2)
   NHÂN VIÊN CHUYỂN SANG HEADQUARTERS (không phải manager)
   =========================================================

   Chuyển Ahmad Jabbar (987987987, nhân viên thường Dept 4)
   sang Dept 1.

   KẾT QUẢ MONG ĐỢI:
   Ahmad không phải manager của Dept 1
   -> SuperSSN = manager Dept 1 = 888665555 (Borg)
   ========================================================= */

PRINT '========== TEST 5: EMPLOYEE MOVES TO HEADQUARTERS (SHOULD SUCCEED) ==========';

BEGIN TRAN;

    UPDATE Employee
    SET DNo = 1
    WHERE SSN = '987987987';

    SELECT SSN, FName, LName, DNo, SuperSSN
    FROM Employee
    WHERE SSN = '987987987';
    -- kỳ vọng: DNo = 1, SuperSSN = 888665555

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 6  (TRIGGER 2)
   THÊM NHÂN VIÊN MỚI -> SUPERSSN PHẢI TỰ ĐỘNG TÍNH LẠI
   =========================================================

   Thêm nhân viên mới vào Dept 5, cố tình INSERT SuperSSN
   = NULL (sai) để kiểm chứng trigger sẽ GHI ĐÈ giá trị
   đúng ngay sau INSERT.

   KẾT QUẢ MONG ĐỢI:
   SuperSSN tự động trở thành 333445555 (Wong, manager
   Dept 5), bất kể giá trị INSERT ban đầu là gì.
   ========================================================= */

PRINT '========== TEST 6: NEW EMPLOYEE SUPERSSN AUTO-DERIVED (SHOULD SUCCEED) ==========';

BEGIN TRAN;

    INSERT INTO Employee (FName, LName, SSN, DNo, SuperSSN, BDate, HireDate)
    VALUES ('Test', 'Employee', '111111111', 5, NULL, '1990-01-01', '2020-01-01');

    SELECT SSN, FName, LName, DNo, SuperSSN
    FROM Employee
    WHERE SSN = '111111111';
    -- kỳ vọng: SuperSSN = 333445555 (không phải NULL như đã insert)

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 7
   XÁC NHẬN DỮ LIỆU GỐC KHÔNG BỊ ẢNH HƯỞNG SAU TOÀN BỘ TEST
   ========================================================= */

PRINT '========== TEST 7: VERIFY DATA UNCHANGED AFTER ALL TESTS ==========';

SELECT COUNT(*) AS TotalEmployees FROM Employee;
-- kỳ vọng: vẫn là 8

SELECT SSN, DNo, SuperSSN FROM Employee ORDER BY SSN;
-- kỳ vọng: giống hệt dữ liệu gốc ban đầu (xem lại Test 1)

SELECT DNumber, MgrSSN FROM Department ORDER BY DNumber;
-- kỳ vọng: Dept1=888665555, Dept4=987654321, Dept5=333445555
GO


/* =========================================================
   BẬT LẠI TRIGGER CỦA EXERCISE 14
   =========================================================

   Bắt buộc chạy khối này sau khi test xong, nếu không
   trigger mgrProj_Department sẽ bị vô hiệu hoá vĩnh viễn
   cho các lần chạy sau (kể cả khi test các bài khác).
   ========================================================= */

IF OBJECT_ID('mgrProj_Department', 'TR') IS NOT NULL
    ENABLE TRIGGER mgrProj_Department ON Department;
GO

-- Xác nhận trigger đã được bật lại
SELECT
    name AS TriggerName,
    is_disabled
FROM sys.triggers
WHERE name = 'mgrProj_Department';
-- kỳ vọng: is_disabled = 0
GO