
Import-Module FarDescription

# Test default and changed settings, restore defaults.
task SettingsDefaultAndChange {
	$ListNames = [FarDescription.Settings]::Default.ListNames
	equals ($ListNames -join '#') 'Descript.ion#Files.bbs'
	[FarDescription.Settings]::Default.ListNames = 'bar'
	equals ([FarDescription.Settings]::Default.ListNames[0]) bar
	[FarDescription.Settings]::Default.ListNames = $ListNames

	$AnsiByDefault = [FarDescription.Settings]::Default.AnsiByDefault
	equals $AnsiByDefault $false
	[FarDescription.Settings]::Default.AnsiByDefault = $true
	equals ([FarDescription.Settings]::Default.AnsiByDefault) $true
	[FarDescription.Settings]::Default.AnsiByDefault = $AnsiByDefault

	$SaveInUTF = [FarDescription.Settings]::Default.SaveInUTF
	equals $SaveInUTF $true
	[FarDescription.Settings]::Default.SaveInUTF = $false
	equals ([FarDescription.Settings]::Default.SaveInUTF) $false
	[FarDescription.Settings]::Default.SaveInUTF = $SaveInUTF

	$SetHidden = [FarDescription.Settings]::Default.SetHidden
	equals $SetHidden $true
	[FarDescription.Settings]::Default.SetHidden = $false
	equals ([FarDescription.Settings]::Default.SetHidden) $false
	[FarDescription.Settings]::Default.SetHidden = $SetHidden
}
