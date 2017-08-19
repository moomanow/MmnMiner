function autoupdate {
    param(
        [Parameter(Mandatory = $false)]
        [Switch]$autoupdate = $false
    )
    if($autoupdate){
        $lastVersion = git rev-list --tags --max-count=1
        $latestTag =git describe --tags $lastVersion
        git checkout $latestTag
        exit 0
    }
}
