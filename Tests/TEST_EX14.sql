USE Trigger_Exercise;
GO

/* =========================================================
   TEST EXERCISE 14

   The manager of a department must work at least 5 hours
   on all projects controlled by the department.
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
   Xem project của từng phòng ban
   ========================================================= */

PRINT '========== TEST 2: PROJECTS BY DEPARTMENT ==========';

SELECT
    P.DNumber,
    P.PNumber,
    P.PName
FROM Project P
ORDER BY P.DNumber, P.PNumber;
GO


/* =========================================================
   TEST 3
   XÁC NHẬN BASELINE: dữ liệu gốc đã thoả luật ngay từ đầu
   =========================================================

   Mục đích:
   Với mỗi phòng ban, hiển thị số giờ manager làm trên
   TỪNG project của phòng ban đó. Cột Hours phải >= 5
   ở mọi dòng thì mới an toàn để test các trigger tiếp theo
   (nếu baseline đã vi phạm sẵn thì các test FAIL/SUCCESS
   phía dưới sẽ cho kết quả sai lệch).
   ========================================================= */

PRINT '========== TEST 3: BASELINE MANAGER HOURS PER PROJECT ==========';

SELECT
    D.DNumber,
    D.MgrSSN,
    E.FName,
    E.LName,
    P.PNumber,
    P.PName,
    W.Hours
FROM (Department D JOIN Project P ON D.DNumber = P.DNumber)
LEFT OUTER JOIN WorksOn W
    ON D.MgrSSN = W.ESSN
    AND P.PNumber = W.PNo
JOIN Employee E
    ON D.MgrSSN = E.SSN
ORDER BY D.DNumber, P.PNumber;
-- kỳ vọng: mọi dòng Hours đều >= 5 (không NULL, không < 5)
GO


/* =========================================================
   TEST 4  (TRIGGER 1 - mgrProj_Department)
   ĐỔI MANAGER SANG NGƯỜI CHƯA LÀM ĐỦ GIỜ -> PHẢI BỊ CHẶN
   =========================================================

   Đổi manager của Dept 5 (Research, projects 1/2/3)
   sang Ahmad Jabbar (987987987), người hoàn toàn CHƯA
   có dòng WorksOn nào cho project 1, 2, 3.

   KẾT QUẢ MONG ĐỢI: bị chặn (Hours IS NULL).
   ========================================================= */

PRINT '========== TEST 4: NEW MANAGER WITHOUT ENOUGH HOURS (SHOULD FAIL) ==========';

BEGIN TRAN;

    PRINT 'Attempting to set Dept 5 manager to an employee with no hours on its projects...';

    UPDATE Department
    SET MgrSSN = '987987987'
    WHERE DNumber = 5;

    PRINT 'If you see this line, the trigger did NOT block the update (unexpected).';

ROLLBACK TRAN;

PRINT 'Transaction rolled back (if not already doomed by the trigger).';
GO


/* =========================================================
   TEST 5  (TRIGGER 1 - mgrProj_Department)
   ĐỔI MANAGER SANG NGƯỜI ĐÃ ĐỦ GIỜ -> PHẢI ĐƯỢC PHÉP
   =========================================================

   Đổi manager của Dept 4 (Administration, projects 10/30)
   sang Ahmad Jabbar (987987987), người đã có sẵn:
   - project 10: 35.0 giờ (>= 5)
   - project 30: 5.0 giờ  (>= 5, đúng biên)

   KẾT QUẢ MONG ĐỢI: INSERT/UPDATE thành công, không lỗi.
   ========================================================= */

PRINT '========== TEST 5: NEW MANAGER WITH ENOUGH HOURS (SHOULD SUCCEED) ==========';

BEGIN TRAN;

    PRINT 'Attempting to set Dept 4 manager to an employee who already meets the rule...';

    UPDATE Department
    SET MgrSSN = '987987987'
    WHERE DNumber = 4;

    PRINT 'Update succeeded as expected.';

    SELECT DNumber, MgrSSN FROM Department WHERE DNumber = 4;

ROLLBACK TRAN;

PRINT 'Transaction rolled back to restore original manager (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 6  (TRIGGER 2 - mgrProj_Project)
   THÊM PROJECT MỚI MÀ MANAGER CHƯA TỪNG LÀM -> PHẢI BỊ CHẶN
   =========================================================

   Thêm project mới (PNumber = 99) vào Dept 5.
   Manager hiện tại (Franklin Wong) chưa hề có dòng
   WorksOn nào cho project 99.

   KẾT QUẢ MONG ĐỢI: bị chặn (Hours IS NULL).
   ========================================================= */

PRINT '========== TEST 6: NEW PROJECT MANAGER HAS NOT WORKED ON (SHOULD FAIL) ==========';

BEGIN TRAN;

    PRINT 'Attempting to insert a new project into Dept 5...';

    INSERT INTO Project (PName, PNumber, PLocation, DNumber)
    VALUES ('TestProject', 99, 'Houston', 5);

    PRINT 'If you see this line, the trigger did NOT block the insert (unexpected).';

ROLLBACK TRAN;

PRINT 'Transaction rolled back (if not already doomed by the trigger).';
GO


/* =========================================================
   TEST 7  (TRIGGER 2 - mgrProj_Project)
   CẬP NHẬT PROJECT ĐÃ THOẢ ĐIỀU KIỆN -> PHẢI ĐƯỢC PHÉP
   =========================================================

   Cập nhật PLocation của project 1 (Dept 5) mà không
   đổi DNumber. Manager (Wong) đã có sẵn 10 giờ trên
   project này (>= 5), nên phải cập nhật được bình thường.

   KẾT QUẢ MONG ĐỢI: UPDATE thành công, không lỗi.
   ========================================================= */

PRINT '========== TEST 7: UPDATE EXISTING PROJECT ALREADY COMPLIANT (SHOULD SUCCEED) ==========';

BEGIN TRAN;

    PRINT 'Attempting to update PLocation of project 1...';

    UPDATE Project
    SET PLocation = 'Bellaire'
    WHERE PNumber = 1;

    PRINT 'Update succeeded as expected.';

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 8  (TRIGGER 3 - mgrProj_WorksOn)
   GIẢM GIỜ CỦA MANAGER XUỐNG DƯỚI 5 -> PHẢI BỊ CHẶN
   =========================================================

   Franklin Wong (manager Dept 5) đang có 10 giờ trên
   project 1. Giảm xuống còn 3 giờ sẽ làm ông không còn
   đủ >= 5 giờ trên project này.

   KẾT QUẢ MONG ĐỢI: bị chặn.
   ========================================================= */

PRINT '========== TEST 8: MANAGER HOURS REDUCED BELOW 5 (SHOULD FAIL) ==========';

BEGIN TRAN;

    PRINT 'Attempting to reduce Franklin Wong hours on project 1 to 3...';

    UPDATE WorksOn
    SET Hours = 3
    WHERE ESSN = '333445555'
      AND PNo = 1;

    PRINT 'If you see this line, the trigger did NOT block the update (unexpected).';

ROLLBACK TRAN;

PRINT 'Transaction rolled back (if not already doomed by the trigger).';
GO


/* =========================================================
   TEST 9  (TRIGGER 3 - mgrProj_WorksOn)
   XOÁ HẲN DÒNG WORKSON CỦA MANAGER -> PHẢI BỊ CHẶN
   =========================================================

   Xoá dòng WorksOn của Franklin Wong trên project 2.
   Sau khi xoá, Hours sẽ là NULL (do LEFT OUTER JOIN
   không còn dòng khớp) -> vi phạm.

   KẾT QUẢ MONG ĐỢI: bị chặn.
   ========================================================= */

PRINT '========== TEST 9: MANAGER WORKSON ROW DELETED (SHOULD FAIL) ==========';

BEGIN TRAN;

    PRINT 'Attempting to delete Franklin Wong WorksOn row on project 2...';

    DELETE FROM WorksOn
    WHERE ESSN = '333445555'
      AND PNo = 2;

    PRINT 'If you see this line, the trigger did NOT block the delete (unexpected).';

ROLLBACK TRAN;

PRINT 'Transaction rolled back (if not already doomed by the trigger).';
GO


/* =========================================================
   TEST 10  (TRIGGER 3 - mgrProj_WorksOn)
   GIẢM GIỜ NHƯNG VẪN >= 5 -> PHẢI ĐƯỢC PHÉP
   =========================================================

   Giảm giờ của Franklin Wong trên project 2 từ 10 xuống 6.
   Vẫn còn >= 5 nên không vi phạm.

   KẾT QUẢ MONG ĐỢI: UPDATE thành công, không lỗi.
   ========================================================= */

PRINT '========== TEST 10: MANAGER HOURS REDUCED BUT STILL >= 5 (SHOULD SUCCEED) ==========';

BEGIN TRAN;

    PRINT 'Attempting to reduce Franklin Wong hours on project 2 to 6...';

    UPDATE WorksOn
    SET Hours = 6
    WHERE ESSN = '333445555'
      AND PNo = 2;

    PRINT 'Update succeeded as expected.';

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 11  (TRIGGER 3 - mgrProj_WorksOn, xét RIÊNG LẺ)
   GIẢM GIỜ CỦA NGƯỜI KHÔNG PHẢI MANAGER
   =========================================================

   John Smith (123456789) không phải manager của phòng ban
   nào, nên xét RIÊNG trigger mgrProj_WorksOn của bài 14
   thì việc giảm giờ của anh không liên quan gì cả.

   LƯU Ý QUAN TRỌNG:
   Nếu trigger worksonLess5h_WorksOn của BÀI 12 cũng đang
   bật trên cùng bảng WorksOn, thao tác này SẼ BỊ CHẶN bởi
   trigger bài 12 (vì John làm < 5h mà không phải manager),
   KHÔNG PHẢI do trigger bài 14. Đây là hành vi ĐÚNG khi
   chạy chung cả nhóm trigger, không phải lỗi của bài 14.

   Muốn thấy trigger bài 14 "im lặng" đúng nghĩa (không có
   trigger nào khác can thiệp), hãy tạm DROP hoặc DISABLE
   trigger worksonLess5h_WorksOn trước khi chạy test này.

   KẾT QUẢ MONG ĐỢI:
   - Nếu CHỈ có trigger bài 14: UPDATE thành công.
   - Nếu chạy chung với trigger bài 12: bị chặn bởi
     worksonLess5h_WorksOn (không phải mgrProj_WorksOn).
     Cả hai trường hợp đều chứng tỏ trigger bài 14 KHÔNG
     tự ý chặn nhầm.
   ========================================================= */

PRINT '========== TEST 11: NON-MANAGER HOURS CHANGE ==========';

BEGIN TRAN;

    PRINT 'Attempting to reduce John Smith hours on project 1 to 1...';

    UPDATE WorksOn
    SET Hours = 1
    WHERE ESSN = '123456789'
      AND PNo = 1;

    PRINT 'Update succeeded (no trigger blocked it).';

ROLLBACK TRAN;

PRINT 'Transaction rolled back (test cleanup, not a failure).';
GO


/* =========================================================
   TEST 12
   XÁC NHẬN DỮ LIỆU GỐC KHÔNG BỊ ẢNH HƯỞNG
   ========================================================= */

PRINT '========== TEST 12: VERIFY DATA UNCHANGED AFTER ALL TESTS ==========';

SELECT COUNT(*) AS TotalProjects FROM Project;
-- kỳ vọng: vẫn là 6

SELECT COUNT(*) AS TotalWorksOnRows FROM WorksOn;
-- kỳ vọng: vẫn là 16

SELECT DNumber, MgrSSN FROM Department ORDER BY DNumber;
-- kỳ vọng: Dept1=888665555, Dept4=987654321, Dept5=333445555

SELECT ESSN, PNo, Hours FROM WorksOn
WHERE ESSN = '333445555'
ORDER BY PNo;
-- kỳ vọng: (1,10.0) (2,10.0) (3,20.0) như dữ liệu gốc
GO