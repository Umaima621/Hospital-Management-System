-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM - DDL SCRIPT
--  Compatible with: SQL Server / SSMS
--  Milestone 2
-- ============================================================

USE master;
GO

-- Create and use the hospital database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'HospitalDB')
    CREATE DATABASE HospitalDB;
GO

USE HospitalDB;
GO

-- ============================================================
--  DROP TABLES (reverse dependency order)
-- ============================================================
IF OBJECT_ID('PERFORMANCE_PROGRESS',  'U') IS NOT NULL DROP TABLE PERFORMANCE_PROGRESS;
IF OBJECT_ID('PERFORMANCE_EXPERIENCE','U') IS NOT NULL DROP TABLE PERFORMANCE_EXPERIENCE;
IF OBJECT_ID('TREATMENT_RECORD',      'U') IS NOT NULL DROP TABLE TREATMENT_RECORD;
IF OBJECT_ID('TREATMENT',             'U') IS NOT NULL DROP TABLE TREATMENT;
IF OBJECT_ID('COMPLAINT',             'U') IS NOT NULL DROP TABLE COMPLAINT;
IF OBJECT_ID('PATIENT',               'U') IS NOT NULL DROP TABLE PATIENT;
IF OBJECT_ID('DOCTOR',                'U') IS NOT NULL DROP TABLE DOCTOR;
IF OBJECT_ID('CONSULTANT',            'U') IS NOT NULL DROP TABLE CONSULTANT;
IF OBJECT_ID('CARE_UNIT',             'U') IS NOT NULL DROP TABLE CARE_UNIT;
IF OBJECT_ID('NURSE',                 'U') IS NOT NULL DROP TABLE NURSE;
IF OBJECT_ID('WARD',                  'U') IS NOT NULL DROP TABLE WARD;
IF OBJECT_ID('SPECIALTY',             'U') IS NOT NULL DROP TABLE SPECIALTY;
GO

-- ============================================================
--  TABLE: SPECIALTY
-- ============================================================
CREATE TABLE SPECIALTY (
    specialty_id    INT             PRIMARY KEY,
    specialty_name  VARCHAR(100)    NOT NULL,
    description     VARCHAR(255)
);
GO

-- ============================================================
--  TABLE: WARD
--  day_sister_id / night_sister_id added as FK after NURSE
-- ============================================================
CREATE TABLE WARD (
    ward_id         INT             PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    specialty_id    INT             NOT NULL,
    day_sister_id   INT             NULL,
    night_sister_id INT             NULL,
    CONSTRAINT fk_ward_specialty
        FOREIGN KEY (specialty_id) REFERENCES SPECIALTY(specialty_id)
);
GO

-- ============================================================
--  TABLE: NURSE
--  care_unit_id FK added after CARE_UNIT is created
-- ============================================================
CREATE TABLE NURSE (
    nurse_id        INT             PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    position        VARCHAR(100)    NOT NULL,
    ward_id         INT             NULL,
    care_unit_id    INT             NULL,
    CONSTRAINT fk_nurse_ward
        FOREIGN KEY (ward_id) REFERENCES WARD(ward_id)
);
GO

-- Now add the WARD -> NURSE foreign keys
ALTER TABLE WARD
    ADD CONSTRAINT fk_ward_day_sister
        FOREIGN KEY (day_sister_id) REFERENCES NURSE(nurse_id);

ALTER TABLE WARD
    ADD CONSTRAINT fk_ward_night_sister
        FOREIGN KEY (night_sister_id) REFERENCES NURSE(nurse_id);
GO

-- ============================================================
--  TABLE: CARE_UNIT
-- ============================================================
CREATE TABLE CARE_UNIT (
    unit_no         INT             PRIMARY KEY,
    ward_id         INT             NOT NULL,
    charge_nurse_id INT             NULL,
    CONSTRAINT fk_careunit_ward
        FOREIGN KEY (ward_id)         REFERENCES WARD(ward_id),
    CONSTRAINT fk_careunit_nurse
        FOREIGN KEY (charge_nurse_id) REFERENCES NURSE(nurse_id)
);
GO

-- Now add NURSE -> CARE_UNIT FK
ALTER TABLE NURSE
    ADD CONSTRAINT fk_nurse_careunit
        FOREIGN KEY (care_unit_id) REFERENCES CARE_UNIT(unit_no);
GO

-- ============================================================
--  TABLE: CONSULTANT
-- ============================================================
CREATE TABLE CONSULTANT (
    staff_no        INT             PRIMARY KEY,
    specialty_id    INT             NOT NULL,
    CONSTRAINT fk_consultant_specialty
        FOREIGN KEY (specialty_id) REFERENCES SPECIALTY(specialty_id)
);
GO

-- ============================================================
--  TABLE: DOCTOR
-- ============================================================
CREATE TABLE DOCTOR (
    staff_no            INT             PRIMARY KEY,
    name                VARCHAR(100)    NOT NULL,
    position            VARCHAR(100)    NOT NULL,
    consultant_id       INT             NULL,
    date_joined_team    DATE            NULL,
    CONSTRAINT fk_doctor_consultant
        FOREIGN KEY (consultant_id) REFERENCES CONSULTANT(staff_no)
);
GO

-- ============================================================
--  TABLE: PATIENT
-- ============================================================
CREATE TABLE PATIENT (
    patient_no      INT             PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    dob             DATE            NOT NULL,
    date_admitted   DATE            NOT NULL,
    bed_no          INT             NULL,
    overseas        BIT             DEFAULT 0,
    ward_id         INT             NULL,
    care_unit_id    INT             NULL,
    doctor_no       INT             NULL,
    CONSTRAINT fk_patient_ward
        FOREIGN KEY (ward_id)       REFERENCES WARD(ward_id),
    CONSTRAINT fk_patient_careunit
        FOREIGN KEY (care_unit_id)  REFERENCES CARE_UNIT(unit_no),
    CONSTRAINT fk_patient_doctor
        FOREIGN KEY (doctor_no)     REFERENCES DOCTOR(staff_no)
);
GO

-- ============================================================
--  TABLE: COMPLAINT
-- ============================================================
CREATE TABLE COMPLAINT (
    complaint_code  INT             PRIMARY KEY,
    description     VARCHAR(255)    NOT NULL
);
GO

-- ============================================================
--  TABLE: TREATMENT
-- ============================================================
CREATE TABLE TREATMENT (
    treatment_code  INT             PRIMARY KEY,
    description     VARCHAR(255)    NOT NULL
);
GO

-- ============================================================
--  TABLE: TREATMENT_RECORD
-- ============================================================
CREATE TABLE TREATMENT_RECORD (
    record_id       INT             PRIMARY KEY,
    patient_no      INT             NOT NULL,
    complaint_code  INT             NOT NULL,
    treatment_code  INT             NOT NULL,
    doctor_no       INT             NOT NULL,
    date_started    DATE            NOT NULL,
    date_ended      DATE            NULL,
    CONSTRAINT fk_tr_patient
        FOREIGN KEY (patient_no)    REFERENCES PATIENT(patient_no),
    CONSTRAINT fk_tr_complaint
        FOREIGN KEY (complaint_code)REFERENCES COMPLAINT(complaint_code),
    CONSTRAINT fk_tr_treatment
        FOREIGN KEY (treatment_code)REFERENCES TREATMENT(treatment_code),
    CONSTRAINT fk_tr_doctor
        FOREIGN KEY (doctor_no)     REFERENCES DOCTOR(staff_no)
);
GO

-- ============================================================
--  TABLE: PERFORMANCE_EXPERIENCE
-- ============================================================
CREATE TABLE PERFORMANCE_EXPERIENCE (
    record_id       INT             PRIMARY KEY,
    doctor_id       INT             NOT NULL,
    position        VARCHAR(100)    NOT NULL,
    from_date       DATE            NOT NULL,
    to_date         DATE            NULL,
    establishment   VARCHAR(150)    NOT NULL,
    CONSTRAINT fk_pe_doctor
        FOREIGN KEY (doctor_id) REFERENCES DOCTOR(staff_no)
);
GO

-- ============================================================
--  TABLE: PERFORMANCE_PROGRESS
-- ============================================================
CREATE TABLE PERFORMANCE_PROGRESS (
    progress_id     INT             PRIMARY KEY,
    consultant_id   INT             NOT NULL,
    doctor_id       INT             NOT NULL,
    progress_date   DATE            NOT NULL,
    grade           VARCHAR(10)     NOT NULL,
    CONSTRAINT fk_pp_consultant
        FOREIGN KEY (consultant_id) REFERENCES CONSULTANT(staff_no),
    CONSTRAINT fk_pp_doctor
        FOREIGN KEY (doctor_id)     REFERENCES DOCTOR(staff_no)
);
GO

-- ============================================================
--  END OF DDL SCRIPT
-- ============================================================


-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM - DATA INSERTION SCRIPT
--  Compatible with: SQL Server / SSMS
--  Milestone 2
-- ============================================================

USE HospitalDB;
GO

-- ============================================================
--  SPECIALTY (10 records)
-- ============================================================
INSERT INTO SPECIALTY (specialty_id, specialty_name, description) VALUES
(1,  'Cardiology',       'Diagnosis and treatment of heart disorders'),
(2,  'Neurology',        'Disorders of the nervous system'),
(3,  'Orthopedics',      'Musculoskeletal system conditions'),
(4,  'Pediatrics',       'Medical care for infants and children'),
(5,  'Oncology',         'Cancer diagnosis and treatment'),
(6,  'Dermatology',      'Skin, hair, and nail disorders'),
(7,  'Gastroenterology', 'Digestive system diseases'),
(8,  'Pulmonology',      'Lung and respiratory diseases'),
(9,  'Nephrology',       'Kidney diseases and renal disorders'),
(10, 'General Surgery',  'Surgical procedures across multiple systems');
GO

-- ============================================================
--  WARD (10 records) — sisters set NULL initially, updated after NURSE
-- ============================================================
INSERT INTO WARD (ward_id, name, specialty_id, day_sister_id, night_sister_id) VALUES
(1,  'Cardiac Ward',      1, NULL, NULL),
(2,  'Neuro Ward',        2, NULL, NULL),
(3,  'Ortho Ward',        3, NULL, NULL),
(4,  'Pediatric Ward',    4, NULL, NULL),
(5,  'Oncology Ward',     5, NULL, NULL),
(6,  'Skin & Care Ward',  6, NULL, NULL),
(7,  'Gastro Ward',       7, NULL, NULL),
(8,  'Respiratory Ward',  8, NULL, NULL),
(9,  'Renal Ward',        9, NULL, NULL),
(10, 'Surgical Ward',    10, NULL, NULL);
GO

-- ============================================================
--  NURSE (15 records) — care_unit_id NULL initially
-- ============================================================
INSERT INTO NURSE (nurse_id, name, position, ward_id, care_unit_id) VALUES
(1,  'Sara Ahmed',       'Senior Sister', 1,  NULL),
(2,  'Mehwish Raza',     'Night Sister',  1,  NULL),
(3,  'Nadia Qureshi',    'Senior Sister', 2,  NULL),
(4,  'Saba Tariq',       'Night Sister',  2,  NULL),
(5,  'Farah Malik',      'Senior Sister', 3,  NULL),
(6,  'Hina Iqbal',       'Night Sister',  3,  NULL),
(7,  'Zara Hussain',     'Senior Sister', 4,  NULL),
(8,  'Amna Baig',        'Night Sister',  4,  NULL),
(9,  'Layla Khan',       'Senior Sister', 5,  NULL),
(10, 'Rabia Noor',       'Night Sister',  5,  NULL),
(11, 'Ayesha Siddiqui',  'Staff Nurse',   6,  NULL),
(12, 'Maria Farooq',     'Staff Nurse',   7,  NULL),
(13, 'Uzma Shafiq',      'Staff Nurse',   8,  NULL),
(14, 'Samina Butt',      'Charge Nurse',  9,  NULL),
(15, 'Fozia Anwar',      'Charge Nurse',  10, NULL);
GO

-- Update WARD sisters now that nurses exist
UPDATE WARD SET day_sister_id = 1,  night_sister_id = 2  WHERE ward_id = 1;
UPDATE WARD SET day_sister_id = 3,  night_sister_id = 4  WHERE ward_id = 2;
UPDATE WARD SET day_sister_id = 5,  night_sister_id = 6  WHERE ward_id = 3;
UPDATE WARD SET day_sister_id = 7,  night_sister_id = 8  WHERE ward_id = 4;
UPDATE WARD SET day_sister_id = 9,  night_sister_id = 10 WHERE ward_id = 5;
UPDATE WARD SET day_sister_id = 11, night_sister_id = 11 WHERE ward_id = 6;
UPDATE WARD SET day_sister_id = 12, night_sister_id = 12 WHERE ward_id = 7;
UPDATE WARD SET day_sister_id = 13, night_sister_id = 13 WHERE ward_id = 8;
UPDATE WARD SET day_sister_id = 14, night_sister_id = 14 WHERE ward_id = 9;
UPDATE WARD SET day_sister_id = 15, night_sister_id = 15 WHERE ward_id = 10;
GO

-- ============================================================
--  CARE_UNIT (10 records)
-- ============================================================
INSERT INTO CARE_UNIT (unit_no, ward_id, charge_nurse_id) VALUES
(101, 1,  1),
(102, 2,  3),
(103, 3,  5),
(104, 4,  7),
(105, 5,  9),
(106, 6,  11),
(107, 7,  12),
(108, 8,  13),
(109, 9,  14),
(110, 10, 15);
GO

-- Update nurses with their care_unit assignments
UPDATE NURSE SET care_unit_id = 101 WHERE nurse_id IN (1, 2);
UPDATE NURSE SET care_unit_id = 102 WHERE nurse_id IN (3, 4);
UPDATE NURSE SET care_unit_id = 103 WHERE nurse_id IN (5, 6);
UPDATE NURSE SET care_unit_id = 104 WHERE nurse_id IN (7, 8);
UPDATE NURSE SET care_unit_id = 105 WHERE nurse_id IN (9, 10);
UPDATE NURSE SET care_unit_id = 106 WHERE nurse_id = 11;
UPDATE NURSE SET care_unit_id = 107 WHERE nurse_id = 12;
UPDATE NURSE SET care_unit_id = 108 WHERE nurse_id = 13;
UPDATE NURSE SET care_unit_id = 109 WHERE nurse_id = 14;
UPDATE NURSE SET care_unit_id = 110 WHERE nurse_id = 15;
GO

-- ============================================================
--  CONSULTANT (10 records)
-- ============================================================
INSERT INTO CONSULTANT (staff_no, specialty_id) VALUES
(201, 1),
(202, 2),
(203, 3),
(204, 4),
(205, 5),
(206, 6),
(207, 7),
(208, 8),
(209, 9),
(210, 10);
GO

-- ============================================================
--  DOCTOR (10 records)
-- ============================================================
INSERT INTO DOCTOR (staff_no, name, position, consultant_id, date_joined_team) VALUES
(301, 'Dr. Imran Sheikh',   'Senior Registrar', 201, '2018-03-15'),
(302, 'Dr. Bilal Chaudhry', 'Registrar',        201, '2020-07-01'),
(303, 'Dr. Hamza Nawaz',    'Senior Registrar', 202, '2017-11-20'),
(304, 'Dr. Tariq Mehmood',  'Registrar',        203, '2021-01-10'),
(305, 'Dr. Aamir Sultan',   'Senior Registrar', 204, '2019-06-05'),
(306, 'Dr. Kashif Javed',   'Registrar',        205, '2022-03-22'),
(307, 'Dr. Usman Ghani',    'Senior Registrar', 206, '2016-09-14'),
(308, 'Dr. Fahad Iqbal',    'Registrar',        207, '2023-02-28'),
(309, 'Dr. Zeeshan Alam',   'Senior Registrar', 208, '2018-08-30'),
(310, 'Dr. Adnan Rauf',     'Registrar',        209, '2020-12-01');
GO

-- ============================================================
--  COMPLAINT (15 records)
-- ============================================================
INSERT INTO COMPLAINT (complaint_code, description) VALUES
(401, 'Chest pain and shortness of breath'),
(402, 'Severe headache and dizziness'),
(403, 'Fractured femur'),
(404, 'High fever and dehydration'),
(405, 'Persistent cough and blood in sputum'),
(406, 'Chronic skin rash and itching'),
(407, 'Abdominal pain and vomiting'),
(408, 'Difficulty breathing and wheezing'),
(409, 'Swollen ankles and reduced urine output'),
(410, 'Post-operative wound infection'),
(411, 'Irregular heartbeat (arrhythmia)'),
(412, 'Seizures and loss of consciousness'),
(413, 'Joint pain and stiffness'),
(414, 'Nausea and jaundice'),
(415, 'Kidney stone and flank pain');
GO

-- ============================================================
--  TREATMENT (15 records)
-- ============================================================
INSERT INTO TREATMENT (treatment_code, description) VALUES
(501, 'Angioplasty and stent placement'),
(502, 'MRI scan and neurological therapy'),
(503, 'Open reduction and internal fixation (ORIF)'),
(504, 'IV fluid therapy and antipyretics'),
(505, 'Chemotherapy cycle administration'),
(506, 'Topical corticosteroid therapy'),
(507, 'Endoscopy and antacid treatment'),
(508, 'Bronchodilator and oxygen therapy'),
(509, 'Dialysis and fluid management'),
(510, 'Surgical debridement and antibiotics'),
(511, 'Cardiac monitoring and beta-blockers'),
(512, 'Anti-epileptic drug administration'),
(513, 'Physiotherapy and pain management'),
(514, 'Liver function monitoring and diuretics'),
(515, 'Lithotripsy (ESWL) procedure');
GO

-- ============================================================
--  PATIENT (30 records)
-- ============================================================
INSERT INTO PATIENT (patient_no, name, dob, date_admitted, bed_no, overseas, ward_id, care_unit_id, doctor_no) VALUES
(1001, 'Ali Hassan',       '1980-04-12', '2024-01-05',  1, 0, 1,  101, 301),
(1002, 'Fatima Zahra',     '1995-09-23', '2024-01-08',  2, 0, 1,  101, 301),
(1003, 'Ahmed Khan',       '1970-11-30', '2024-01-10',  3, 0, 2,  102, 303),
(1004, 'Zainab Mirza',     '1988-06-15', '2024-01-12',  4, 0, 2,  102, 303),
(1005, 'Omar Farooq',      '1975-03-22', '2024-01-15',  5, 0, 3,  103, 304),
(1006, 'Sana Akhtar',      '2002-08-01', '2024-01-18',  6, 0, 3,  103, 304),
(1007, 'Tariq Aziz',       '1990-12-09', '2024-01-20',  7, 0, 4,  104, 305),
(1008, 'Hira Baig',        '2010-05-17', '2024-01-22',  8, 0, 4,  104, 305),
(1009, 'Rashid Nawaz',     '1965-07-04', '2024-01-25',  9, 0, 5,  105, 306),
(1010, 'Maryam Saeed',     '1983-02-28', '2024-01-28', 10, 0, 5,  105, 306),
(1011, 'Khalid Mahmood',   '1978-10-13', '2024-02-02', 11, 0, 6,  106, 307),
(1012, 'Nadia Rauf',       '1993-04-05', '2024-02-05', 12, 0, 6,  106, 307),
(1013, 'Shahid Islam',     '1969-08-19', '2024-02-08', 13, 0, 7,  107, 308),
(1014, 'Ayesha Khalil',    '1985-11-11', '2024-02-10', 14, 0, 7,  107, 308),
(1015, 'Imran Zahid',      '1972-01-25', '2024-02-12', 15, 0, 8,  108, 309),
(1016, 'Sadia Rehman',     '1998-06-30', '2024-02-15', 16, 0, 8,  108, 309),
(1017, 'Nasir Ali',        '1960-09-07', '2024-02-18', 17, 0, 9,  109, 310),
(1018, 'Rukhsana Bano',    '1987-03-14', '2024-02-20', 18, 0, 9,  109, 310),
(1019, 'Waseem Akram',     '1976-12-03', '2024-02-22', 19, 0, 10, 110, 301),
(1020, 'Samia Pervez',     '1991-07-21', '2024-02-25', 20, 0, 10, 110, 302),
(1021, 'David Brown',      '1982-05-16', '2024-03-01', 21, 1, 1,  101, 302),
(1022, 'Emily Watson',     '1999-02-11', '2024-03-03', 22, 1, 2,  102, 303),
(1023, 'John Miller',      '1955-08-27', '2024-03-05', 23, 1, 3,  103, 304),
(1024, 'Sarah Connor',     '1974-11-08', '2024-03-08', 24, 1, 4,  104, 305),
(1025, 'Rahim Uddin',      '2005-04-19', '2024-03-10', 25, 0, 4,  104, 305),
(1026, 'Bushra Naz',       '1966-09-02', '2024-03-12', 26, 0, 5,  105, 306),
(1027, 'Javed Iqbal',      '1980-01-15', '2024-03-15', 27, 0, 6,  106, 307),
(1028, 'Fauzia Hamid',     '1994-06-24', '2024-03-18', 28, 0, 7,  107, 308),
(1029, 'Zia ur Rehman',    '1971-10-30', '2024-03-20', 29, 0, 8,  108, 309),
(1030, 'Amna Farhat',      '1989-03-07', '2024-03-22', 30, 0, 9,  109, 310);
GO

-- ============================================================
--  TREATMENT_RECORD (20 records)
-- ============================================================
INSERT INTO TREATMENT_RECORD (record_id, patient_no, complaint_code, treatment_code, doctor_no, date_started, date_ended) VALUES
(601, 1001, 401, 501, 301, '2024-01-05', '2024-01-20'),
(602, 1002, 411, 511, 301, '2024-01-08', '2024-01-25'),
(603, 1003, 402, 502, 303, '2024-01-10', '2024-01-30'),
(604, 1004, 412, 512, 303, '2024-01-12', NULL),
(605, 1005, 403, 503, 304, '2024-01-15', '2024-02-10'),
(606, 1006, 413, 513, 304, '2024-01-18', '2024-02-05'),
(607, 1007, 404, 504, 305, '2024-01-20', '2024-01-28'),
(608, 1008, 404, 504, 305, '2024-01-22', '2024-01-29'),
(609, 1009, 405, 505, 306, '2024-01-25', NULL),
(610, 1010, 405, 505, 306, '2024-01-28', NULL),
(611, 1011, 406, 506, 307, '2024-02-02', '2024-02-20'),
(612, 1012, 406, 506, 307, '2024-02-05', '2024-02-22'),
(613, 1013, 407, 507, 308, '2024-02-08', '2024-02-18'),
(614, 1014, 414, 514, 308, '2024-02-10', '2024-03-01'),
(615, 1015, 408, 508, 309, '2024-02-12', '2024-02-28'),
(616, 1016, 408, 508, 309, '2024-02-15', '2024-03-05'),
(617, 1017, 409, 509, 310, '2024-02-18', NULL),
(618, 1018, 415, 515, 310, '2024-02-20', '2024-03-10'),
(619, 1019, 410, 510, 301, '2024-02-22', '2024-03-08'),
(620, 1021, 401, 501, 302, '2024-03-01', '2024-03-15');
GO

-- ============================================================
--  PERFORMANCE_EXPERIENCE (15 records)
-- ============================================================
INSERT INTO PERFORMANCE_EXPERIENCE (record_id, doctor_id, position, from_date, to_date, establishment) VALUES
(701, 301, 'House Officer',          '2012-08-01', '2014-07-31', 'Jinnah Hospital Lahore'),
(702, 301, 'Medical Officer',        '2014-08-01', '2018-03-14', 'Services Hospital Lahore'),
(703, 302, 'House Officer',          '2016-01-01', '2018-01-01', 'Holy Family Hospital Rawalpindi'),
(704, 302, 'Medical Officer',        '2018-01-02', '2020-06-30', 'Pakistan Institute of Medical Sciences'),
(705, 303, 'House Officer',          '2011-06-01', '2013-05-31', 'Shifa International Hospital'),
(706, 303, 'Senior Medical Officer', '2013-06-01', '2017-11-19', 'Aga Khan University Hospital'),
(707, 304, 'House Officer',          '2015-03-01', '2017-03-01', 'Liaquat National Hospital'),
(708, 304, 'Medical Officer',        '2017-03-02', '2021-01-09', 'Combined Military Hospital Lahore'),
(709, 305, 'House Officer',          '2013-01-01', '2015-01-01', 'Children Hospital Lahore'),
(710, 305, 'Medical Officer',        '2015-01-02', '2019-06-04', 'National Institute of Child Health'),
(711, 306, 'House Officer',          '2018-01-01', '2020-01-01', 'Shaukat Khanum Memorial Hospital'),
(712, 307, 'House Officer',          '2010-06-01', '2012-06-01', 'Dow University Hospital'),
(713, 307, 'Medical Officer',        '2012-06-02', '2016-09-13', 'Civil Hospital Karachi'),
(714, 308, 'House Officer',          '2019-01-01', '2021-01-01', 'Mayo Hospital Lahore'),
(715, 309, 'Medical Officer',        '2013-01-01', '2018-08-29', 'Patel Hospital Karachi');
GO

-- ============================================================
--  PERFORMANCE_PROGRESS (15 records)
-- ============================================================
INSERT INTO PERFORMANCE_PROGRESS (progress_id, consultant_id, doctor_id, progress_date, grade) VALUES
(801, 201, 301, '2019-06-30', 'A'),
(802, 201, 301, '2020-06-30', 'A+'),
(803, 201, 302, '2021-06-30', 'B+'),
(804, 201, 302, '2022-06-30', 'A'),
(805, 202, 303, '2018-12-31', 'A+'),
(806, 202, 303, '2020-12-31', 'A+'),
(807, 203, 304, '2022-06-30', 'B'),
(808, 203, 304, '2023-06-30', 'B+'),
(809, 204, 305, '2020-06-30', 'A'),
(810, 204, 305, '2021-06-30', 'A'),
(811, 205, 306, '2023-03-31', 'B+'),
(812, 206, 307, '2017-09-30', 'A'),
(813, 206, 307, '2019-09-30', 'A+'),
(814, 207, 308, '2024-02-28', 'B'),
(815, 208, 309, '2019-08-31', 'A');
GO

-- ============================================================
--  END OF INSERTION SCRIPT
-- ============================================================


USE HospitalDB;

-- 1. Specialty
SELECT * FROM SPECIALTY;

-- 2. Ward
SELECT * FROM WARD;

-- 3. Nurse
SELECT * FROM NURSE;

-- 4. Care Unit
SELECT * FROM CARE_UNIT;

-- 5. Consultant
SELECT * FROM CONSULTANT;

-- 6. Doctor
SELECT * FROM DOCTOR;

-- 7. Patient
SELECT * FROM PATIENT;

-- 8. Complaint
SELECT * FROM COMPLAINT;

-- 9. Treatment
SELECT * FROM TREATMENT;

-- 10. Treatment Record
SELECT * FROM TREATMENT_RECORD;

-- 11. Performance Experience
SELECT * FROM PERFORMANCE_EXPERIENCE;

-- 12. Performance Progress
SELECT * FROM PERFORMANCE_PROGRESS;
