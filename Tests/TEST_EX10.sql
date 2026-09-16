USE Trigger_Exercise;
GO

-- SAI: giam gio cua Ramesh (666884444, hien 40h tren du an 3) xuong con 5h -> tong < 30
UPDATE WorksOn SET hours = 5 WHERE ESSN = '666884444' AND PNo = 3;
GO

-- DUNG: dat lai 40h
UPDATE WorksOn SET hours = 40 WHERE ESSN = '666884444' AND PNo = 3;
GO

SELECT ESSN, SUM(hours) AS TongGio FROM WorksOn WHERE ESSN='666884444' GROUP BY ESSN;
GO
