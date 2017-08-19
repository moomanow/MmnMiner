. .\Include.ps1

try {
    $Zpool_Request = Invoke-WebRequest "http://www.zpool.ca/api/status" -UseBasicParsing | ConvertFrom-Json
}
catch {
    return
}

if (-not $Zpool_Request) {return}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Location = "US"

[double]$base = 0.00200

$Zpool_Request | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    $Zpool_Host = "$_.mine.zpool.ca"
    $Zpool_Port = $Zpool_Request.$_.port
    $Zpool_Algorithm = Get-Algorithm $Zpool_Request.$_.name
    $Zpool_Coin = ""

    $Divisor = 1000000

    switch ($Zpool_Algorithm) {
        "equihash" {$Divisor /= 1000}
        "blake2s" {$Divisor *= 1000}
        "blakecoin" {$Divisor *= 1000}
        "decred" {$Divisor *= 1000}
        "x11" {$Divisor *= 1000}
        "qubit" {$Divisor *= 1000}
        "quark" {$Divisor *= 1000}
        "sha256" {$Divisor *= 1000000}
        "yescrypt" {$Divisor /= 1000}
    }

    if ((Get-Stat -Name "$($Name)_$($Zpool_Algorithm)_Profit") -eq $null) {$Stat = Set-Stat -Name "$($Name)_$($Zpool_Algorithm)_Profit" -Value ([Double]$Zpool_Request.$_.estimate_last24h / $Divisor)}
    else {$Stat = Set-Stat -Name "$($Name)_$($Zpool_Algorithm)_Profit" -Value ([Double]$Zpool_Request.$_.estimate_current / $Divisor)}
    if ($Wallet) {
        [PSCustomObject]@{
            Algorithm     = $Zpool_Algorithm
            Info          = $Zpool_Coin
            #Price         = $Stat.Live
            #Price         = $Stat.Minute
            #Price         = $Stat.Minute_5
            #Price         = $Stat.Minute_10
            #Price         = $Stat.Minute_15
            Price         = $Stat.Minute_30
            #Price         = $Stat.Hour
            StablePrice   = $Stat.Week
            MarginOfError = $Stat.Week_Fluctuation
            DecayPeriod        = 45 #seconds
            DecayBase          = 1-0.01 #decimal percentage
            ProfitMorthanBase  = 1-0.05 #decimal percentage
            Protocol      = "stratum+tcp"
            Host          = $Zpool_Host
            Port          = $Zpool_Port
            User          = $Wallet
            Pass          = "$WorkerName,c=BTC,stats"
            Location      = $Location
            SSL           = $false
        }
    }
}
