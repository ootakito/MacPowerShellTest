# Register-MacDailyTask.ps1
# macOS 用：毎日指定時刻に ps1 を実行する launchd タスク登録

function Register-MacDailyTask {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,   # 実行したい ps1（フルパス）

        [Parameter(Mandatory)]
        [int]$Hour,            # 0-23
        [int]$Minute = 0,
        [string]$Label = "com.example.logarchive.daily"
    )

    if (-not $IsMacOS) {
        throw "この関数は macOS 専用です。"
    }

    # PowerShell 本体のパス（pwsh）
    $pwshPath = (Get-Command pwsh).Source

    # LaunchAgents のパスを組み立て
    $launchAgentsDir = Join-Path $HOME "Library/LaunchAgents"
    if (-not (Test-Path $launchAgentsDir)) {
        New-Item -ItemType Directory -Path $launchAgentsDir -Force | Out-Null
    }

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

    $dest = Join-Path $launchAgentsDir "$Label.plist"

    # UTF-8 で plist を出力（変な文字防止！）
    $plist | Out-File -FilePath $dest -Encoding utf8

    # 一旦 unload → load し直し
    launchctl unload "$dest" 2>$null
    launchctl load "$dest"

    Write-Host "登録完了: $dest を 毎日 $Hour:$('{0:D2}' -f $Minute) に実行"
}

# ==== ここから下は「実際の登録コマンド」の例 ====

# 実際に動かしたい ps1 のフルパスに変える
# 例: /Users/ootaki/ps/LogArchive.ps1
$targetScript = "/Users/あなたのユーザー名/ps/LogArchive.ps1"

# 毎日 3:00 に実行する例
Register-MacDailyTask -ScriptPath $targetScript -Hour 3 -Minute 0 -Label "com.example.logarchive.daily"
