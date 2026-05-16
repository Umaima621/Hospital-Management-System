<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 1: A list of consultants and the doctors in their team
$sql = "
    SELECT
        C.staff_no          AS consultant_id,
        S.specialty_name    AS specialty,
        D.staff_no          AS doctor_id,
        D.name              AS doctor_name,
        D.position          AS doctor_position,
        D.date_joined_team
    FROM CONSULTANT C
    JOIN SPECIALTY  S ON S.specialty_id  = C.specialty_id
    JOIN DOCTOR     D ON D.consultant_id = C.staff_no
    ORDER BY C.staff_no, D.name
";

echo json_encode(runQuery($conn, $sql));
?>
