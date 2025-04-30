<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

param(
	$Configuration = 'Release',
	$TargetFramework = 'netstandard2.0'
)

Set-StrictMode -Version 3
$ModuleName = 'FarDescription'
$ModuleRoot = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName"

# Synopsis: Clean temp files.
task clean -After pushPSGallery {
	remove z, Src\bin, Src\obj, README.htm
}

# Synopsis: Update meta files.
task meta -Inputs .build.ps1, Release-Notes.md -Outputs "Module\$ModuleName.psd1", Src\Directory.Build.props -Jobs version, {
	$Project = 'https://github.com/nightroman/FarDescription'
	$Summary = 'Far Manager style descriptions of files and directories.'
	$Copyright = 'Copyright (c) Roman Kuzmin'

	Set-Content "Module\$ModuleName.psd1" @"
@{
	Author = 'Roman Kuzmin'
	ModuleVersion = '$Version'
	Description = '$Summary'
	CompanyName = 'https://github.com/nightroman'
	Copyright = '$Copyright'

	PowerShellVersion = '5.1'
	GUID = '1e7f7fc4-59c4-48c6-8847-bddef25458dd'

	RootModule = '$ModuleName.dll'
	RequiredAssemblies = '$ModuleName.dll'
	TypesToProcess = @('$ModuleName.Types.ps1xml')

	CmdletsToExport = @(
		'Sync-FarDescriptionSynopsis'
		'Update-FarDescription'
	)

	PrivateData = @{
		PSData = @{
			Tags = 'FarManager', 'Description'
			ProjectUri = '$Project'
			LicenseUri = '$Project/blob/main/LICENSE'
			ReleaseNotes = '$Project/blob/main/Release-Notes.md'
		}
	}
}
"@

	Set-Content Src\Directory.Build.props @"
<Project>
	<PropertyGroup>
		<Description>$Summary</Description>
		<Company>$Project</Company>
		<Copyright>$Copyright</Copyright>
		<Product>$ModuleName</Product>
		<Version>$Version</Version>
		<IncludeSourceRevisionInInformationalVersion>False</IncludeSourceRevisionInInformationalVersion>
	</PropertyGroup>
</Project>
"@
}

# Synopsis: Build and publish.
task build meta, {
	exec { dotnet build "Src\$ModuleName.csproj" -c $Configuration -f $TargetFramework }
}

# Synopsis: Publish the module.
task publish {
	if ($Configuration -eq 'Release') {remove $ModuleRoot}
	exec { robocopy Module $ModuleRoot /s } (0..3)
	exec { robocopy "Src\bin\$Configuration\$TargetFramework" $ModuleRoot /s } (0..3)
}

# Synopsis: Build help, https://github.com/nightroman/Helps
task help -Inputs {Get-Item Help.ps1, Src\Commands\*} -Outputs {"$ModuleRoot\en-US\$ModuleName.dll-Help.xml"} {
	. Helps.ps1
	Convert-Helps Help.ps1 $Outputs
}

# Synopsis: Build and test help.
task helps help, {
	. Helps.ps1
	Test-Helps Help.ps1
}

# Synopsis: Run tests.
task test {
	Invoke-Build ** Tests
}

# Synopsis: Test Core.
task core {
	exec { pwsh -NoProfile -Command Invoke-Build test }
}

# Synopsis: Test Desktop.
task desktop {
	exec { powershell -NoProfile -Command Invoke-Build test }
}

# Synopsis: Markdown to HTML.
task markdown {
	requires -Path $env:MarkdownCss
	exec { pandoc.exe @(
		'README.md'
		'--output=README.htm'
		'--from=gfm'
		'--embed-resources'
		'--standalone'
		"--css=$env:MarkdownCss"
		"--metadata=pagetitle=$ModuleName"
	)}
}

# Synopsis: Set $Script:Version.
task version {
	($Script:Version = Get-BuildVersion Release-Notes.md '##\s+v(\d+\.\d+\.\d+)')
}

# Synopsis: Collect package files.
task package version, markdown, {
	equals $Version (Get-Item "$ModuleRoot\$ModuleName.dll").VersionInfo.ProductVersion

	remove z
	$toModule = mkdir z\$ModuleName

	Copy-Item -Destination $toModule -Recurse @(
		'LICENSE'
		'README.htm'
		"$ModuleRoot\*"
	)

	Assert-SameFile.ps1 -Result (Get-ChildItem $toModule -Recurse -File -Name) -Text -View $env:MERGE @'
FarDescription.dll
FarDescription.pdb
FarDescription.psd1
FarDescription.types.ps1xml
LICENSE
README.htm
en-US\about_FarDescription.help.txt
en-US\FarDescription.dll-Help.xml
'@
}

# Synopsis: Publish PSGallery module.
task pushPSGallery package, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path z\$ModuleName -NuGetApiKey $NuGetApiKey
}

# Synopsis: Dev cycle.
task . build, core, desktop, helps, clean
