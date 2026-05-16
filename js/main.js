// Main JavaScript for Hospital Management System

function showLoading() {
    const d = document.getElementById('loading');
    if (d) d.style.display = 'block';
}

function hideLoading() {
    const d = document.getElementById('loading');
    if (d) d.style.display = 'none';
}

function showError(message, containerId) {
    const c = document.getElementById(containerId);
    if (c) c.innerHTML = `<div class="error-message"><strong>Error:</strong> ${message}</div>`;
}

// Format date strings cleanly
function formatDate(val) {
    if (!val) return 'N/A';
    // Handle ISO strings like "2024-01-05T00:00:00+00:00" or plain "2024-01-05"
    const date = new Date(val);
    if (isNaN(date.getTime())) return val; // return as-is if unparseable
    return date.toLocaleDateString('en-GB', { year: 'numeric', month: 'short', day: 'numeric' });
}

// Export any table to CSV — works on dynamically injected tables too
function exportToCSV(tableId, filename) {
    const table = document.getElementById(tableId);
    if (!table) { alert('Table not found.'); return; }
    const rows = table.querySelectorAll('tr');
    const csv = [];
    rows.forEach(row => {
        const cols = row.querySelectorAll('td, th');
        const rowData = Array.from(cols).map(col => {
            let text = col.innerText.replace(/"/g, '""');
            if (text.includes(',')) text = `"${text}"`;
            return text;
        });
        csv.push(rowData.join(','));
    });
    const blob = new Blob([csv.join('\n')], { type: 'text/csv' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename + '.csv';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);
}

function printTable(elementId) {
    const content = document.getElementById(elementId);
    if (!content) return;
    const w = window.open('', '_blank');
    w.document.write(`<html><head><title>Hospital Report</title>
        <style>body{font-family:Arial,sans-serif;margin:20px}table{border-collapse:collapse;width:100%}
        th,td{border:1px solid #ddd;padding:8px;text-align:left}th{background:#f2f2f2}</style>
        </head><body>${content.innerHTML}</body></html>`);
    w.document.close();
    w.print();
}

function isValidDate(d) { return new Date(d) instanceof Date && !isNaN(new Date(d)); }
function getQueryParam(p) { return new URLSearchParams(window.location.search).get(p); }

// Wire up export and print buttons — works for both static and dynamically added buttons
// Uses event delegation on document so it catches buttons added after page load
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('export-btn')) {
        const tableId = e.target.getAttribute('data-table');
        const filename = e.target.getAttribute('data-filename') || 'report';
        exportToCSV(tableId, filename);
    }
    if (e.target.classList.contains('print-btn')) {
        const reportId = e.target.getAttribute('data-report');
        printTable(reportId);
    }
});

document.addEventListener('DOMContentLoaded', function() {
    // Back button
    document.querySelectorAll('.back-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            window.history.back();
        });
    });
});
