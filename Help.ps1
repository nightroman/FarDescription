
Import-Module FarDescription

### Update-FarDescription
@{
	command = 'Update-FarDescription'
	synopsis = 'Removes descriptions of missing items.'
	description = @'
	This cmdlet removes descriptions of missing files and folders from the
	description file. The description file is removed if it is empty after
	this update.
'@
	parameters = @{
		Path = @'
		The literal path of directory which description file is updated.
'@
		Recurse = @'
		Tells to process directories recursively.
'@
	}
}

### Sync-FarDescriptionSynopsis
@{
	command = 'Sync-FarDescriptionSynopsis'
	synopsis = 'Syncs synopses and descriptions.'
	description = @'
	It gets script synopses and sets them as file descriptions.

	If a synopsis is empty or cannot be obtained (syntax error?) then the
	cmdlet writes a warning and does not change the existing description.
'@
	parameters = @{
		Path = @'
		The literal path of directory which description file is updated.
'@
	}
}
