USE Trigger_Exercise;
GO

-- ==========================================
-- 1. TẠM TẮT CÁC FOREIGN KEY
-- ==========================================

ALTER TABLE Employee
NOCHECK CONSTRAINT FK_Employee_Department;

ALTER TABLE Employee
NOCHECK CONSTRAINT FK_Employee_Employee;

ALTER TABLE Department
NOCHECK CONSTRAINT FK_Department_Employee;
GO


-- ==========================================
-- 2. INSERT EMPLOYEE
-- ==========================================

INSERT INTO Employee
(
    FName,
    MInit,
    LName,
    SSN,
    BDate,
    Address,
    Sex,
    Salary,
    SuperSSN,
    DNo,
    HireDate
)
VALUES
('John','B','Smith','123456789','1955-05-09',
 '731 Fondren, Houston, TX','M',30000,'333445555',5,'1985-01-01'),

('Franklin','T','Wong','333445555','1945-12-08',
 '638 Voss, Houston, TX','M',40000,'888665555',5,'1982-01-01'),

('Alicia','J','Zelaya','999887777','1958-07-19',
 '3321 Castle, Spring, TX','F',25000,'987654321',4,'1985-01-01'),

('Jennifer','S','Wallace','987654321','1931-06-20',
 '291 Berry, Bellaire, TX','F',43000,'888665555',4,'1982-01-01'),

('Ramesh','K','Narayan','666884444','1952-09-15',
 '975 Fire Oak, Humble, TX','M',38000,'333445555',5,'1985-01-01'),

('Joyce','A','English','453453453','1962-07-31',
 '5631 Rice, Houston, TX','F',25000,'333445555',5,'1985-01-01'),

('Ahmad','V','Jabbar','987987987','1959-03-29',
 '980 Dallas, Houston, TX','M',25000,'987654321',4,'1985-01-01'),

('James','A','Borg','888665555','1927-11-10',
 '450 Stone, Houston, TX','M',55000,NULL,1,'1980-01-01');
GO


-- ==========================================
-- 3. INSERT DEPARTMENT
-- ==========================================

INSERT INTO Department
(
    DName,
    DNumber,
    MgrSSN,
    MgrStartDate,
    nbrEmployees
)
VALUES
('Research',5,'333445555','1978-05-22',4),

('Administration',4,'987654321','1985-01-01',3),

('Headquarters',1,'888665555','1971-06-19',1);
GO


-- ==========================================
-- 4. INSERT PROJECT
-- ==========================================

INSERT INTO Project
(
    PName,
    PNumber,
    PLocation,
    DNumber
)
VALUES
('ProductX',1,'Bellaire',5),
('ProductY',2,'Sugarland',5),
('ProductZ',3,'Houston',5),
('Computerization',10,'Stafford',4),
('Reorganization',20,'Houston',1),
('Newbenefits',30,'Stafford',4);
GO


-- ==========================================
-- 5. INSERT DEPTLOCATIONS
-- ==========================================

INSERT INTO DeptLocations
(
    DNumber,
    DLocation
)
VALUES
(1,'Houston'),
(4,'Stafford'),
(5,'Bellaire'),
(5,'Sugarland'),
(5,'Houston');
GO


-- ==========================================
-- 6. INSERT DEPENDENT
-- ==========================================

INSERT INTO Dependent
(
    ESSN,
    DependentName,
    Sex,
    BDate,
    Relationship
)
VALUES
('333445555','Alice','F','1976-04-05','Daughter'),
('333445555','Theodore','M','1973-10-25','Son'),
('333445555','Joy','F','1948-05-03','Spouse'),
('987654321','Abner','M','1932-02-29','Spouse'),
('123456789','Michael','M','1978-01-01','Son'),
('123456789','Alice','F','1978-12-31','Daughter'),
('123456789','Elizabeth','F','1957-05-05','Spouse');
GO


-- ==========================================
-- 7. INSERT WORKSON
-- ==========================================

INSERT INTO WorksOn
(
    ESSN,
    PNo,
    hours
)
VALUES
('123456789',1,32.5),
('123456789',2,7.5),

('333445555',1,10),
('333445555',2,10),
('333445555',3,20),

('453453453',1,20),
('453453453',2,20),

('666884444',3,40),

('888665555',20,30.0),

('987654321',10,5.0),
('987654321',20,15.0),
('987654321',30,20.0),

('987987987',10,35.0),
('987987987',30,5.0),

('999887777',10,10.0),
('999887777',30,30.0);
GO


-- ==========================================
-- 8. BẬT LẠI FOREIGN KEY
-- ==========================================

ALTER TABLE Employee
WITH CHECK CHECK CONSTRAINT FK_Employee_Department;

ALTER TABLE Employee
WITH CHECK CHECK CONSTRAINT FK_Employee_Employee;

ALTER TABLE Department
WITH CHECK CHECK CONSTRAINT FK_Department_Employee;
GO

