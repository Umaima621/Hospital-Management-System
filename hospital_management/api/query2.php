<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 2: Wards with respective sisters, care units and staff nurses in charge
$sql = "
    SELECT
        W.name              AS ward_name,
        S.specialty_name    AS specialty,
        DS.name             AS day_sister,
        NS.name             AS night_sister,
        CU.unit_no          AS care_unit_no,
        CN.name             AS charge_nurse
    FROM WARD       W
    JOIN SPECIALTY  S  ON S.specialty_id    = W.specialty_id
    LEFT JOIN NURSE DS ON DS.nurse_id       = W.day_sister_id
    LEFT JOIN NURSE NS ON NS.nurse_id       = W.night_sister_id
    LEFT JOIN CARE_UNIT CU ON CU.ward_id    = W.ward_id
    LEFT JOIN NURSE CN ON CN.nurse_id       = CU.charge_nurse_id
    ORDER BY W.ward_id, CU.unit_no
";

echo json_encode(runQuery($conn, $sql));
?>
