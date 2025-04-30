using System.Management.Automation;

namespace FarDescription.Commands;

[Cmdlet(VerbsData.Sync, Res.NounSynopsis)]
public sealed class SyncFarDescriptionSynopsisCommand : PSCmdlet
{
	[Parameter(Position = 0)]
	public string Path { get; set; }

	protected override void BeginProcessing()
	{
		Path = GetUnresolvedProviderPathFromPSPath(Path ?? "");

		var descriptionFile = Description.GetDescriptionFile(Path, out _);
		var map = Description.Import(descriptionFile);

		var script = ScriptBlock.Create("Get-Help -Name:$args[0] -Category:ExternalScript -ErrorAction:Stop");
		var separators = new char[] { '\r', '\n' };

		var change = 0;
		foreach (var file in Directory.GetFiles(Path, "*.ps1"))
		{
			try
			{
				var obj = script.InvokeReturnAsIs(file);
				if (obj == null)
					continue;

				var help = PSObject.AsPSObject(obj);
				string newText;
				if (help.BaseObject is string)
				{
					newText = string.Empty;
				}
				else
				{
					var synopsis = help.Properties["Synopsis"];

					if (synopsis == null || synopsis.Value == null)
					{
						newText = string.Empty;
					}
					else
					{
						var text = synopsis.Value.ToString();
						var lines = text.Split(separators, StringSplitOptions.RemoveEmptyEntries);
						newText = lines.Length == 0 ? string.Empty : lines[0].Trim();
					}
				}

				var key = System.IO.Path.GetFileName(file);
				if (map.TryGetValue(key, out string oldText))
				{
					if (newText == oldText)
						continue;
				}

				// check synopsis
				if (newText.Length == 0)
				{
					// do not change anything if synopsis is empty.
					WriteWarning($"{file}: Cannot get script synopsis.");
				}
				else
				{
					// set valid synopsis
					++change;
					map[key] = newText;
				}
			}
			catch (RuntimeException exn)
			{
				WriteWarning($"{file}: {exn.Message}");
			}
		}

		if (change > 0)
			Description.Export(descriptionFile, map);
	}
}
