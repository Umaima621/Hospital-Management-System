<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 7: Patients with more than one complaint and their treatments
$sql = "
    SELECT
        P.patient_no,
        P.name              AS patient_name,
        C.description       AS complaint,
        T.description       AS treatment,
        TR.date_started,
        TR.date_ended
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
    ORDER BY P.patient_no, C.complaint_code
";

echo json_encode(runQuery($conn, $sql));
?>
