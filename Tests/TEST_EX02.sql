USE Trigger_Exercise;
GO

-- SAI: gán supervisor (333445555, sinh 1945) cho 1 người sinh SAU 1945 nhưng ta set BDate GIA hon sep -> that ra can test nguoc:
-- Cach test ro nhat: update BDate cua 1 NV cho tre hon sep cua no
-- John Smith (123456789) co sep la Franklin Wong (333445555, sinh 08-12-1945)
-- Neu update BDate cua John thanh truoc nam 1945 (tuc GIA HON sep) -> VI PHAM

UPDATE Employee SET BDate = '1940-01-01' WHERE SSN = '123456789';
GO

-- DUNG: John van tre hon sep -> khong loi
UPDATE Employee SET BDate = '1970-01-01' WHERE SSN = '123456789';
GO

SELECT SSN, FName, LName, BDate, SuperSSN FROM Employee WHERE SSN = '123456789';
GO
