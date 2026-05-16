<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 8: Patients grouped by treatment within complaint
$sql = "
    SELECT
        C.complaint_code,
        C.description       AS complaint,
        T.treatment_code,
        T.description       AS treatment,
        P.patient_no,
        P.name              AS patient_name,
        TR.date_started,
        TR.date_ended
    FROM TREATMENT_RECORD TR
    JOIN COMPLAINT  C ON C.complaint_code  = TR.complaint_code
    JOIN TREATMENT  T ON T.treatment_code  = TR.treatment_code
    JOIN PATIENT    P ON P.patient_no      = TR.patient_no
    ORDER BY C.complaint_code, T.treatment_code, P.patient_no
";

echo json_encode(runQuery($conn, $sql));
?>
