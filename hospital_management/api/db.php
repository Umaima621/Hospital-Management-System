<?php
// Database connection for IVOR Paine Memorial Hospital
// CS204 Database Systems - FAST NUCES Islamabad

$serverName = "localhost\SQLEXPRESS"; // Change if your SQL Server instance is different
$database   = "HospitalDB";
$username   = "hospital_user";
$password   = "Admin123!";

$connectionOptions = [
    "Database"              => $database,
    "Uid"                   => $username,
    "PWD"                   => $password,
    "TrustServerCertificate"=> true,
];

$conn = sqlsrv_connect($serverName, $connectionOptions);

if (!$conn) {
    http_response_code(500);
    header("Content-Type: application/json");
    echo json_encode(["error" => "Database connection failed: " . print_r(sqlsrv_errors(), true)]);
    exit;
}

// Helper: run a query and return rows as associative array
function runQuery($conn, $sql, $params = []) {
    $stmt = sqlsrv_query($conn, $sql, $params);
    if (!$stmt) {
        return ["error" => print_r(sqlsrv_errors(), true)];
    }
    $rows = [];
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        // Convert DateTime objects to strings
        foreach ($row as $key => $val) {
            if ($val instanceof DateTime) {
                $row[$key] = $val->format("Y-m-d");
            }
        }
        $rows[] = $row;
    }
    return $rows;
}
?>
