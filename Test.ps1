function Invoke-LogArchive {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDir,
        # (Mandatory = $true)は本当に存在するか[string]$SourceDirで引数の型は指定する
        [Parameter(Mandatory = $true)]
        [string]$ArchiveDir,

        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )

    $ErrorActionPreference = 'Stop'

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    try{
        if(-not(Test-Path $ArchiveDir) ){
            New-Item -ItemType Directory -Path $ArchiveDir | Out-Null
            # Out-Nullは余計なログを出させない工夫
            Write-Host "アーカイブフォルダ作成: $ArchiveDir"
            "$timestamp INFO アーカイブフォルダ作成: $ArchiveDir" | Out-File $LogFile -Append
            # Out-Fileはファイルに書くという意味この場合、ログファイルに書いてる
        } else {
            Write-Host "アーカイブフォルダ存在: $ArchiveDir"
            "$timestamp INFO アーカイブフォルダ存在: $ArchiveDir" | Out-File $LogFile -Append
        }

        $logs = Get-ChildItem -Path $SourceDir -Filter *.log

    if(-not $logs -or $logs.Count -eq 0){
        write-Host "コピーする.logファイルがありません。"
        "$timestamp INFO  コピーする .logファイルがありません" | Out-File $LogFile -Append
        return 0
        # return 0は成功という処理で1だと失敗処理になる
    }

    foreach ($log in $logs){
        $srcPath = $log.FullName
        # $log.FullNameは$log内のフルパスを取り出してる。
        $dstPath = Join-Path $ArchiveDir $log.Name
        # Join-Path $ArchiveDir $log.NameでJoin-Pathはパスの結合になるこの場合$ArchiveDir $log.Nameが結合してパスが出来る
        Copy-Item $srcPath -Destination $dstPath -Force
        # Copy-Item $srcPath -Destination $dstPath -Force　-Destinationは保存先の指定で構文はCopy-Item <コピー元> -Destination <コピー先>
        # -Forceは何があっても強制的に動かす、$srcPathの内容を$dstPathに強制的に上書きしてよい感じになる
        Write-Host "コピー完了: $srcPath -> $dstPath"
        "$timestamp INFO コピー完了: $srcPath -> $dstPath" | Out-File $LogFile -Append
    }

    Write-Host "ログのアーカイブが完了しました。"
    "$timestamp INFO  ログのアーカイブが正常終了しました。" | Out-File $LogFile -Append
    return 0
    } catch {
        $errMsg = $_.Exception.Message
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        # $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"はローカルスコープ内で記述すれば正確な時間がわかる。
        Write-Host "エラー発生(アーカイブ): $errMsg" -ForegroundColor Red
        # -ForegroundColor 色を付ける
        "$timestamp ERROR アーカイブ中にエラー: $errMsg" | Out-File $logFile -Append
        return 1
    }

}

function Test-LogError {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )

    $ErrorActionPreference = 'Stop'

    try{
        if(-not(Test-Path $LogFile)){
            Write-Host "ログファイルが存在しません: $LogFile" -ForegroundColor Yellow
            return 1   # 無い時はエラー扱いにしておく
        }

        $content = Get-Content -Path $logFile
        # Get-Contentは読み取る-Pathは指定する何を読み取るか
        if($content -match "ERROR"){
            Write-Host "ログにERRORが含まれてます。" -ForegroundColor Red
            return 1 
        }else{
            Write-Host "ログにERRORはありません。" -ForegroundColor Green
            return 0
        }   
    } catch {
        $errMsg = $_.Exception.Message
        Write-Host "エラー発生(ERROR判定) : $errMsg" -ForegroundColor Red
        return 1    
    }
}

$sourceDir = "/Users/ootakitoshihiro/PowerShellTest/Logs"
$archiveDir = "/Users/ootakitoshihiro/PowerShellTest/LogArchive"
$logFile = "/Users/ootakitoshihiro/PowerShellTest/archive.log"

$archiveExit = Invoke-LogArchive -SourceDir $sourceDir -ArchiveDir $archiveDir -LogFile $logFile
# 関数を呼び出して失敗か成功か判断してる-SourceDirの-は引数$sourceDirが-SourceDirになり関数の引数になる
Write-Host "アーカイブ終了コード: $archiveExit"

if ($archiveExit -ne 0){
    # -neはノットイコールつまりreturnで帰ってきたのが0以外ならという意味になる
    Write-Host "アーカイブに失敗したため、ERRORチェックはスキップします。" -ForegroundColor Red
    exit $archiveExit
}

$checkExit = Test-LogError -LogFile $logFile
Write-Host "ERROR チェック終了コード: $checkExit"

exit $checkExit
