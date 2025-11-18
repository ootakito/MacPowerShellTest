$sourceDir = "/Users/ootakitoshihiro/PowerShellTest/Logs"
$archiveDir = "/Users/ootakitoshihiro/PowerShellTest/LogArchive"

if(-not(Test-Path $archiveDir)){
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
    Write-Host "アーカイブフォルダ作成: $archiveDir"
} else {
    Write-Host "アーカイブフォルダ存在: $archiveDir" 
}

$logs = Get-ChildItem $sourceDir -Filter *.log

if ($logs.Count -eq 0){
    write-Host "コピーする .log ファイルがありません"
    return
}

foreach ($log in $logs){
    $srcPath = $log.FullName
    $dstPath = Join-Path $archiveDir $log.Name

    Copy-Item $srcPath -Destination $dstPath -Force

    Write-Host "コピー完了: $srcPath -> $dstPath"
}

Write-Host "ログのアーカイブが完了しました。"
