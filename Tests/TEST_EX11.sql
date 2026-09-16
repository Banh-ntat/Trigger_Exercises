USE Trigger_Exercise;
GO

-- Du an 2 hien co John (7.5h < 10h). Them 2 nguoi nua lam duoi 10h -> tong 3 nguoi -> SAI o nguoi thu 3
INSERT INTO WorksOn (ESSN, PNo, hours) VALUES ('666884444', 2, 5.0); -- 2nd person <10h, OK
GO
INSERT INTO WorksOn (ESSN, PNo, hours) VALUES ('987654321', 2, 5.0); -- 3rd person <10h, phai bi chan
GO

SELECT PNo, COUNT(*) AS SoNguoiDuoi10h
FROM WorksOn WHERE hours < 10 AND PNo = 2 GROUP BY PNo;
GO
