# FarDescription

Far Manager style descriptions of files and directories

***

FarDescription is the PowerShell module for managing file and directory
descriptions stored in special files.

## Quick start

**Step 1:** Get and install

FarDescription is published as the [PSGallery module](https://www.powershellgallery.com/packages/FarDescription).

You can install the module by this command:

```powershell
Install-Module FarDescription
```

**Step 2:** In a PowerShell command prompt import the module:

```powershell
Import-Module FarDescription
```

**Step 3:** Take a look at help for available commands and features:

```powershell
help about_FarDescription
Get-Command -Module FarDescription
help Update-FarDescription -Full
```

## Examples

Show items with descriptions:

```powershell
Import-Module FarDescription
Get-ChildItem | Format-Table Name, FarDescription
```

Get file description:

```powershell
Import-Module FarDescription
(Get-Item MyFile.txt).FarDescription
```

Set file description:

```powershell
Import-Module FarDescription
(Get-Item MyFile.txt).FarDescription = 'My description ...'
```

## See also

- [FarDescription Release Notes](https://github.com/nightroman/FarDescription/blob/master/Release-Notes.md)
- [about_FarDescription.help.txt](https://github.com/nightroman/FarDescription/blob/master/Module/en-US/about_FarDescription.help.txt)
