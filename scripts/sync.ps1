# Regenerates the Claude Code skill from the shared core, then sanity-checks sizes.
# Usage: powershell -File scripts/sync.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$corePath = Join-Path $root 'core\omnimentor-core.md'
$skillPath = Join-Path $root '.claude\skills\omnimentor\SKILL.md'
$briefPath = Join-Path $root 'chatgpt\instructions.txt'
$utf8 = New-Object Text.UTF8Encoding($false)

$front = @'
---
name: omnimentor
description: "Practical-first learning coach for any skill. Use when the user wants to learn, be taught, practice, or be tested on something — programming, DSA and algorithm problems, system design, theory and concepts, or general skills like communication, research, and interviews — or wants a study plan or roadmap for a topic or deadline. Hands-on tasks first, Socratic hints instead of answers, adaptive difficulty, spaced review, and a persistent learner profile. Commands are /learn, /timeline, /roadmap, /program, /dsa, /design, /theory, /quiz, /practice, /challenge, /mock, /debug, /review, /explain, /eli5, /recap, /progress, /harder, /easier, /project."
---
'@

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $skillPath) | Out-Null
$core = [IO.File]::ReadAllText($corePath, $utf8)
$skill = $front.TrimEnd() + "`n`n" + $core.TrimEnd() + "`n"
[IO.File]::WriteAllText($skillPath, $skill, $utf8)

# --- checks ---
$brief = [IO.File]::ReadAllText($briefPath, $utf8)
$coreCmds = ([regex]::Matches($core, '(?m)^\| `/[a-z]+')).Count
$briefCmds = ([regex]::Matches($brief, '(?m)^- /[a-z]+')).Count

Write-Host "SKILL.md written      : $($skill.Length) chars"
Write-Host "core                  : $($core.Length) chars, $coreCmds commands"
Write-Host "chatgpt brief         : $($brief.Length) chars (cap 8000), $briefCmds commands"
if ($brief.Length -gt 8000) { Write-Warning "chatgpt/instructions.txt exceeds the 8000-char Instructions cap." }
if ($briefCmds -ne $coreCmds) { Write-Warning "Command count mismatch: core=$coreCmds brief=$briefCmds. Update the compact brief." }
