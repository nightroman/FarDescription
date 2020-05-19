<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

param(
	$Configuration = 'Release',
	$TargetFrameworkVersion = 'v3.5'
)

Set-StrictMode -Version 2
$ModuleName = 'FarDescription'
$ModuleRoot = "$(if ($_=$env:ProgramW6432) {$_} else {$env:ProgramFiles})\WindowsPowerShell\Modules\$ModuleName"

# Get version from release notes.
function Get-Version {
	switch -Regex -File Release-Notes.md {'##\s+v(\d+\.\d+\.\d+)' {return $Matches[1]} }
}

# Synopsis: Clean the workspace.
task Clean {
	remove z, Src\bin, Src\obj, README.htm
}

$MetaParam = @{
	Inputs = '.build.ps1', 'Release-Notes.md'
	Outputs = "Module\$ModuleName.psd1", 'Src\AssemblyInfo.cs'
}

# Synopsis: Generate or update meta files.
task Meta @MetaParam {
	$Version = Get-Version
	$Project = 'https://github.com/nightroman/FarDescription'
	$Summary = 'Far Manager style descriptions of files and directories.'
	$Copyright = 'Copyright (c) Roman Kuzmin'

	Set-Content Module\$ModuleName.psd1 @"
@{
	Author = 'Roman Kuzmin'
	ModuleVersion = '$Version'
	Description = '$Summary'
	CompanyName = 'https://github.com/nightroman'
	Copyright = '$Copyright'

	PowerShellVersion = '2.0'
	GUID = '{1e7f7fc4-59c4-48c6-8847-bddef25458dd}'

	ModuleToProcess = '$ModuleName.dll'
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
			LicenseUri = '$Project/blob/master/LICENSE.txt'
			ReleaseNotes = '$Project/blob/master/Release-Notes.md'
		}
	}
}
"@

	Set-Content Src\AssemblyInfo.cs @"
using System;
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyProduct("$ModuleName")]
[assembly: AssemblyVersion("$Version")]
[assembly: AssemblyCompany("$Project")]
[assembly: AssemblyTitle("$ModuleName")]
[assembly: AssemblyDescription("$Summary")]
[assembly: AssemblyCopyright("$Copyright")]

[assembly: ComVisible(false)]
[assembly: CLSCompliant(false)]
"@
}

# Synopsis: Build the project (and post-build Publish).
task Build Meta, {
	exec { & (Resolve-MSBuild) @(
		"Src\$ModuleName.csproj"
		'/t:Build'
		'/verbosity:minimal'
		"/p:Configuration=$Configuration"
		"/p:TargetFrameworkVersion=$TargetFrameworkVersion"
	)}
}

# Synopsis: Publish the module (post-build).
task Publish {
	if ($Configuration -eq 'Release') {remove $ModuleRoot}
	exec { robocopy Module $ModuleRoot /s /np /r:0 /xf *-Help.ps1 } (0..3)
	exec { robocopy Src\bin\$Configuration $ModuleRoot /s /np /r:0 } (0..3)
}

# Synopsis: Build help by Helps (https://github.com/nightroman/Helps).
task Help @{
	Inputs = {Get-Item Src\Commands\*, Module\en-US\$ModuleName.dll-Help.ps1}
	Outputs = {"$ModuleRoot\en-US\$ModuleName.dll-Help.xml"}
	Jobs = {
		. Helps.ps1
		Convert-Helps Module\en-US\$ModuleName.dll-Help.ps1 $Outputs
	}
}

# Synopsis: Make an test help.
task TestHelp Help, {
	. Helps.ps1
	Test-Helps Module\en-US\$ModuleName.dll-Help.ps1
}

# Synopsis: Test in the current PowerShell.
task Test {
	$ErrorView = 'NormalView'
	Invoke-Build ** Tests
}

# Synopsis: Test in PowerShell v2.
task Test2 {
	exec {powershell -Version 2 -NoProfile -Command Invoke-Build Test}
}

# Synopsis: Test in PowerShell v6.
task Test6 -If $env:powershell6 {
	exec {& $env:powershell6 -NoProfile -Command Invoke-Build Test}
}

# Synopsis: Convert markdown to HTML.
task Markdown {
	assert (Test-Path $env:MarkdownCss)
	exec { pandoc.exe @(
		'README.md'
		'--output=README.htm'
		'--from=gfm'
		'--self-contained', "--css=$env:MarkdownCss"
		'--standalone', "--metadata=pagetitle=$ModuleName"
	)}
}

# Synopsis: Set $script:Version.
task Version {
	($script:Version = Get-Version)
	# manifest version
	$data = & ([scriptblock]::Create([IO.File]::ReadAllText("$ModuleRoot\$ModuleName.psd1")))
	assert ($data.ModuleVersion -eq $script:Version)
	# assembly version
	assert ((Get-Item $ModuleRoot\$ModuleName.dll).VersionInfo.FileVersion -eq ([Version]"$script:Version.0"))
}

# Synopsis: Make the package in z.
task Package Build, Help, TestHelp, Test, Test2, Test6, Markdown, {
	remove z
	$null = mkdir z\$ModuleName

	Copy-Item -Recurse -Destination z\$ModuleName $(
		'LICENSE.txt'
		'README.htm'
		"$ModuleRoot\*"
	)
}

# Synopsis: Make and push the PSGallery package.
task PushPSGallery Package, Version, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path z\$ModuleName -NuGetApiKey $NuGetApiKey
},
Clean

# Synopsis: Fast dev round.
task . Build, Help, Test, Clean
