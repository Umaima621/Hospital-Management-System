<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 2: Ward Record — ward info + nurses + patients per ward
// Returns two datasets: ward summary and patients per ward
$sqlWard = "
    SELECT
        W.ward_id,
        W.name              AS ward_name,
        S.specialty_name    AS specialty,
        DS.name             AS day_sister,
        NS.name             AS night_sister,
        CU.unit_no          AS care_unit_no,
        CN.name             AS charge_nurse,
        -- staff nurses in this ward
        (SELECT COUNT(*) FROM NURSE WHERE ward_id = W.ward_id AND position = 'Staff Nurse')     AS staff_nurse_count,
        (SELECT COUNT(*) FROM NURSE WHERE ward_id = W.ward_id AND position NOT IN ('Senior Sister','Night Sister','Staff Nurse','Charge Nurse')) AS non_registered_count
    FROM WARD       W
    JOIN SPECIALTY  S  ON S.specialty_id    = W.specialty_id
    LEFT JOIN NURSE DS ON DS.nurse_id       = W.day_sister_id
    LEFT JOIN NURSE NS ON NS.nurse_id       = W.night_sister_id
    LEFT JOIN CARE_UNIT CU ON CU.ward_id    = W.ward_id
    LEFT JOIN NURSE CN ON CN.nurse_id       = CU.charge_nurse_id
    ORDER BY W.ward_id, CU.unit_no
";

// Patient list per ward (as the spec Ward Record form shows)
$sqlPatients = "
    SELECT
        P.ward_id,
        P.patient_no,
        P.name              AS patient_name,
        P.care_unit_id      AS care_unit,
        P.bed_no,
        P.date_admitted,
        C.staff_no          AS consultant_id
    FROM PATIENT    P
    JOIN DOCTOR     D ON D.staff_no    = P.doctor_no
    JOIN CONSULTANT C ON C.staff_no    = D.consultant_id
    ORDER BY P.ward_id, P.patient_no
";

$wards    = runQuery($conn, $sqlWard);
$patients = runQuery($conn, $sqlPatients);

echo json_encode(["wards" => $wards, "patients" => $patients]);
?>
