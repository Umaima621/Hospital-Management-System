USE HospitalDB;
GO

-- Add 2 Junior Houseman doctors
INSERT INTO DOCTOR (staff_no, name, position, consultant_id, date_joined_team) VALUES
(311, 'Dr. Kamran Yusuf', 'Junior Houseman', 201, '2023-08-01'),
(312, 'Dr. Sana Mirza',   'Junior Houseman', 202, '2023-09-15');

-- Assign patients to them
INSERT INTO PATIENT (patient_no, name, dob, date_admitted, bed_no, overseas, ward_id, care_unit_id, doctor_no) VALUES
(1031, 'Bilal Rana',  '1992-03-10', '2024-04-01', 31, 0, 1, 101, 311),
(1032, 'Noor Fatima', '1985-07-22', '2024-04-03', 32, 0, 2, 102, 312);

-- Treatment records for junior housemen (fixes Query 4)
INSERT INTO TREATMENT_RECORD (record_id, patient_no, complaint_code, treatment_code, doctor_no, date_started, date_ended) VALUES
(621, 1031, 401, 511, 311, '2024-04-01', '2024-04-15'),
(622, 1032, 402, 502, 312, '2024-04-03', '2024-04-20');

-- Second complaints for existing patients (fixes Query 7)
INSERT INTO TREATMENT_RECORD (record_id, patient_no, complaint_code, treatment_code, doctor_no, date_started, date_ended) VALUES
(623, 1001, 411, 511, 301, '2024-01-21', '2024-02-01'),
(624, 1003, 412, 512, 303, '2024-01-31', '2024-02-15'),
(625, 1005, 413, 513, 304, '2024-02-11', '2024-02-25');