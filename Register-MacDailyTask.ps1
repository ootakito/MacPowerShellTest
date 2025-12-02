# Register-MacDailyTask.ps1
# macOS 用：毎日指定時刻に LogArchive.ps1 を実行する launchd タスクを登録

# 実行したい ps1 のフルパス（ここは自分の環境に合わせて）
$targetScript = "/Users/ootakitoshihiro/MacPowerShellTest/LogArchive.ps1"

function Register-MacDailyTask {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,   # 実行したい ps1（フルパス）

        [Parameter(Mandatory)]
        [int]$Hour,            # 0-23

        [int]$Minute = 0,
        [string]$Label = "com.example.logarchive.daily"
    )

    # macOS 以外では使わせない
    if (-not $IsMacOS) {
        throw "この関数はmacOS専用です。"
    }

    # pwsh のフルパス取得
    $pwshPath = (Get-Command pwsh).Source

    # LaunchAgents のパスを組み立て
    $launchAgentsDir = Join-Path $HOME "Library/LaunchAgents"

    # フォルダがなければ作成
    if (-not (Test-Path $launchAgentsDir)) {
        New-Item -ItemType Directory -Path $launchAgentsDir -Force | Out-Null
    }

    # plist の出力先（Label をそのままファイル名に）
    $dest = Join-Path $launchAgentsDir "$Label.plist"

    # plist 本体
    $plist = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$Label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$pwshPath</string>
    <string>-File</string>
    <string>$ScriptPath</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>$Hour</integer>
    <key>Minute</key><integer>$Minute</integer>
  </dict>
  <key>StandardOutPath</key><string>/tmp/$Label.out</string>
  <key>StandardErrorPath</key><string>/tmp/$Label.err</string>
</dict>
</plist>
"@

    # UTF-8 で plist を出力
    $plist | Out-File -FilePath $dest -Encoding utf8

    # 一旦 unload → load し直し
    launchctl unload "$dest" 2>$null
    launchctl load "$dest"

    # 登録完了メッセージ
    Write-Host ("登録完了: {0} を 毎日 {1}:{2:D2} に実行" -f $dest, $Hour, $Minute)
}

# ==== 実際の登録コマンド呼び出し部分 ====
# 今の時刻 + 数分に合わせて Hour / Minute を変えてテスト
Register-MacDailyTask `
  -ScriptPath $targetScript `
  -Hour 16 `
  -Minute 31 `
  -Label "com.example.logarchive.daily"
