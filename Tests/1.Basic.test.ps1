<#
.Synopsis
	Tests FarDecription basics.

.Description
	The test shows how to get or set Far descriptions and copy, move, rename
	files and directories with their descriptions updated.
#>

Import-Module FarDescription

task Basic {
	### setup: make a test directory and a file in it
	remove z, z.2, Descript.ion
	$dirPath = "$BuildRoot\z"
	$filePath = "$dirPath\File 1"
	$null = mkdir z
	Set-Content $filePath 42

	### get the directory and file items
	# these items have extra members:
	# -- property FarDescript (both)
	# -- method FarMoveTo() (both)
	# -- method FarCopyTo() (file)
	$dirItem = Get-Item $dirPath
	$fileItem = Get-Item $filePath

	### set descriptions
	# use not ASCII text, head Alt+160 (to stay), and tail space (to go)
	$dirItem.FarDescription = ' Тест описания папки '
	$fileItem.FarDescription = ' Тест описания файла '
	assert (Test-Path Descript.ion)
	assert (Test-Path z\Descript.ion)
	equals $dirItem.FarDescription ' Тест описания папки'
	equals $fileItem.FarDescription ' Тест описания файла'

	### copy the file with description
	$fileItem2 = $fileItem.FarCopyTo("$filePath.txt")
	equals $fileItem2.FarDescription ' Тест описания файла'

	### move (rename) the file with description
	$fileItem2.FarMoveTo("$filePath.tmp")
	equals $fileItem2.Name 'File 1.tmp'
	equals $fileItem2.FarDescription ' Тест описания файла'

	### drop the 1st file description; test 2nd file description
	$fileItem.FarDescription = ''
	equals $fileItem.FarDescription ''
	assert (Test-Path "$dirPath\Descript.ion")
	equals $fileItem2.FarDescription ' Тест описания файла'

	### drop the 2nd file description; Descript.ion is dropped, too
	$fileItem2.FarDescription = ''
	equals $fileItem2.FarDescription ''
	assert (!(Test-Path "$dirPath\Descript.ion"))

	### set the 1st description, then delete the file; Descript.ion is created, then dropped
	$fileItem.FarDescription = 'Тест удаления с описанием'
	assert (Test-Path "$dirPath\Descript.ion")
	equals $fileItem.FarDescription 'Тест удаления с описанием'
	$fileItem.FarDelete()
	equals $fileItem.FarDescription ''
	assert (!(Test-Path "$dirPath\Descript.ion"))

	### move (rename) the directory with description
	$dirItem.FarMoveTo("$dirPath.2")
	equals $dirItem.Name 'z.2'
	equals $dirItem.FarDescription ' Тест описания папки'

	### drop the directory description
	$dirItem.FarDescription = ''
	equals $dirItem.FarDescription ''

	### end
	remove $dirItem.FullName
}
