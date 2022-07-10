<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

param(
	$Configuration = 'Release',
	$TargetFramework = 'netstandard2.0'
)

Set-StrictMode -Version 3
$ModuleName = 'FarDescription'
$ModuleRoot = "$(if ($_=$env:ProgramW6432) {$_} else {$env:ProgramFiles})\WindowsPowerShell\Modules\$ModuleName"

# Get version from release notes.
function Get-Version {
	switch -Regex -File Release-Notes.md {'##\s+v(\d+\.\d+\.\d+)' {return $Matches[1]} }
}

# Synopsis: Clean the workspace.
task clean {
	remove z, Src\bin, Src\obj, README.htm
}

$MetaParam = @{
	Inputs = '.build.ps1', 'Release-Notes.md'
	Outputs = "Module\$ModuleName.psd1", 'Src\AssemblyInfo.cs'
}

# Synopsis: Generate or update meta files.
task meta @MetaParam {
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
			LicenseUri = '$Project/blob/master/LICENSE'
			ReleaseNotes = '$Project/blob/master/Release-Notes.md'
		}
	}
}
"@

	Set-Content Src\Directory.Build.props @"
<Project>
	<PropertyGroup>
		<Company>$Project</Company>
		<Copyright>$Copyright</Copyright>
		<Description>$Summary</Description>
		<Product>$ModuleName</Product>
		<Version>$Version</Version>
		<FileVersion>$Version</FileVersion>
		<AssemblyVersion>$Version</AssemblyVersion>
	</PropertyGroup>
</Project>
"@
}

# Synopsis: Build the project (and post-build Publish).
task build meta, {
	exec { dotnet build "Src\$ModuleName.csproj" -c $Configuration -f $TargetFramework }
}

# Synopsis: Publish the module (post-build).
task publish {
	if ($Configuration -eq 'Release') {remove $ModuleRoot}
	exec { robocopy Module $ModuleRoot /s /np /r:0 /xf *-Help.ps1 } (0..3)
	exec { robocopy "Src\bin\$Configuration\$TargetFramework" $ModuleRoot /s /np /r:0 } (0..3)
}

# Synopsis: Build help by Helps (https://github.com/nightroman/Helps).
task help @{
	Inputs = {Get-Item Src\Commands\*, Module\en-US\$ModuleName.dll-Help.ps1}
	Outputs = {"$ModuleRoot\en-US\$ModuleName.dll-Help.xml"}
	Jobs = {
		. Helps.ps1
		Convert-Helps Module\en-US\$ModuleName.dll-Help.ps1 $Outputs
	}
}

# Synopsis: Make an test help.
task testHelp help, {
	. Helps.ps1
	Test-Helps Module\en-US\$ModuleName.dll-Help.ps1
}

# Synopsis: Test current PowerShell.
task test {
	$ErrorView = 'NormalView'
	Invoke-Build ** Tests
}

# Synopsis: Test PS Core.
task test7 {
	exec {pwsh -NoProfile -Command Invoke-Build test}
}

# Synopsis: Convert markdown to HTML.
task markdown {
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
task version {
	($script:Version = Get-Version)
	# manifest version
	$data = & ([scriptblock]::Create([IO.File]::ReadAllText("$ModuleRoot\$ModuleName.psd1")))
	assert ($data.ModuleVersion -eq $script:Version)
	# assembly version
	assert ((Get-Item $ModuleRoot\$ModuleName.dll).VersionInfo.FileVersion -eq ([Version]"$script:Version"))
}

# Synopsis: Make the package in z.
task package build, help, testHelp, test, test7, markdown, {
	remove z
	$null = mkdir "z\$ModuleName"

	Copy-Item -Recurse -Destination "z\$ModuleName" $(
		'LICENSE'
		'README.htm'
		"$ModuleRoot\*"
	)

	$packageItemCount = @(Get-ChildItem "z\$ModuleName" -Recurse).Length
	equals $packageItemCount 10
}

# Synopsis: Make and push the PSGallery package.
task pushPSGallery package, version, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path z\$ModuleName -NuGetApiKey $NuGetApiKey
},
clean

# Synopsis: Fast dev round.
task . build, help, test, clean
