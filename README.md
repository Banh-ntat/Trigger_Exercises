# SQL Server - Active Database Trigger Exercises

## 1. Giới thiệu

Repository này dùng để thực hiện bài tập **Active Database** trên SQL Server.

Bài tập gồm **16 Exercise**, yêu cầu sử dụng:

- CHECK Constraint
- Foreign Key
- Trigger
- INSERT / UPDATE / DELETE Trigger
- Derived Attribute
- Kiểm tra dữ liệu giữa nhiều bảng
- Kiểm tra quan hệ Supervisor
- Kiểm tra quan hệ Supervisor không bị cyclic

Database sử dụng schema gồm các bảng:

- Employee
- Department
- Project
- DeptLocations
- Dependent
- WorksOn

---

## 2. Cấu trúc thư mục

```text
Trigger_Exercises/
│
├── README.md
│
├── 00_CreateDatabase.sql
├── 01_CreateTables.sql
├── 02_InsertData.sql
├── 03_ResetDatabase.sql
│
├── Tests/
│   ├── TEST_EX01.sql
│   ├── TEST_EX02.sql
│   ├── TEST_EX03.sql
│   ├── TEST_EX04.sql
│   ├── TEST_EX05.sql
│   ├── TEST_EX06.sql
│   ├── TEST_EX07.sql
│   ├── TEST_EX08.sql
│   ├── TEST_EX09.sql
│   ├── TEST_EX10.sql
│   ├── TEST_EX11.sql
│   ├── TEST_EX12.sql
│   ├── TEST_EX13.sql
│   ├── TEST_EX14.sql
│   ├── TEST_EX15.sql
│   └── TEST_EX16.sql
└── Exercises/
    ├── EX01.sql
    ├── EX02.sql
    ├── EX03.sql
    ├── EX04.sql
    ├── EX05.sql
    ├── EX06.sql
    ├── EX07.sql
    ├── EX08.sql
    ├── EX09.sql
    ├── EX10.sql
    ├── EX11.sql
    ├── EX12.sql
    ├── EX13.sql
    ├── EX14.sql
    ├── EX15.sql
    └── EX16.sql
```
## 3. Yêu cầu

| Công cụ | Mục đích |
|---|---|
| SQL Server | Hệ quản trị CSDL |
| SSMS | Chạy SQL |
| Git | Quản lý source code |

## 4. Hướng dẫn chạy chương trình

### Bước 1: Clone project

```bash
git clone https://github.com/Banh-ntat/Trigger_Exercises.git
cd Trigger_Exercises
```

### Bước 2: Tạo Database

Mở `00_CreateDatabase.sql` bằng SSMS và nhấn **F5**.

### Bước 3: Tạo Tables

Mở `01_CreateTables.sql` → nhấn **F5**.

Database gồm 6 bảng:

```text
Employee
Department
Project
DeptLocations
Dependent
WorksOn
```

### Bước 4: Thêm dữ liệu

Mở `02_InsertData.sql` → nhấn **F5**.

Kiểm tra:

```sql
SELECT * FROM Employee;
SELECT * FROM Department;
SELECT * FROM Project;
SELECT * FROM DeptLocations;
SELECT * FROM Dependent;
SELECT * FROM WorksOn;
```

### Bước 5: Chạy bài Trigger

Chạy từng file theo thứ tự:

```text
EX01 → EX02 → EX03 → ... → EX16
```

Ví dụ:

```text
Exercises/EX01.sql
```

Mở file → nhấn **F5** → chạy phần **TEST** trong file.

> Không nên chạy tất cả bài cùng lúc. Chạy và kiểm tra từng bài.

## 5. Reset Database

Khi muốn làm lại Database:

```text
03_ResetDatabase.sql
        ↓
01_CreateTables.sql
        ↓
02_InsertData.sql
        ↓
EX01 → EX16
```

> ⚠️ `03_ResetDatabase.sql` sẽ xóa Database và toàn bộ dữ liệu hiện tại.

## 6. Git

Trước khi làm:

```bash
git pull origin main
```

Sau khi hoàn thành:

```bash
git add .
git commit -m "Add EX01 trigger"
git push origin main
```

## 7. Checklist

| Công việc | Trạng thái |
|---|:---:|
| Tạo Database | ⬜ |
| Tạo Tables | ⬜ |
| Insert Data | ⬜ |
| EX01 → EX06 | ⬜ |
| EX07 → EX11 | ⬜ |
| EX12 → EX16 | ⬜ |
| Test toàn bộ | ⬜ |
| Push GitHub | ⬜ |