<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 3: A list of patients and their complaints, treatments and dates of treatment
$sql = "
    SELECT
        P.patient_no,
        P.name              AS patient_name,
        C.description       AS complaint,
        T.description       AS treatment,
        D.name              AS treating_doctor,
        TR.date_started,
        TR.date_ended
    FROM TREATMENT_RECORD TR
    JOIN PATIENT    P ON P.patient_no      = TR.patient_no
    JOIN COMPLAINT  C ON C.complaint_code  = TR.complaint_code
    JOIN TREATMENT  T ON T.treatment_code  = TR.treatment_code
    JOIN DOCTOR     D ON D.staff_no        = TR.doctor_no
    ORDER BY P.patient_no, TR.date_started
";

echo json_encode(runQuery($conn, $sql));
?>
