$path = "/Users/ootakitoshihiro/PowerShellTest/Logs"

# フォルダがなければ作る
if (-not (Test-Path $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
    Write-Host "作成完了: $path"
} else {
    Write-Host "作成済: $path"
}

# ログファイルのリスト
$logFiles = @(
    "$path/test.log",
    "$path/test2.log"
)

# タイムスタンプ作成
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$line = "[$timestamp] Backup SUCCESS"

# それぞれのログに書き込む
foreach ($logFile in $logFiles) {
    $line | Out-File $logFile -Append
    Write-Host "書き込み完了: $logFile"
}
