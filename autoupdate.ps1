function autoupdate {
    param(
        [Parameter(Mandatory = $false)]
        [Switch]$autoupdate = $false
    )
    if($autoupdate){
        $currentVersion = git rev-parse HEAD
        $lastVersion = git rev-list --tags --max-count=1
        if($currentVersion -ne $lastVersion){
            $latestTag =git describe --tags $lastVersion
            git checkout $latestTag
            start run.bat
            exit 0
        }
    }
}
