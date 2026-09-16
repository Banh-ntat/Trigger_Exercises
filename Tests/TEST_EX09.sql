USE Trigger_Exercise;
GO

-- Ahmad Jabbar (987987987) hien lam 2 du an (10, 30).
-- Tao 2 du an moi cho phong 4 -> dia diem PHAI la 'Stafford' (dia diem hop le duy nhat cua phong 4
-- theo bang DeptLocations, vi constraint FK_Project_DeptLocations o EX05 van dang hoat dong)
INSERT INTO Project (PName, PNumber, PLocation, DNumber) VALUES ('P101',101,'Stafford',4);
INSERT INTO Project (PName, PNumber, PLocation, DNumber) VALUES ('P102',102,'Stafford',4);
GO

-- Dung 5.0h/du an de tranh vi pham cac rang buoc se tao o bai sau (EX10: 30-50h, EX12: <5h chi danh cho manager)
INSERT INTO WorksOn (ESSN, PNo, hours) VALUES ('987987987', 101, 5.0);  -- 3rd project
INSERT INTO WorksOn (ESSN, PNo, hours) VALUES ('987987987', 102, 5.0);  -- 4th project, OK (bien)
GO

-- Them du an thu 5 (dung lai du an 1 co san, dia diem da hop le) -> phai bi chan boi EX09
INSERT INTO WorksOn (ESSN, PNo, hours) VALUES ('987987987', 1, 5.0);
GO

SELECT ESSN, COUNT(*) AS SoDuAn FROM WorksOn WHERE ESSN='987987987' GROUP BY ESSN;
GO
