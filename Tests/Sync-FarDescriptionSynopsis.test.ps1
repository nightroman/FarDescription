
Import-Module FarDescription

task Basic {
	remove z
	$null = mkdir z

	# case: two lines synopsis
	Set-Content z\z.ps1 @'
<#
.Synopsis
	line1
	line2
#>
'@

	Sync-FarDescriptionSynopsis z

	# two files in z
	$r = @(Get-ChildItem z -Force)
	equals $r.Count 2
	equals $r[0].Name Descript.ion
	equals $r[1].Name z.ps1
	equals $r[1].FarDescription line1

	#! case: empty synopsis, used to fail
	Set-Content z\z.ps1 @'
<#
.Synopsis
#>
'@

	Sync-FarDescriptionSynopsis z

	# still two files, preserved description
	$r = @(Get-ChildItem z -Force)
	equals $r.Count 2
	equals $r[0].Name Descript.ion
	equals $r[1].Name z.ps1
	equals $r[1].FarDescription line1

	remove z
}
