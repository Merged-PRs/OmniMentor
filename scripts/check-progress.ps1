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
$baseColumns = @('Topic', 'Subtopic / pattern', 'Status', 'Proof', 'Last evidence', 'Interval (days)', 'Next review', 'Gap notes')
$optionalColumns = @('Prereq', 'Confidence', 'Misconception')

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
    $expected = if ($cols.Count -eq 8) { $baseColumns } elseif ($cols.Count -eq 11) { $baseColumns + $optionalColumns } else { $null }
    if (-not $expected) {
        $errors.Add("Mastery header must have 8 or 11 columns, found $($cols.Count).")
        return $errors
    }
    if (($cols -join '|') -ne ($expected -join '|')) {
        $errors.Add("Mastery header columns must be exactly: $($expected -join ' | ')")
        return $errors
    }

    $idx = @{}
    for ($j = 0; $j -lt $cols.Count; $j++) { $idx[$cols[$j]] = $j }

    $seen = @{}
    $rows = 0
    for ($i = $hdr + 2; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if (-not $line.Trim().StartsWith('|')) { break }
        $c = @(($line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
        $rows++
        $where = "row $rows ($($c[0]) / $($c[1]))"
        if ($c.Count -ne $cols.Count) { $errors.Add("$where has $($c.Count) columns, expected $($cols.Count)"); continue }

        $key = (("$($c[$idx['Topic']]) / $($c[$idx['Subtopic / pattern']])").ToLower() -replace '\s+', ' ').Trim()
        if ($seen.ContainsKey($key)) { $errors.Add("Duplicate key '$key' at $where - merge into one row") } else { $seen[$key] = $true }

        $topic = $c[$idx['Topic']]
        $topicOk = $validTopic -contains $topic -or ($topic -match '^Programming / \S')
        if (-not $topicOk) { $errors.Add("$where has invalid Topic '$topic' - use Programming / <lang>, DSA, System Design, AI/ML, Theory, or General Skill") }

        $status = $c[$idx['Status']]
        $proof = $c[$idx['Proof']]
        if ($validStatus -notcontains $status) { $errors.Add("$where has invalid Status '$status'") }
        if ($validProof -notcontains $proof) { $errors.Add("$where has invalid Proof '$proof'") }
        if ($status -eq 'mastered' -and $proof -ne 'independent') { $errors.Add("$where is mastered with proof '$proof' - only independent earns mastery") }
        if ($status -eq 'weak' -and [string]::IsNullOrWhiteSpace($c[$idx['Gap notes']])) { $errors.Add("$where is weak with no gap note") }

        if ($cols.Count -eq 11) {
            $confidence = $c[$idx['Confidence']]
            if ($confidence -ne '' -and $confidence -notmatch '^[1-5]$') { $errors.Add("$where has invalid Confidence '$confidence' - use 1-5 or leave empty") }
            foreach ($opt in 'Prereq', 'Misconception') {
                $value = $c[$idx[$opt]]
                if ($value -ne '') {
                    $parts = @($value -split ';' | ForEach-Object { $_.Trim() })
                    if ($parts -contains '') { $errors.Add("$where has an empty ;-separated value in $opt") }
                }
            }
        }

        $interval = 0
        if (-not [int]::TryParse($c[$idx['Interval (days)']], [ref]$interval) -or $validInterval -notcontains $interval) {
            $errors.Add("$where has invalid Interval '$($c[$idx['Interval (days)']])' - must be 1, 3, 7, 21, or 60")
        }

        $last = [datetime]::MinValue
        $next = [datetime]::MinValue
        $lastOk = [datetime]::TryParseExact($c[$idx['Last evidence']], 'yyyy-MM-dd', $null, 'None', [ref]$last)
        $nextOk = [datetime]::TryParseExact($c[$idx['Next review']], 'yyyy-MM-dd', $null, 'None', [ref]$next)
        if (-not $lastOk) { $errors.Add("$where has invalid Last evidence '$($c[$idx['Last evidence']])' - use yyyy-MM-dd") }
        if (-not $nextOk) { $errors.Add("$where has invalid Next review '$($c[$idx['Next review']])' - use yyyy-MM-dd") }
        if ($lastOk -and $nextOk -and $validInterval -contains $interval) {
            $expectedNext = $last.AddDays($interval).ToString('yyyy-MM-dd')
            if ($next.ToString('yyyy-MM-dd') -ne $expectedNext) { $errors.Add("$where breaks Next review = Last evidence + Interval (expected $expectedNext)") }
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
    $dir = Join-Path ([IO.Path]::GetTempPath()) "omnimentor-selftest-$PID"
    New-Item -ItemType Directory -Force $dir | Out-Null
    $p8 = Join-Path $dir 'good8.md'
    $p11 = Join-Path $dir 'good11.md'
    $pb = Join-Path $dir 'bad11.md'
    $pm = Join-Path $dir 'mixed.md'

    $good8 = @'
## Mastery
| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
|---|---|---|---|---|---|---|---|
| DSA | sliding window | learning | hinted | 2026-11-06 | 1 | 2026-11-07 | window shrink off-by-one |
| Programming / Rust | ownership | mastered | independent | 2026-11-01 | 7 | 2026-11-08 | |
'@

    $good11 = @'
## Mastery
| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes | Prereq | Confidence | Misconception |
|---|---|---|---|---|---|---|---|---|---|---|
| Programming / Rust | ownership | mastered | independent | 2026-11-01 | 7 | 2026-11-08 | | | 4 | |
| DSA | sliding window | learning | hinted | 2026-11-06 | 1 | 2026-11-07 | window shrink off-by-one | arrays; hashing | | |
'@

    $bad11 = @'
## Mastery
| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes | Prereq | Confidence | Misconception |
|---|---|---|---|---|---|---|---|---|---|---|
| DSA | sliding window | mastered | hinted | 2026-11-06 | 1 | 2026-11-07 | | | 6 | index as key |
| DSA | Sliding  Window | weak | independent | 2026-11-06 | 5 | 2026-11-20 | | | | |
| Rust | ownership | learning | independent | 2026-11-01 | 3 | 2026-11-04 | | | | |
'@

    $mixed = @'
## Mastery
| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes | Prereq |
|---|---|---|---|---|---|---|---|---|
| DSA | sliding window | learning | hinted | 2026-11-06 | 1 | 2026-11-07 | | arrays |
'@

    [IO.File]::WriteAllText($p8, $good8, $utf8)
    [IO.File]::WriteAllText($p11, $good11, $utf8)
    [IO.File]::WriteAllText($pb, $bad11, $utf8)
    [IO.File]::WriteAllText($pm, $mixed, $utf8)
    $e8 = (Get-ProfileErrors $p8).Count
    $e11 = (Get-ProfileErrors $p11).Count
    $eb = (Get-ProfileErrors $pb).Count
    $em = (Get-ProfileErrors $pm).Count
    Remove-Item $dir -Recurse -Force

    if ($e8 -eq 0 -and $e11 -eq 0 -and $eb -ge 6 -and $em -ge 1) {
        Write-Host "SELFTEST PASS: 8-col clean; 11-col clean incl. missing confidence; bad 11-col caught $eb; mixed header rejected" -ForegroundColor Green
        exit 0
    }
    Write-Host "SELFTEST FAIL: good8=$e8 (want 0), good11=$e11 (want 0), bad11=$eb (want >=6), mixed=$em (want >=1)" -ForegroundColor Red
    exit 1
}

exit (Show $Path)
