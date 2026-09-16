USE Trigger_Exercise;
GO

-- ==========================================
-- EXERCISE 5: Dia diem du an phai la 1 trong cac dia diem cua phong ban chu quan
-- Dung FK composite (DNumber, PLocation) -> (DNumber, DLocation) trong DeptLocations
-- ==========================================

ALTER TABLE Project
ADD CONSTRAINT FK_Project_DeptLocations
FOREIGN KEY (DNumber, PLocation)
REFERENCES DeptLocations (DNumber, DLocation);
GO
