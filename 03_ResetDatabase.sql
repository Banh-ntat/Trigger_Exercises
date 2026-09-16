USE master;
GO

-- Xóa database cũ nếu đang tồn tại
IF DB_ID('Trigger_Exercise') IS NOT NULL
BEGIN
    ALTER DATABASE Trigger_Exercise
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE Trigger_Exercise;
END
GO