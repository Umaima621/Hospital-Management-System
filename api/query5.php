<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 5: Consultants with a unique specialty (specialty held by only one consultant)
$sql = "
    SELECT
        C.staff_no          AS consultant_id,
        S.specialty_name    AS specialty,
        S.description       AS specialty_description
    FROM CONSULTANT C
    JOIN SPECIALTY  S ON S.specialty_id = C.specialty_id
    WHERE C.specialty_id IN (
        SELECT specialty_id
        FROM   CONSULTANT
        GROUP  BY specialty_id
        HAVING COUNT(*) = 1
    )
    ORDER BY S.specialty_name
";

echo json_encode(runQuery($conn, $sql));
?>
