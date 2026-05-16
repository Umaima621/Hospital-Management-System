<?php

$serverName = "localhost\SQLEXPRESS";
$database   = "HospitalDB";

$connectionOptions = [
    "Database" => $database,
    "TrustServerCertificate" => true
];

$conn = sqlsrv_connect($serverName, $connectionOptions);

if (!$conn) {
    http_response_code(500);
    header("Content-Type: application/json");
    echo json_encode([
        "error" => sqlsrv_errors()
    ]);
    exit;
}

function runQuery($conn, $sql, $params = []) {
    $stmt = sqlsrv_query($conn, $sql, $params);

    if (!$stmt) {
        return ["error" => sqlsrv_errors()];
    }

    $rows = [];

    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
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