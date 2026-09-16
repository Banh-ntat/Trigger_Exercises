USE Trigger_Exercise;
GO

-- ==========================================
-- 1. TẠO BẢNG EMPLOYEE
-- ==========================================

CREATE TABLE Employee
(
    FName varchar(15) NOT NULL,
    MInit char(1),
    LName varchar(15) NOT NULL,
    SSN char(9) NOT NULL,
    BDate smalldatetime NULL,
    Address varchar(30),
    Sex char(1),
    Salary decimal(18,2),
    SuperSSN char(9),
    DNo int NOT NULL,
    HireDate smalldatetime NULL,

    CONSTRAINT PK_Employee
        PRIMARY KEY (SSN),

    CONSTRAINT FK_Employee_Employee
        FOREIGN KEY (SuperSSN)
        REFERENCES Employee(SSN)
);
GO


-- ==========================================
-- 2. TẠO BẢNG DEPARTMENT
-- ==========================================

CREATE TABLE Department
(
    DName varchar(15) NOT NULL,
    DNumber int NOT NULL,
    MgrSSN char(9) NOT NULL,
    MgrStartDate smalldatetime,
    nbrEmployees int,

    CONSTRAINT PK_Department
        PRIMARY KEY (DNumber),

    CONSTRAINT FK_Department_Employee
        FOREIGN KEY (MgrSSN)
        REFERENCES Employee(SSN)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO


-- ==========================================
-- 3. KHÓA NGOẠI EMPLOYEE -> DEPARTMENT
-- ==========================================

ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Department
FOREIGN KEY (DNo)
REFERENCES Department(DNumber);
GO


-- ==========================================
-- 4. TẠO BẢNG PROJECT
-- ==========================================

CREATE TABLE Project
(
    PName varchar(15) NOT NULL,
    PNumber int NOT NULL,
    PLocation varchar(15),
    DNumber int NOT NULL,

    CONSTRAINT PK_Project
        PRIMARY KEY (PNumber),

    CONSTRAINT FK_Project_Department
        FOREIGN KEY (DNumber)
        REFERENCES Department(DNumber)
);
GO


-- ==========================================
-- 5. TẠO BẢNG DEPTLOCATIONS
-- ==========================================

CREATE TABLE DeptLocations
(
    DNumber int NOT NULL,
    DLocation varchar(15) NOT NULL,

    CONSTRAINT PK_Dept_Locations
        PRIMARY KEY (DNumber, DLocation),

    CONSTRAINT FK_Dept_Locations_Department
        FOREIGN KEY (DNumber)
        REFERENCES Department(DNumber)
);
GO


-- ==========================================
-- 6. TẠO BẢNG DEPENDENT
-- ==========================================

CREATE TABLE Dependent
(
    ESSN char(9) NOT NULL,
    DependentName varchar(15) NOT NULL,
    Sex char(1),
    BDate smalldatetime NULL,
    Relationship varchar(8),

    CONSTRAINT PK_Dependent
        PRIMARY KEY (ESSN, DependentName),

    CONSTRAINT FK_Dependent_Employee
        FOREIGN KEY (ESSN)
        REFERENCES Employee(SSN)
);
GO


-- ==========================================
-- 7. TẠO BẢNG WORKSON
-- ==========================================

CREATE TABLE WorksOn
(
    ESSN char(9) NOT NULL,
    PNo int NOT NULL,
    hours decimal(18,1) NOT NULL,

    CONSTRAINT PK_WorksOn
        PRIMARY KEY (ESSN, PNo),

    CONSTRAINT FK_WorksOn_Employee
        FOREIGN KEY (ESSN)
        REFERENCES Employee(SSN),

    CONSTRAINT FK_WorksOn_Project
        FOREIGN KEY (PNo)
        REFERENCES Project(PNumber)
);
GO

