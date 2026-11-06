# Runs the OmniMentor baseline scenarios against the CURRENT core.
# Usage: powershell -File evals/run-baseline.ps1 [-Runs 3] [-Only beginner] [-Model provider/model]
param(
    [int]$Runs = 3,
    [string]$Only = '',
    [string]$Model = 'zenmux/deepseek/deepseek-v4.1-flash',
    [string]$ResultsDir = 'baseline',
    [string]$CoreFile = '',
    [string]$SkillFile = ''
)
$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = New-Object Text.UTF8Encoding($false)
chcp 65001 | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)
$root = Split-Path -Parent $PSScriptRoot
$resultsDir = Join-Path $PSScriptRoot "results\$ResultsDir"
New-Item -ItemType Directory -Force $resultsDir | Out-Null
$scenarios = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'scenarios.json') | ConvertFrom-Json
$runTag = ($ResultsDir + '-' + (Get-Date -Format 'yyyyMMddHHmmssfff')) -replace '[^a-zA-Z0-9]', ''

$summary = New-Object System.Text.StringBuilder
[void]$summary.AppendLine("# Run summary: $ResultsDir")
[void]$summary.AppendLine('')
[void]$summary.AppendLine("Model: ``$Model``")
[void]$summary.AppendLine('')
[void]$summary.AppendLine('| Scenario | Run | Ledger changed | Ledger present | Validator exit | Mastery rows |')
[void]$summary.AppendLine('|---|---|---|---|---|---|')

foreach ($s in $scenarios) {
    if ($Only -and $s.id -ne $Only) { continue }
    for ($r = 1; $r -le $Runs; $r++) {
        $work = Join-Path $env:TEMP ("omni-eval\{0}\{1}-{2}" -f $runTag, $s.id, $r)
        if (Test-Path $work) { Remove-Item $work -Recurse -Force }
        New-Item -ItemType Directory -Force $work | Out-Null
        Copy-Item (Join-Path $root '.claude') $work -Recurse -Force
        Copy-Item (Join-Path $root 'core') $work -Recurse -Force
        Copy-Item (Join-Path $root 'scripts') $work -Recurse -Force
        if ($CoreFile) { Copy-Item $CoreFile (Join-Path $work 'core\omnimentor-core.md') -Force }
        if ($SkillFile) { Copy-Item $SkillFile (Join-Path $work '.claude\skills\omnimentor\SKILL.md') -Force }

        if ($s.seedProfile) {
            $pdir = Join-Path $work '.omnimentor'
            New-Item -ItemType Directory -Force $pdir | Out-Null
            [IO.File]::WriteAllText((Join-Path $pdir 'progress.md'), $s.seedProfile, $utf8)
        }
        $seededProfile = Join-Path $work '.omnimentor\progress.md'
        $seedHash = if (Test-Path $seededProfile) { (Get-FileHash $seededProfile -Algorithm SHA256).Hash } else { 'none' }

        $sid = 'ses_eval_{0}_{1}_{2}' -f $runTag, ($s.id -replace '-', '_'), $r
        $outFile = Join-Path $resultsDir ("{0}-run{1}.md" -f $s.id, $r)
        $log = New-Object System.Text.StringBuilder
        [void]$log.AppendLine("# $($s.id) - run $r")
        [void]$log.AppendLine('')
        [void]$log.AppendLine("Model: ``$Model``")
        $t = 0
        Push-Location $work
        try {
            foreach ($turn in $s.turns) {
                $t++
                [void]$log.AppendLine('')
                [void]$log.AppendLine("## Learner turn $t")
                [void]$log.AppendLine('')
                [void]$log.AppendLine('```text')
                [void]$log.AppendLine($turn)
                [void]$log.AppendLine('```')
                $exit = 0
                $attempt = 0
                do {
                    $attempt++
                    try {
                        $raw = & opencode run --auto --model $Model -s $sid $turn 2>&1 | Out-String
                        $exit = $LASTEXITCODE
                    } catch {
                        $raw = "HARNESS ERROR: $($_.Exception.Message)"
                        $exit = -1
                    }
                    if ($exit -ne 0 -and $attempt -lt 2) { Start-Sleep -Seconds 3 }
                } while ($exit -ne 0 -and $attempt -lt 2)
                $clean = ($raw -replace '\x1B\[[0-9;]*[A-Za-z]', '')
                $clean = (($clean -split "`n") | Where-Object {
                    $_ -notmatch '^\s*opencode\.exe\s*:' -and
                    $_ -notmatch '^\s*At C:.*opencode\.ps1:' -and
                    $_ -notmatch '^\s*\+' -and
                    $_ -notmatch '^\s*CategoryInfo' -and
                    $_ -notmatch '^\s*FullyQualifiedErrorId'
                }) -join "`n"
                $clean = $clean.Trim()
                if ($attempt -gt 1) { [void]$log.AppendLine("(retried after exit $exit)") }
                New-Item -ItemType Directory -Force (Split-Path -Parent $outFile) | Out-Null
                [void]$log.AppendLine('')
                [void]$log.AppendLine("## Assistant turn $t (exit $exit)")
                [void]$log.AppendLine('')
                [void]$log.AppendLine($clean)
                [IO.File]::WriteAllText($outFile, $log.ToString(), $utf8)
                if ($exit -ne 0) { break }
            }
        } finally {
            Pop-Location
        }

        $profilePath = Join-Path $work '.omnimentor\progress.md'
        $ledgerExists = Test-Path $profilePath
        $finalHash = if ($ledgerExists) { (Get-FileHash $profilePath -Algorithm SHA256).Hash } else { 'none' }
        $ledgerChanged = $seedHash -ne $finalHash
        $valExit = 'n/a'
        $rows = @()
        [void]$log.AppendLine('')
        [void]$log.AppendLine('## Ledger after run')
        [void]$log.AppendLine('')
        [void]$log.AppendLine("**Changed since seed:** $ledgerChanged")
        [void]$log.AppendLine('')
        if ($ledgerExists) {
            $ledger = [IO.File]::ReadAllText($profilePath, $utf8)
            [void]$log.AppendLine('```markdown')
            [void]$log.AppendLine($ledger.Trim())
            [void]$log.AppendLine('```')
            $val = & powershell -ExecutionPolicy Bypass -File (Join-Path $work 'scripts\check-progress.ps1') -Path $profilePath 2>&1 | Out-String
            $valExit = $LASTEXITCODE
            [void]$log.AppendLine('')
            [void]$log.AppendLine('### check-progress.ps1')
            [void]$log.AppendLine('')
            [void]$log.AppendLine('```text')
            [void]$log.AppendLine($val.Trim())
            [void]$log.AppendLine('```')

            $lines = $ledger -split "`r?`n"
            $hi = -1
            for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^\|\s*Topic\s*\|') { $hi = $i; break } }
            if ($hi -ge 0) {
                $heads = @((($lines[$hi].Trim().Trim('|')) -split '\|') | ForEach-Object { $_.Trim() })
                for ($i = $hi + 2; $i -lt $lines.Count; $i++) {
                    if (-not $lines[$i].Trim().StartsWith('|')) { break }
                    $c = @((($lines[$i].Trim().Trim('|')) -split '\|') | ForEach-Object { $_.Trim() })
                    $row = [ordered]@{}
                    for ($j = 0; $j -lt $heads.Count -and $j -lt $c.Count; $j++) { $row[$heads[$j]] = $c[$j] }
                    $rows += [pscustomobject]$row
                }
            }
        } else {
            [void]$log.AppendLine('(no `.omnimentor/progress.md` was written)')
        }

        $rowText = if ($rows.Count -gt 0) {
            ($rows | ForEach-Object { "$($_['Topic']) / $($_['Subtopic / pattern']) [$($_['Status']) $($_['Proof'])]" }) -join '<br>'
        } else { 'none' }
        [void]$summary.AppendLine("| $($s.id) | $r | $ledgerChanged | $ledgerExists | $valExit | $rowText |")

        $outFile = Join-Path $resultsDir ("{0}-run{1}.md" -f $s.id, $r)
        [IO.File]::WriteAllText($outFile, $log.ToString(), $utf8)
        Write-Host ("done {0} run {1}" -f $s.id, $r)
    }
}

New-Item -ItemType Directory -Force $resultsDir | Out-Null
[IO.File]::WriteAllText((Join-Path $resultsDir 'SUMMARY.md'), $summary.ToString(), $utf8)
Write-Host "summary: $resultsDir\SUMMARY.md"
