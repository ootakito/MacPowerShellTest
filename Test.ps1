# ===== Mac 用に書き換えたバックアップスクリプト =====

# $path = "/Users/ootakitoshihiro/PowerShellTest"
# $backupDir = "/Users/ootakitoshihiro/PowerShellBackup"

# 元フォルダが無ければ作成
# if (-not (Test-Path $path)) {
#     New-Item -ItemType Directory -Path $path | Out-Null
#     Write-Host "作成完了: $path"
# } else {
#     Write-Host "作成済: $path"
# }

# 元ファイル作成
# $srcFile = "$path/sample.txt"
# "Hello!" | Out-File $srcFile
# Write-Host "元ファイルを作成しました: $srcFile"

# バックアップフォルダ確認
# if (-not (Test-Path $backupDir)) {
#     New-Item -ItemType Directory -Path $backupDir | Out-Null
#     Write-Host "バックアップフォルダ作成: $backupDir"
# } else {
#     Write-Host "バックアップフォルダ存在: $backupDir"
# }

# バックアップ実行
# $dstFile = "$backupDir/sample.txt"
# Copy-Item $srcFile -Destination $dstFile -Force
# Write-Host "バックアップ済: $dstFile"

# ログ出力
# $logFile = "$backupDir/back.log"
# $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# "[$timestamp] Backup SUCCESS → $dstFile" | Out-File $logFile -Append

$path = "/Users/ootakitoshihiro/PowerShellTest/Logs"

if (-not (Test-Path $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
    Write-Host "作成完了: $path"
} else {
    Write-Host "作成済: $path"
}

$logFiles = @{
    "$path/test.log",
    "$path/test2.log"
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$line = "[$timestamp] Backup SUCCESS " 

foreach ($logFile in logFiles){
    $line | Out-File $logFile -Append
    write-Host "書き込み完了:logFile"
}
