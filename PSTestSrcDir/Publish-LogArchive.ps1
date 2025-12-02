param(
    [Parameter(Mandatory)]
    [string]$Version,

    [string]$ShareRoot = "$HOME/LogArchiveShare",

    [string[]] $ServerRoots = @(
        "$HOME/Servers/ServerA",
        "$HOME/Servers/ServerB"
    )
)

function Copy-ToServer{
    param([string]$ServerRoot)

    $sourceVersionDir = Join-Path $ShareRoot "versions/$Version"

    if (-not(Test-Path $sourceVersionDir)){
        throw "Source version folder not found: $sourceVersionDir"
    }

    $releasesRoot = Join-Path $ServerRoots "releases"

    if (-not(Test-Path $releasesRoot)){
        New-Item -ItemType Directory -Path $releasesRoot | Out-Null
    }

    if (Test-Path $destVersionDir){
        Write-Host "[$ServerRoot] version $Version already exists. Skipping copy."
    } else {
        $srcPattern = Join-Path $sourceVersionDir "*"
        Copy-Item -Path $srcPattern -Destination $destVersionDir -Recurse
        Write-Host "[$ServerRoot] Copied version $Version"
    }

    $currentLink = Join-Path $ServerRoots "current"

    if (Test-Path $currentLink){
        Remove-Item $currentLink
    }

    New-Item -ItemType SymbolicLink -Path $currentLink -Target $destVersionDir | Out-Null
    Write-Host "[$ServerRoot] current -> $destVersionDir"

    foreach ($server in $ServerRoots){
        Copy-ToServer $server
    }
}

