
// FarDescription module
// Copyright (c) Roman Kuzmin

using System.IO;
using System.Management.Automation;

namespace FarDescription.Internal
{
	[Cmdlet(VerbsData.Update, Res.Noun)]
	public sealed class UpdateFarDescriptionCommand : PSCmdlet
	{
		[Parameter(Position = 0)]
		public string Path { get; set; }

		[Parameter]
		public SwitchParameter Recurse { get; set; }

		static void Update(string directory, bool recurce)
		{
			var file = Description.GetDescriptionFile(directory, out bool exists);
			if (exists)
				Description.UpdateDescriptionFile(file);

			if (recurce)
			{
				foreach (var child in Directory.GetDirectories(directory))
					Update(child, true);
			}
		}

		protected override void BeginProcessing()
		{
			Path = GetUnresolvedProviderPathFromPSPath(Path ?? "");
			Update(Path, Recurse);
		}
	}
}
