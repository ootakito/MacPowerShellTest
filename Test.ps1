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

function Invoke-LogArchive{
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDir,

        [Parameter(Mandatory = $true)]
        [string]$ArchiveDir,

        [Parameter(Mandatory = $true)]
        [string]$LogFile
        
    )

    $ErrorActionPreference = 'Stop'

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    try{
        if(-not(Test-Path $ArchiveDir)){
            New-Item -ItemType Directory -path $ArchiveDir | Out-Null
            Write-Host "アーカイブフォルダ作成: $ArchiveDir"
            "$timestamp INFO  アーカイブフォルダ作成:  $ArchiveDir" | Out-File $LogFile -Append
        }else{
            Write-Host "アーカイブフォルダ存在: $ArchiveDir" | Out-File $LogFile -Append
            "$timestamp INFO アーカイブフォルダ存在: $ArchiveDir" | Out-File $LogFile -Append
        }

        $logs = Get-ChildItem -path $SourceDir -Filter *.log

        if(-not $logs -or $logs.Count -eq 0){
            Write-Host "コピーする .log ファイルがありません"
            "$timestamp INFO コピーする .logファイルがありません" | Out-File $LogFile -Append
            return 0
        }

        foreach ( $log in $logs){
            $srcPath = $log.FullName
            $dstPath = Join-Path $ArchiveDir $log.Name

            Copy-Item $srcPath -Destination $dstPath -Force

            Write-Host "コピー完了: $srcPath -> $dstPath"

            "$timestamp INFO コピー完了: $srcPath -> $dstPath" | Out-File $LogFile -Append
        }

        Write-Host "ログのアーカイブが完了しました。"
        "$timestamp INFO ログのアーカイブが正常終了しました。" | Out-File $LogFile -Append

        return 0

        
    } catch {
        $errMsg = $_.Exception.Message

        Write-Host "エラー発生: $errMsg" | Out-File $LogFile -Append
        
        return 1
    }
}

$SourceDir = "/Users/ootakitoshihiro/PowerShellTest/Logs"
$archiveDir = "/Users/ootakitoshihiro/PowerShellTest/LogArchive"
$logFile = "/Users/ootakitoshihiro/PowerShellTest/archive.log"

$exitCode = Invoke-LogArchive -SourceDir $sourceDir -ArchiveDir $archiveDir -LogFile $logFile

Write-Host "スクリプト終了コード: $exitCode"