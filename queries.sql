-- ============================================================
--  IVOR PAINE MEMORIAL HOSPITAL
--  CS204 Database Systems -- Milestone 3
--  12 Report Queries
--  Compatible with: SQL Server / SSMS
-- ============================================================

USE HospitalDB;
GO

-- ============================================================
-- QUERY 1: List of consultants and the doctors in their team
-- ============================================================
SELECT
    C.staff_no          AS Consultant_ID,
    S.specialty_name    AS Specialty,
    D.staff_no          AS Doctor_ID,
    D.name              AS Doctor_Name,
    D.position          AS Doctor_Position,
    D.date_joined_team  AS Date_Joined_Team
FROM CONSULTANT C
JOIN SPECIALTY  S ON S.specialty_id  = C.specialty_id
JOIN DOCTOR     D ON D.consultant_id = C.staff_no
ORDER BY C.staff_no, D.name;
GO

-- ============================================================
-- QUERY 2: List of wards with sisters, care units and staff nurses in charge
-- ============================================================
SELECT
    W.name              AS Ward_Name,
    S.specialty_name    AS Specialty,
    DS.name             AS Day_Sister,
    NS.name             AS Night_Sister,
    CU.unit_no          AS Care_Unit_No,
    CN.name             AS Charge_Nurse
FROM WARD       W
JOIN SPECIALTY  S  ON S.specialty_id    = W.specialty_id
LEFT JOIN NURSE DS ON DS.nurse_id       = W.day_sister_id
LEFT JOIN NURSE NS ON NS.nurse_id       = W.night_sister_id
LEFT JOIN CARE_UNIT CU ON CU.ward_id    = W.ward_id
LEFT JOIN NURSE CN ON CN.nurse_id       = CU.charge_nurse_id
ORDER BY W.ward_id, CU.unit_no;
GO

-- ============================================================
-- QUERY 3: List of patients and their complaints, treatments and dates of treatment
-- ============================================================
SELECT
    P.patient_no,
    P.name              AS Patient_Name,
    C.description       AS Complaint,
    T.description       AS Treatment,
    D.name              AS Treating_Doctor,
    TR.date_started     AS Date_Started,
    TR.date_ended       AS Date_Ended
FROM TREATMENT_RECORD TR
JOIN PATIENT    P ON P.patient_no      = TR.patient_no
JOIN COMPLAINT  C ON C.complaint_code  = TR.complaint_code
JOIN TREATMENT  T ON T.treatment_code  = TR.treatment_code
JOIN DOCTOR     D ON D.staff_no        = TR.doctor_no
ORDER BY P.patient_no, TR.date_started;
GO

-- ============================================================
-- QUERY 4: List of junior housemen and their patients and the staff nurse for the care-unit
-- ============================================================
SELECT
    D.staff_no          AS Doctor_ID,
    D.name              AS Junior_Houseman,
    D.position          AS Position,
    P.patient_no        AS Patient_No,
    P.name              AS Patient_Name,
    CU.unit_no          AS Care_Unit,
    N.name              AS Staff_Nurse
FROM DOCTOR         D
JOIN PATIENT        P  ON P.doctor_no       = D.staff_no
JOIN CARE_UNIT      CU ON CU.unit_no        = P.care_unit_id
JOIN NURSE          N  ON N.nurse_id        = CU.charge_nurse_id
WHERE D.position = 'Junior Houseman'
ORDER BY D.staff_no, P.patient_no;
GO

-- ============================================================
-- QUERY 5: List of consultants with a unique specialty
--          (specialty held by only one consultant in the hospital)
-- ============================================================
SELECT
    C.staff_no          AS Consultant_ID,
    S.specialty_name    AS Specialty,
    S.description       AS Specialty_Description
FROM CONSULTANT C
JOIN SPECIALTY  S ON S.specialty_id = C.specialty_id
WHERE C.specialty_id IN (
    SELECT specialty_id
    FROM   CONSULTANT
    GROUP  BY specialty_id
    HAVING COUNT(*) = 1
)
ORDER BY S.specialty_name;
GO

-- ============================================================
-- QUERY 6: List of complaints, treatments given for that complaint
--          and experience history of the doctor giving that treatment
-- ============================================================
SELECT
    C.complaint_code    AS Complaint_Code,
    C.description       AS Complaint,
    T.description       AS Treatment,
    D.name              AS Doctor_Name,
    D.position          AS Current_Position,
    PE.position         AS Past_Position,
    PE.establishment    AS Establishment,
    PE.from_date        AS Experience_From,
    PE.to_date          AS Experience_To
FROM TREATMENT_RECORD   TR
JOIN COMPLAINT          C  ON C.complaint_code  = TR.complaint_code
JOIN TREATMENT          T  ON T.treatment_code  = TR.treatment_code
JOIN DOCTOR             D  ON D.staff_no        = TR.doctor_no
LEFT JOIN PERFORMANCE_EXPERIENCE PE ON PE.doctor_id = D.staff_no
ORDER BY C.complaint_code, D.staff_no, PE.from_date;
GO

-- ============================================================
-- QUERY 7: List of patients with more than one complaint and their treatments
-- ============================================================
SELECT
    P.patient_no        AS Patient_No,
    P.name              AS Patient_Name,
    C.description       AS Complaint,
    T.description       AS Treatment,
    TR.date_started     AS Date_Started,
    TR.date_ended       AS Date_Ended
FROM PATIENT P
JOIN TREATMENT_RECORD TR ON TR.patient_no     = P.patient_no
JOIN COMPLAINT        C  ON C.complaint_code  = TR.complaint_code
JOIN TREATMENT        T  ON T.treatment_code  = TR.treatment_code
WHERE P.patient_no IN (
    SELECT patient_no
    FROM   TREATMENT_RECORD
    GROUP  BY patient_no
    HAVING COUNT(DISTINCT complaint_code) > 1
)
ORDER BY P.patient_no, C.complaint_code;
GO

-- ============================================================
-- QUERY 8: List of patients grouped by treatment within complaint
-- ============================================================
SELECT
    C.complaint_code    AS Complaint_Code,
    C.description       AS Complaint,
    T.treatment_code    AS Treatment_Code,
    T.description       AS Treatment,
    P.patient_no        AS Patient_No,
    P.name              AS Patient_Name,
    TR.date_started     AS Date_Started,
    TR.date_ended       AS Date_Ended
FROM TREATMENT_RECORD TR
JOIN COMPLAINT  C ON C.complaint_code  = TR.complaint_code
JOIN TREATMENT  T ON T.treatment_code  = TR.treatment_code
JOIN PATIENT    P ON P.patient_no      = TR.patient_no
ORDER BY C.complaint_code, T.treatment_code, P.patient_no;
GO

-- ============================================================
-- QUERY 9: Performance history for a particular doctor
--          Replace @DoctorID with the desired staff_no
-- ============================================================
DECLARE @DoctorID INT = 301;   -- Change this value as needed

SELECT
    D.staff_no          AS Doctor_ID,
    D.name              AS Doctor_Name,
    D.position          AS Current_Position,
    D.date_joined_team  AS Date_Joined_Team,
    PE.position         AS Past_Position,
    PE.establishment    AS Establishment,
    PE.from_date        AS Experience_From,
    PE.to_date          AS Experience_To,
    PP.progress_date    AS Grade_Date,
    PP.grade            AS Performance_Grade,
    PP.consultant_id    AS Graded_By_Consultant
FROM DOCTOR D
LEFT JOIN PERFORMANCE_EXPERIENCE PE ON PE.doctor_id   = D.staff_no
LEFT JOIN PERFORMANCE_PROGRESS   PP ON PP.doctor_id   = D.staff_no
WHERE D.staff_no = @DoctorID
ORDER BY PE.from_date, PP.progress_date;
GO

-- ============================================================
-- QUERY 10: Full medical details for a particular patient
--           Replace @PatientNo with the desired patient_no
-- ============================================================
DECLARE @PatientNo INT = 1001;  -- Change this value as needed

SELECT
    P.patient_no        AS Patient_No,
    P.name              AS Patient_Name,
    P.dob               AS Date_of_Birth,
    P.date_admitted     AS Date_Admitted,
    P.bed_no            AS Bed_No,
    CASE WHEN P.overseas = 1 THEN 'Yes' ELSE 'No' END AS Overseas,
    W.name              AS Ward_Name,
    S.specialty_name    AS Ward_Specialty,
    CU.unit_no          AS Care_Unit,
    N.name              AS Charge_Nurse,
    D.name              AS Assigned_Doctor,
    D.position          AS Doctor_Position,
    SP2.specialty_name  AS Consultant_Specialty,
    CM.description      AS Complaint,
    T.description       AS Treatment,
    TD.name             AS Treating_Doctor,
    TR.date_started     AS Treatment_Start,
    TR.date_ended       AS Treatment_End
FROM PATIENT            P
JOIN WARD               W   ON W.ward_id        = P.ward_id
JOIN SPECIALTY          S   ON S.specialty_id   = W.specialty_id
JOIN CARE_UNIT          CU  ON CU.unit_no        = P.care_unit_id
JOIN NURSE              N   ON N.nurse_id        = CU.charge_nurse_id
JOIN DOCTOR             D   ON D.staff_no        = P.doctor_no
JOIN CONSULTANT         C2  ON C2.staff_no       = D.consultant_id
JOIN SPECIALTY          SP2 ON SP2.specialty_id  = C2.specialty_id
LEFT JOIN TREATMENT_RECORD TR ON TR.patient_no   = P.patient_no
LEFT JOIN COMPLAINT     CM  ON CM.complaint_code = TR.complaint_code
LEFT JOIN TREATMENT     T   ON T.treatment_code  = TR.treatment_code
LEFT JOIN DOCTOR        TD  ON TD.staff_no       = TR.doctor_no
WHERE P.patient_no = @PatientNo
ORDER BY TR.date_started;
GO

-- ============================================================
-- QUERY 11: List of treatments given for a particular complaint
--           between two dates, ordered by treatment
--           Replace @ComplaintCode, @FromDate, @ToDate as needed
-- ============================================================
DECLARE @ComplaintCode INT  = 401;
DECLARE @FromDate      DATE = '2024-01-01';
DECLARE @ToDate        DATE = '2024-12-31';

SELECT
    CM.complaint_code   AS Complaint_Code,
    CM.description      AS Complaint,
    T.description       AS Treatment,
    P.name              AS Patient_Name,
    D.name              AS Doctor_Name,
    TR.date_started     AS Date_Started,
    TR.date_ended       AS Date_Ended
FROM TREATMENT_RECORD TR
JOIN COMPLAINT  CM ON CM.complaint_code = TR.complaint_code
JOIN TREATMENT  T  ON T.treatment_code  = TR.treatment_code
JOIN PATIENT    P  ON P.patient_no      = TR.patient_no
JOIN DOCTOR     D  ON D.staff_no        = TR.doctor_no
WHERE TR.complaint_code = @ComplaintCode
  AND TR.date_started  >= @FromDate
  AND TR.date_started  <= @ToDate
ORDER BY T.description, TR.date_started;
GO

-- ============================================================
-- QUERY 12: List of different positions held by staff and count
-- ============================================================
SELECT
    'Doctor' AS Staff_Type,
    position AS Position,
    COUNT(*)  AS Staff_Count
FROM DOCTOR
GROUP BY position

UNION ALL

SELECT
    'Nurse'  AS Staff_Type,
    position AS Position,
    COUNT(*)  AS Staff_Count
FROM NURSE
GROUP BY position

ORDER BY Staff_Type, Position;
GO

-- ============================================================
-- END OF QUERIES
-- ============================================================
