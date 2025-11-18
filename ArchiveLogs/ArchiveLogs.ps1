# ArchiveLogs.ps1

# ① 元ログフォルダとアーカイブ先フォルダのパス
$sourceDir  = "/Users/ootakitoshihiro/PowerShellTest/Logs"
$archiveDir = "/Users/ootakitoshihiro/PowerShellTest/LogArchive"

# ② アーカイブフォルダが無ければ作成
if (-not (Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
    Write-Host "アーカイブフォルダ作成: $archiveDir"
} else {
    Write-Host "アーカイブフォルダ存在: $archiveDir"
}

# ③ .log ファイルを全部取得
$logs = Get-ChildItem $sourceDir -Filter *.log

# ④ ログが1つもない場合のメッセージ
if ($logs.Count -eq 0) {
    Write-Host "コピーする .log ファイルがありません。"
    return
}

# ⑤ 1つずつアーカイブにコピー
foreach ($log in $logs) {
    $srcPath = $log.FullName
    $dstPath = Join-Path $archiveDir $log.Name

    Copy-Item $srcPath -Destination $dstPath -Force

    Write-Host "コピー完了: $srcPath -> $dstPath"
}

# ⑥ 全体メッセージ
Write-Host "ログのアーカイブが完了しました。"
