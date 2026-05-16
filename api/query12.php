<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 12: Different positions held by staff and count of staff in each position
// Combines doctors and nurses into one unified staff list
$sql = "
    SELECT position, COUNT(*) AS staff_count, 'Doctor' AS staff_type
    FROM   DOCTOR
    GROUP  BY position

    UNION ALL

    SELECT position, COUNT(*) AS staff_count, 'Nurse' AS staff_type
    FROM   NURSE
    GROUP  BY position

    ORDER  BY staff_type, position
";

echo json_encode(runQuery($conn, $sql));
?>
