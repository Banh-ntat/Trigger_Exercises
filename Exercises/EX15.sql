USE Trigger_Exercise;
GO

/* =========================================================
   EXERCISE 15

   The attribute Employee.SuperSSN is a derived attribute
   computed as follows:
   - Department managers are supervised by the manager of
     Department 1 (Headquarters).
   - Employees that are not managers are supervised by the
     manager of their own department.
   - The manager of Department 1 has a NULL value in
     attribute SuperSSN.

   Đây KHÔNG phải trigger kiểu "kiểm tra và chặn" như các
   bài 12-14. Đây là trigger kiểu "tự động tính lại giá trị"
   (derive), giống bài 8. Khi dữ liệu nguồn (Department.MgrSSN
   hoặc Employee.DNo) thay đổi, trigger sẽ tự UPDATE lại
   Employee.SuperSSN cho đúng công thức trên.
   ========================================================= */


/* =========================================================
   TRIGGER 1
   Khi INSERT hoặc UPDATE Department (cụ thể là khi cột
   MgrSSN thay đổi - có manager mới)

   Cần cập nhật lại SuperSSN của:
   a) TẤT CẢ nhân viên thuộc phòng ban vừa đổi manager
      (kể cả manager mới và các nhân viên thường trong đó)
   b) NẾU phòng ban 1 (Headquarters) vừa đổi manager thì
      phải cập nhật lại SuperSSN của TẤT CẢ manager của
      các phòng ban khác (vì tất cả manager đều được giám
      sát bởi manager của Headquarters)
   ========================================================= */

CREATE OR ALTER TRIGGER derived_Employee_SuperSSN_Department
ON Department
AFTER INSERT, UPDATE
AS
BEGIN

    IF UPDATE(MgrSSN)
    BEGIN

        UPDATE Employee
        SET SuperSSN =
        (
            SELECT
                CASE
                    -- Nhân viên KHÔNG phải manager của phòng ban mình
                    -- -> được giám sát bởi manager của phòng ban đó
                    WHEN Employee.SSN <> D.MgrSSN
                        THEN D.MgrSSN

                    -- Nhân viên LÀ manager, nhưng không phải Dept 1
                    -- -> được giám sát bởi manager của Headquarters
                    WHEN Employee.SSN = D.MgrSSN AND Employee.DNo <> 1
                        THEN (SELECT MgrSSN FROM Department WHERE DNumber = 1)

                    -- Nhân viên LÀ manager của chính Dept 1
                    -- -> không ai giám sát, SuperSSN = NULL
                    ELSE NULL
                END
            FROM Department D
            WHERE D.DNumber = Employee.DNo
        )
        WHERE
            -- (a) nhân viên thuộc phòng ban vừa đổi manager
            DNo IN (SELECT DNumber FROM Inserted)

            -- (b) phòng ban 1 (Headquarters) vừa đổi manager
            -- -> cập nhật lại mọi manager hiện có (họ đều được
            --    giám sát bởi manager mới của Headquarters)
            OR
            (
                1 IN (SELECT DNumber FROM Inserted)
                AND SSN IN (SELECT MgrSSN FROM Department)
            );

    END

END;
GO


/* =========================================================
   TRIGGER 2
   Khi INSERT hoặc UPDATE Employee (cụ thể là khi cột DNo
   thay đổi - nhân viên chuyển sang phòng ban khác, hoặc
   nhân viên mới được thêm vào)

   Tính lại SuperSSN dựa trên phòng ban MỚI của nhân viên đó,
   theo đúng công thức: không phải manager -> giám sát bởi
   manager phòng ban mình; là manager (không phải Dept 1)
   -> giám sát bởi manager Headquarters; là manager Dept 1
   -> NULL.
   ========================================================= */

CREATE OR ALTER TRIGGER derived_Employee_SuperSSN_Employee
ON Employee
AFTER INSERT, UPDATE
AS
BEGIN

    IF UPDATE(DNo)
    BEGIN

        UPDATE Employee
        SET SuperSSN =
        (
            SELECT
                CASE
                    WHEN I.SSN <> D.MgrSSN
                        THEN D.MgrSSN

                    WHEN I.SSN = D.MgrSSN AND I.DNo <> 1
                        THEN (SELECT MgrSSN FROM Department WHERE DNumber = 1)

                    ELSE NULL
                END
            FROM Inserted I
            JOIN Department D ON I.DNo = D.DNumber
            WHERE I.SSN = Employee.SSN
        )
        WHERE SSN IN (SELECT SSN FROM Inserted);

    END

END;
GO


/* =========================================================
   GHI CHÚ QUAN TRỌNG

   1. Hai trigger này TỰ BẢO VỆ khỏi đệ quy vô hạn: câu UPDATE
      bên trong mỗi trigger chỉ đụng vào cột SuperSSN, không
      đụng vào MgrSSN hay DNo, nên khi trigger kia bị kích hoạt
      lại (do SQL Server bật nested triggers mặc định), điều
      kiện IF UPDATE(MgrSSN) / IF UPDATE(DNo) sẽ là FALSE và
      trigger tự thoát ngay, không lặp lại.

   2. Trigger chỉ chạy khi có INSERT/UPDATE MỚI. Dữ liệu ban
      đầu trong đề bài đã khớp sẵn với công thức derive này
      (đã kiểm tra thủ công), nên không cần chạy UPDATE khởi
      tạo lại. Nếu dữ liệu ban đầu bị lệch, cần chạy 1 lần
      UPDATE thủ công để đồng bộ trước khi các trigger này
      có tác dụng bảo vệ về sau.

   3. Nếu trigger của Exercise 4 (composite FK giữa Department
      (MgrSSN, DNumber) và Employee (SSN, DNo)) đang được bật
      cùng lúc, một manager mới BẮT BUỘC phải thuộc đúng phòng
      ban đó trước khi được gán làm manager - cần lưu ý thứ tự
      thao tác khi test kết hợp nhiều trigger.
   ========================================================= */