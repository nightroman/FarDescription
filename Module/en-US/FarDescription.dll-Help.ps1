
Import-Module FarDescription

### Update-FarDescription
@{
	command = 'Update-FarDescription'
	synopsis = 'Removes descriptions of missing items.'
	description = @'
This cmdlet removes descriptions of missing files and folders from the description file.
The description file is removed if it is empty after this update.
'@
	parameters = @{
		Path = 'Specifies the literal path of directory which description file is updated.'
		Recurse = 'Tells to process child directories recursively.'
	}
}

### Sync-FarDescriptionSynopsis
@{
	command = 'Sync-FarDescriptionSynopsis'
	synopsis = 'Syncs synopses and descriptions.'
	description = @'
This cmdlet gets script synopses and sets them as file descriptions.

If a synopsis is empty or cannot be obtained for some reasons (syntax error) then
the cmdlet writes a warning and does not change the existing description, if any.
'@
	parameters = @{
		Path = 'Specifies the literal path of directory which description file is updated.'
	}
}
