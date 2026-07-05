# ============================================================
# 修复 hmcore SDK ABI 不匹配问题
# 问题：hmcore SDK 自带 arm64-v8a 的 .so 文件，但 Windows 
#       模拟器是 x86_64 架构，导致安装时 parse native so failed
# 解决：删除 .so 文件并禁用不存在的 C++ 编译配置
# 用法：在 ohpm install 之后执行此脚本
#       powershell -ExecutionPolicy Bypass -File scripts/fix-hmcore.ps1
# ============================================================

$hmcoreBase = "oh_modules/.ohpm/@hw-agconnect+hmcore@1.0.6/oh_modules/@hw-agconnect/hmcore"

if (-not (Test-Path $hmcoreBase)) {
    Write-Host "[fix-hmcore] hmcore SDK not found, skip." -ForegroundColor Yellow
    exit 0
}

# 1. 删除 arm64-v8a 的 .so 文件
$libsDir = Join-Path $hmcoreBase "libs"
if (Test-Path $libsDir) {
    Remove-Item -Path $libsDir -Recurse -Force
    Write-Host "[fix-hmcore] Removed arm64-v8a .so files" -ForegroundColor Green
} else {
    Write-Host "[fix-hmcore] libs directory already removed" -ForegroundColor Gray
}

# 2. 禁用 C++ 编译配置（CMakeLists.txt 不存在）
$buildProfile = Join-Path $hmcoreBase "build-profile.json5"
if (Test-Path $buildProfile) {
    $content = Get-Content $buildProfile -Raw -Encoding UTF8
    if ($content -match "externalNativeOptions") {
        $fixed = @'
{
  "apiType": "stageMode",
  "buildOption": {},
  "targets": [
    {
      "name": "default",
    }
  ]
}
'@
        Set-Content $buildProfile -Value $fixed -Encoding UTF8 -NoNewline
        # append newline
        Add-Content $buildProfile -Value "" -Encoding UTF8
        Write-Host "[fix-hmcore] Disabled C++ externalNativeOptions" -ForegroundColor Green
    } else {
        Write-Host "[fix-hmcore] build-profile.json5 already fixed" -ForegroundColor Gray
    }
}

Write-Host "[fix-hmcore] Done! hmcore SDK is now compatible with x86_64 simulator." -ForegroundColor Green
