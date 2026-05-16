<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 11: Treatments given for a particular complaint between two dates, ordered by treatment
$complaintCode = isset($_GET['complaint_code']) ? intval($_GET['complaint_code']) : 0;
$dateFrom      = isset($_GET['date_from'])      ? $_GET['date_from']              : '';
$dateTo        = isset($_GET['date_to'])        ? $_GET['date_to']                : '';

// Return complaints list if no filter provided
if ($complaintCode <= 0 || empty($dateFrom) || empty($dateTo)) {
    $sql = "SELECT complaint_code, description FROM COMPLAINT ORDER BY description";
    echo json_encode(["complaints" => runQuery($conn, $sql)]);
    exit;
}

$sql = "
    SELECT
        CM.complaint_code,
        CM.description      AS complaint,
        T.description       AS treatment,
        P.name              AS patient_name,
        D.name              AS doctor_name,
        TR.date_started,
        TR.date_ended
    FROM TREATMENT_RECORD TR
    JOIN COMPLAINT  CM ON CM.complaint_code = TR.complaint_code
    JOIN TREATMENT  T  ON T.treatment_code  = TR.treatment_code
    JOIN PATIENT    P  ON P.patient_no      = TR.patient_no
    JOIN DOCTOR     D  ON D.staff_no        = TR.doctor_no
    WHERE TR.complaint_code = ?
      AND TR.date_started  >= ?
      AND TR.date_started  <= ?
    ORDER BY T.description, TR.date_started
";

echo json_encode(runQuery($conn, $sql, [$complaintCode, $dateFrom, $dateTo]));
?>
