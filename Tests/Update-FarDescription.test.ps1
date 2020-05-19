
Import-Module FarDescription

task NoParam {
	#! used to fail
	Update-FarDescription
}

task Missing {
	$item = [IO.FileInfo]"$BuildRoot\missing"
	equals $item.FarDescription ''

	# case: Descript.ion
	Set-Content Descript.ion 'missing foo bar'
	assert (Test-Path Descript.ion)
	equals $item.FarDescription 'foo bar'

	Update-FarDescription
	assert (!(Test-Path Descript.ion))
	equals $item.FarDescription ''

	# case: Files.bbs
	Set-Content Files.bbs 'missing foo bar'
	assert (Test-Path Files.bbs)
	equals $item.FarDescription 'foo bar'

	Update-FarDescription
	assert (!(Test-Path Files.bbs))
	equals $item.FarDescription ''
}
