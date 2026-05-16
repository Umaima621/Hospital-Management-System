<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 6: Complaints, treatments given for that complaint and experience history of the treating doctor
$sql = "
    SELECT
        C.complaint_code,
        C.description           AS complaint,
        T.description           AS treatment,
        D.name                  AS doctor_name,
        D.position              AS current_position,
        PE.position             AS past_position,
        PE.establishment,
        PE.from_date,
        PE.to_date
    FROM TREATMENT_RECORD   TR
    JOIN COMPLAINT          C  ON C.complaint_code  = TR.complaint_code
    JOIN TREATMENT          T  ON T.treatment_code  = TR.treatment_code
    JOIN DOCTOR             D  ON D.staff_no        = TR.doctor_no
    LEFT JOIN PERFORMANCE_EXPERIENCE PE ON PE.doctor_id = D.staff_no
    ORDER BY C.complaint_code, D.staff_no, PE.from_date
";

echo json_encode(runQuery($conn, $sql));
?>
