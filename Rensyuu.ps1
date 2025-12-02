function Show-Info {
    param(
        $Name = "Guest",
        $Age  = 20,
        $Country = "USA"
    )

    Write-Host "Name: $Name"
    Write-Host "Age: $Age"
    Write-Host "Country: $Country"
}
Show-Info -Name "Toshi" -Age 35 -Country "Japan"
