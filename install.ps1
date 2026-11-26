# 我的 BOT 学员版 - 技能目录安装脚本
# 作用：把 mybot-l2-workstyle 方法论复制到 ~/.dsh/skills/，让学员版能加载五篇方法论。
# 用法：右键本文件 → 使用 PowerShell 运行；或打开 PowerShell 执行：
#   powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = 'Stop'
Write-Host "=== My BOT Student Edition: install skill pack ===" -ForegroundColor Cyan

$dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
$dest = Join-Path $dshHome 'skills'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$found = @()
$profilesDir = Join-Path $dshHome 'profiles'
if (Test-Path $profilesDir) {
    Get-ChildItem $profilesDir -Directory | ForEach-Object {
        $p = Join-Path $_.FullName 'node_modules\dsh-my-bot-l2\skills\mybot-l2-workstyle'
        if (Test-Path $p) { $found += $p }
        $pnpm = Join-Path $_.FullName 'node_modules\.pnpm'
        if (Test-Path $pnpm) {
            Get-ChildItem $pnpm -Directory -Filter 'dsh-my-bot-l2@*' -ErrorAction SilentlyContinue | ForEach-Object {
                $q = Join-Path $_.FullName 'node_modules\dsh-my-bot-l2\skills\mybot-l2-workstyle'
                if (Test-Path $q) { $found += $q }
            }
        }
    }
}

if ($found.Count -eq 0) {
    Write-Host ""
    Write-Host "NOT FOUND: 没找到已安装的 dsh-my-bot-l2 包。" -ForegroundColor Yellow
    Write-Host "请先在 DSH 里装好『我的 BOT·学员版』，再运行本脚本。" -ForegroundColor Yellow
    Write-Host "或者用手动方式：把仓库里 skills/mybot-l2-workstyle 整个文件夹放到：" -ForegroundColor Yellow
    Write-Host "  $dest" -ForegroundColor Yellow
    exit 2
}

$src = $found[0]
$target = Join-Path $dest 'mybot-l2-workstyle'
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
Copy-Item $src $target -Recurse -Force

$skillFile = Join-Path $target 'SKILL.md'
$refCount = (Get-ChildItem (Join-Path $target 'references') -Filter '*.md' -ErrorAction SilentlyContinue).Count

Write-Host ""
if (Test-Path $skillFile) {
    Write-Host "OK: skill installed." -ForegroundColor Green
    Write-Host "  from : $src"
    Write-Host "  to   : $target"
    Write-Host "  files: SKILL.md + $refCount playbooks"
    Write-Host ""
    Write-Host "Next: restart DSH, start a new chat, pick persona '我的 BOT·学员版'." -ForegroundColor Cyan
} else {
    Write-Host "COPY FAILED: SKILL.md missing after copy." -ForegroundColor Red
    exit 3
}
