# ============================================================
# 项目初始化脚本
# 拉取代码后运行此脚本即可完成环境配置
# 用法：powershell -ExecutionPolicy Bypass -File install.ps1
# ============================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  鸿蒙商城项目 - 环境初始化" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 安装依赖
Write-Host "[1/2] Installing dependencies (ohpm install)..." -ForegroundColor Yellow
ohpm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] ohpm install failed!" -ForegroundColor Red
    exit 1
}

# 2. 修复 hmcore SDK ABI 兼容性问题
Write-Host "[2/2] Fixing hmcore SDK ABI compatibility..." -ForegroundColor Yellow
& "$PSScriptRoot/scripts/fix-hmcore.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  初始化完成！请在 DevEco Studio 中打开项目" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
