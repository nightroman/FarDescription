namespace FarDescription;

/// <summary>
/// Global settings. Names are original Far names.
/// </summary>
public sealed class Settings
{
	public static Settings Default { get; } = new Settings()
	{
		ListNames = ["Descript.ion", "Files.bbs"],
		SaveInUTF = true,
		SetHidden = true
	};
	public string[] ListNames { get; set; }
	public bool AnsiByDefault { get; set; }
	public bool SaveInUTF { get; set; }
	public bool SetHidden { get; set; }
}
