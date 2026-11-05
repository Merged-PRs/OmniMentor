# Validates an OmniMentor learner profile against the rules in core/omnimentor-core.md.
# Usage: powershell -File scripts/check-progress.ps1 [-Path .omnimentor\progress.md] [-SelfTest]
param(
    [string]$Path = '.omnimentor\progress.md',
    [switch]$SelfTest
)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$validStatus = @('mastered', 'learning', 'weak')
$validProof = @('independent', 'hinted', 'solution')
$validInterval = @(1, 3, 7, 21, 60)
$validTopic = @('DSA', 'System Design', 'AI/ML', 'Theory', 'General Skill')
$required = @('Topic', 'Subtopic / pattern', 'Status', 'Proof', 'Last evidence', 'Interval (days)', 'Next review', 'Gap notes')

function Get-ProfileErrors([string]$file) {
    $errors = New-Object System.Collections.Generic.List[string]
    if (-not (Test-Path -LiteralPath $file)) { $errors.Add("File not found: $file"); return $errors }

    $lines = [IO.File]::ReadAllText($file, $utf8) -split "`r?`n"
    $hdr = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\|\s*Topic\s*\|') { $hdr = $i; break }
    }
    if ($hdr -lt 0) { $errors.Add('No Mastery table header (| Topic | ...) found.'); return $errors }

    $cols = @(($lines[$hdr].Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
    foreach ($need in $required) {
        if ($cols -notcontains $need) { $errors.Add("Header is missing column: $need") }
    }
    if ($errors.Count -gt 0) { return $errors }

    $seen = @{}
    $rows = 0
    for ($i = $hdr + 2; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if (-not $line.Trim().StartsWith('|')) { break }
        $c = @(($line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
        $rows++
        $where = "row $rows ($($c[0]) / $($c[1]))"
        if ($c.Count -ne 8) { $errors.Add("$where has $($c.Count) columns, expected 8"); continue }

        $key = (("$($c[0]) / $($c[1])").ToLower() -replace '\s+', ' ').Trim()
        if ($seen.ContainsKey($key)) { $errors.Add("Duplicate key '$key' at $where - merge into one row") } else { $seen[$key] = $true }

        $topicOk = $validTopic -contains $c[0] -or ($c[0] -match '^Programming / \S')
        if (-not $topicOk) { $errors.Add("$where has invalid Topic '$($c[0])' - use Programming / <lang>, DSA, System Design, AI/ML, Theory, or General Skill") }

        if ($validStatus -notcontains $c[2]) { $errors.Add("$where has invalid Status '$($c[2])'") }
        if ($validProof -notcontains $c[3]) { $errors.Add("$where has invalid Proof '$($c[3])'") }
        if ($c[2] -eq 'mastered' -and $c[3] -ne 'independent') { $errors.Add("$where is mastered with proof '$($c[3])' - only independent earns mastery") }
        if ($c[2] -eq 'weak' -and [string]::IsNullOrWhiteSpace($c[7])) { $errors.Add("$where is weak with no gap note") }

        $interval = 0
        if (-not [int]::TryParse($c[5], [ref]$interval) -or $validInterval -notcontains $interval) {
            $errors.Add("$where has invalid Interval '$($c[5])' - must be 1, 3, 7, 21, or 60")
        }

        $last = [datetime]::MinValue
        $next = [datetime]::MinValue
        $lastOk = [datetime]::TryParseExact($c[4], 'yyyy-MM-dd', $null, 'None', [ref]$last)
        $nextOk = [datetime]::TryParseExact($c[6], 'yyyy-MM-dd', $null, 'None', [ref]$next)
        if (-not $lastOk) { $errors.Add("$where has invalid Last evidence '$($c[4])' - use yyyy-MM-dd") }
        if (-not $nextOk) { $errors.Add("$where has invalid Next review '$($c[6])' - use yyyy-MM-dd") }
        if ($lastOk -and $nextOk -and $validInterval -contains $interval) {
            $expected = $last.AddDays($interval).ToString('yyyy-MM-dd')
            if ($next.ToString('yyyy-MM-dd') -ne $expected) { $errors.Add("$where breaks Next review = Last evidence + Interval (expected $expected)") }
        }
    }
    if ($rows -eq 0) { $errors.Add('Mastery table has no rows.') }
    if ($rows -gt 60) { $errors.Add("Mastery has $rows rows - prune to 60 or fewer") }
    return $errors
}

function Show([string]$file) {
    $e = Get-ProfileErrors $file
    if ($e.Count -eq 0) { Write-Host "OK: $file" -ForegroundColor Green; return 0 }
    Write-Host "FAIL: $file ($($e.Count) problem(s))" -ForegroundColor Red
    $e | ForEach-Object { Write-Host "  - $_" }
    return 1
}

if ($SelfTest) {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) "omnimentor-selftest-$PID.md"
    $good = @'
| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
|---|---|---|---|---|---|---|---|
| DSA | sliding window | learning | hinted | 2026-11-06 | 1 | 2026-11-07 | window shrink off-by-one |
| Programming / Rust | ownership | mastered | independent | 2026-11-01 | 7 | 2026-11-08 | |
'@
    $bad = @'
| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
|---|---|---|---|---|---|---|---|
| DSA | sliding window | mastered | hinted | 2026-11-06 | 1 | 2026-11-07 | |
| DSA | Sliding  Window | weak | independent | 2026-11-06 | 5 | 2026-11-20 | |
| Rust | ownership | learning | independent | 2026-11-01 | 3 | 2026-11-04 | |
'@
    [IO.File]::WriteAllText($tmp, "## Mastery`n$good", $utf8)
    $goodErrors = (Get-ProfileErrors $tmp).Count
    [IO.File]::WriteAllText($tmp, "## Mastery`n$bad", $utf8)
    $badErrors = (Get-ProfileErrors $tmp).Count
    Remove-Item $tmp -Force
    if ($goodErrors -eq 0 -and $badErrors -ge 5) {
        Write-Host "SELFTEST PASS: good profile clean, bad profile caught $badErrors problems" -ForegroundColor Green
        exit 0
    }
    Write-Host "SELFTEST FAIL: good=$goodErrors (want 0), bad=$badErrors (want >=5)" -ForegroundColor Red
    exit 1
}

exit (Show $Path)
