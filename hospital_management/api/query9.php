<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 9: Performance history for a particular doctor (searched by doctor ID)
$doctorId = isset($_GET['doctor_id']) ? intval($_GET['doctor_id']) : 0;

if ($doctorId <= 0) {
    // Return all doctors list for the dropdown
    $sql = "SELECT staff_no AS doctor_id, name, position FROM DOCTOR ORDER BY name";
    echo json_encode(["doctors" => runQuery($conn, $sql)]);
    exit;
}

$sql = "
    SELECT
        D.staff_no          AS doctor_id,
        D.name              AS doctor_name,
        D.position          AS current_position,
        D.date_joined_team,
        -- Experience history
        PE.position         AS past_position,
        PE.establishment,
        PE.from_date,
        PE.to_date,
        -- Performance grades
        PP.progress_date,
        PP.grade,
        PP.consultant_id
    FROM DOCTOR D
    LEFT JOIN PERFORMANCE_EXPERIENCE PE ON PE.doctor_id   = D.staff_no
    LEFT JOIN PERFORMANCE_PROGRESS   PP ON PP.doctor_id   = D.staff_no
    WHERE D.staff_no = ?
    ORDER BY PE.from_date, PP.progress_date
";

echo json_encode(runQuery($conn, $sql, [$doctorId]));
?>
