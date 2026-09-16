USE Trigger_Exercise;
GO

-- ==========================================
-- TEST EXERCISE 16
-- Kiem tra quan he Supervisor khong duoc cyclic
-- ==========================================


-- ==========================================
-- TEST 1: KIEM TRA QUAN HE SUPERVISOR HIEN TAI
-- ==========================================

PRINT '==========================================';
PRINT 'TEST 1: CURRENT SUPERVISOR RELATIONSHIP';
PRINT '==========================================';

SELECT
    SSN,
    FName,
    LName,
    SuperSSN
FROM Employee
ORDER BY SSN;
GO


-- ==========================================
-- TEST 2: TAO CHU TRINH
-- James Borg -> Franklin Wong
-- Franklin Wong -> James Borg
--
-- Franklin (333445555) dang duoc James
-- (888665555) giam sat.
--
-- Ta cho James tro thanh cap duoi cua Franklin.
-- Khi do:
--
-- James -> Franklin
-- Franklin -> James
--
-- => CHU TRINH
-- ==========================================

PRINT '==========================================';
PRINT 'TEST 2: CREATE CYCLIC SUPERVISION';
PRINT '==========================================';

PRINT 'Attempting to create cycle...';

UPDATE Employee
SET SuperSSN = '333445555'
WHERE SSN = '888665555';
GO


-- ==========================================
-- TEST 3: KIEM TRA SAU KHI ROLLBACK
--
-- Neu trigger hoat dong dung, UPDATE o TEST 2
-- bi rollback.
--
-- James Borg phai van co SuperSSN = NULL.
-- ==========================================

PRINT '==========================================';
PRINT 'TEST 3: VERIFY ROLLBACK';
PRINT '==========================================';

SELECT
    SSN,
    FName,
    LName,
    SuperSSN
FROM Employee
WHERE SSN IN
(
    '888665555',
    '333445555'
)
ORDER BY SSN;
GO


-- ==========================================
-- TEST 4: TAO THAY DOI HOP LE
--
-- Gan James Borg ve NULL.
-- Day khong tao chu trinh.
-- ==========================================

PRINT '==========================================';
PRINT 'TEST 4: REMOVE CYCLIC RELATIONSHIP';
PRINT '==========================================';

UPDATE Employee
SET SuperSSN = NULL
WHERE SSN = '888665555';
GO


-- ==========================================
-- TEST 5: KIEM TRA KET QUA CUOI CUNG
-- ==========================================

PRINT '==========================================';
PRINT 'TEST 5: FINAL SUPERVISOR RELATIONSHIP';
PRINT '==========================================';

SELECT
    SSN,
    FName,
    LName,
    SuperSSN
FROM Employee
WHERE SSN IN
(
    '888665555',
    '333445555'
)
ORDER BY SSN;
GO