using System.Management.Automation;
using System.Runtime.InteropServices;

namespace FarDescription;

/// <summary>
/// This class exposes some Windows API native methods.
/// </summary>
static class NativeMethods //! name ~ FxCop
{
	[DllImport("Kernel32.dll", CharSet = CharSet.Unicode)]
	internal static extern int GetOEMCP();
}

/// <summary>
/// Infrastructure.
/// </summary>
public static class CodeMethods
{
	/// <summary>
	/// Gets Far description for the FS item.
	/// </summary>
	public static string FileSystemInfoGetFarDescription(PSObject instance)
	{
		if (instance == null)
			throw new ArgumentNullException("instance");

		if (instance.BaseObject is FileSystemInfo info)
			return Description.Get(info.FullName);
		else
			return string.Empty;
	}

	/// <summary>
	/// Sets Far description for the FS item.
	/// </summary>
	public static void FileSystemInfoSetFarDescription(PSObject instance, string value)
	{
		if (instance == null)
			throw new ArgumentNullException("instance");

		if (instance.BaseObject is FileSystemInfo info)
			Description.Set(info.FullName, value);
	}

	/// <summary>
	/// Moves the file or directory with its Far description.
	/// </summary>
	/// <remarks>
	/// It is a wrapper of <c>System.IO.FileInfo.MoveTo()</c> and <c>System.IO.DirectoryInfo.MoveTo()</c>:
	/// in addition it moves the Far description.
	/// </remarks>
	public static object FileSystemInfoMoveTo(PSObject instance, string value)
	{
		if (instance == null)
			throw new ArgumentNullException("instance");

		if (instance.BaseObject is not FileSystemInfo info)
			return null;

		string path = info.FullName;
		string desc = Description.Get(path);

		if (info is FileInfo file)
			file.MoveTo(value);
		else
			((DirectoryInfo)info).MoveTo(value);

		Description.Set(path, string.Empty);
		Description.Set(info.FullName, desc);
		return null;
	}

	/// <summary>
	/// Copies a file and its Far description.
	/// </summary>
	/// <remarks>
	/// It is a wrapper of <c>System.IO.FileInfo.CopyTo()</c>:
	/// in addition it copies the Far description.
	/// </remarks>
	public static FileInfo FileInfoCopyTo(PSObject instance, string value)
	{
		if (instance == null)
			throw new ArgumentNullException("instance");

		if (instance.BaseObject is not FileInfo file1)
			return null;

		FileInfo file2 = file1.CopyTo(value);
		Description.Set(file2.FullName, Description.Get(file1.FullName));
		return file2;
	}

	/// <summary>
	/// Deletes a file and its Far description.
	/// </summary>
	/// <remarks>
	/// It is a wrapper of <c>System.IO.FileInfo.Delete()</c>:
	/// in addition it deletes the Far description.
	/// </remarks>
	public static object FileInfoDelete(PSObject instance)
	{
		if (instance == null)
			throw new ArgumentNullException("instance");

		if (instance.BaseObject is not FileInfo file)
			return null;

		string path = file.FullName;
		file.Delete();
		Description.Set(path, string.Empty);
		return null;
	}
}

// Directorty item description map; used for caching directory descriptions.
class DescriptionMap(string directory, DateTime timestamp, Dictionary<string, string> map)
{
    public string Directory => directory;
    public DateTime Timestamp => timestamp;
    public Dictionary<string, string> Map => map;
}
