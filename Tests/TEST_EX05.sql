USE Trigger_Exercise;
GO

-- SAI: du an moi cho phong 5 (Research) nhung dat o "Chicago" (khong co trong DeptLocations cua phong 5)
INSERT INTO Project (PName, PNumber, PLocation, DNumber)
VALUES ('TestProj', 99, 'Chicago', 5);
GO

-- DUNG: dat o "Houston" (co trong DeptLocations cua phong 5)
INSERT INTO Project (PName, PNumber, PLocation, DNumber)
VALUES ('TestProj', 99, 'Houston', 5);
GO

SELECT * FROM Project WHERE PNumber = 99;
GO
