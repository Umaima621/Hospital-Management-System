<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 4: Junior housemen and their patients and the staff nurse for the care-unit of that patient
$sql = "
    SELECT
        D.staff_no          AS doctor_id,
        D.name              AS junior_houseman,
        D.position,
        P.patient_no,
        P.name              AS patient_name,
        CU.unit_no          AS care_unit,
        N.name              AS staff_nurse
    FROM DOCTOR         D
    JOIN PATIENT        P  ON P.doctor_no       = D.staff_no
    JOIN CARE_UNIT      CU ON CU.unit_no        = P.care_unit_id
    JOIN NURSE          N  ON N.nurse_id        = CU.charge_nurse_id
    WHERE D.position = 'Junior Houseman'
    ORDER BY D.staff_no, P.patient_no
";

echo json_encode(runQuery($conn, $sql));
?>
