# ================================
# 超ミニ版ロールバック(概念学習用)
# Mac用：ファイルを3世代で入れ替えるだけ
# ================================

$base = "$HOME/RollbackTest"
$current = Join-Path $base "Current"
$backup  = Join-Path $base "Backup"
$newVer  = Join-Path $base "New"

foreach ($dir in @($current, $backup, $newVer)){
  if (-not(Test-Path $dir)){
    New-Item -ItemType Directory -Path $dir | Out-Null
  }
}



"これは現在稼働中のバージョンです" | Out-File -FilePath (Join-Path $current "app.txt")
"これは新しいバージョンです"         | Out-File -FilePath (Join-Path $newVer "app.txt")

$shouldFail = Test-Path (Join-Path $newVer "fail.txt")

Remove-Item $backup -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item $current $backup -Recurse -Force
Write-Host "バックアップ作成完了"

try{
  Remove-Item $current -Recurse -Force
  Copy-Item $newVer $current -Recurse -Force
  if ($shouldFail){
    throw "疑似エラー：fail.txt があるためデプロイ失敗"
  }
  Write-Host "デプロイ成功！"
} catch {
    Write-Host "エラー発生：$($_.Exception.Message)"
    Write-Host "ロールバック開始..."

Remove-Item $current -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item $backup $current -Recurse -Force

Write-Host  "ロールバック完了（元に戻しました）"
}




Write-Host "=== 完了 ==="
