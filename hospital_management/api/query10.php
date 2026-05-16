<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// Query 10: Full medical details for a particular patient
$patientNo = isset($_GET['patient_no']) ? intval($_GET['patient_no']) : 0;

if ($patientNo <= 0) {
    // Return patient list for dropdown
    $sql = "SELECT patient_no, name FROM PATIENT ORDER BY name";
    echo json_encode(["patients" => runQuery($conn, $sql)]);
    exit;
}

$sql = "
    SELECT
        P.patient_no,
        P.name              AS patient_name,
        P.dob,
        P.date_admitted,
        P.bed_no,
        P.overseas,
        W.name              AS ward_name,
        S.specialty_name    AS specialty,
        CU.unit_no          AS care_unit,
        N.name              AS charge_nurse,
        D.name              AS assigned_doctor,
        D.position          AS doctor_position,
        C2.staff_no         AS consultant_id,
        SP2.specialty_name  AS consultant_specialty,
        -- Complaints & treatments
        CM.description      AS complaint,
        T.description       AS treatment,
        TD.name             AS treating_doctor,
        TR.date_started,
        TR.date_ended
    FROM PATIENT            P
    JOIN WARD               W   ON W.ward_id        = P.ward_id
    JOIN SPECIALTY          S   ON S.specialty_id   = W.specialty_id
    JOIN CARE_UNIT          CU  ON CU.unit_no        = P.care_unit_id
    JOIN NURSE              N   ON N.nurse_id        = CU.charge_nurse_id
    JOIN DOCTOR             D   ON D.staff_no        = P.doctor_no
    JOIN CONSULTANT         C2  ON C2.staff_no       = D.consultant_id
    JOIN SPECIALTY          SP2 ON SP2.specialty_id  = C2.specialty_id
    LEFT JOIN TREATMENT_RECORD TR ON TR.patient_no   = P.patient_no
    LEFT JOIN COMPLAINT     CM  ON CM.complaint_code = TR.complaint_code
    LEFT JOIN TREATMENT     T   ON T.treatment_code  = TR.treatment_code
    LEFT JOIN DOCTOR        TD  ON TD.staff_no       = TR.doctor_no
    WHERE P.patient_no = ?
    ORDER BY TR.date_started
";

echo json_encode(runQuery($conn, $sql, [$patientNo]));
?>
