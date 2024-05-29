# Find my understudied genes

Identifying Genes of Promise Tool.

# How to prepare a Windows to create the package

Install Visual Studio Code (check architecture and User/System Installer).
Install also these extensions:
 - Dart
 - Flutter

Install GitHub Desktop (or something similar) and pull the code at the default folder.

Note: Change to the flutter-app branch.

Open in VSCode the folder promising_genes/find_my_inderstudied_genes

You will be asked to install the Flutter SDK. Select "Windows" and look for "Download and install" folder. It will download a file called flutter_windows_3.7.0-stable.zip

IMPORTANT: The flutter windows builder in new versions is changing the destination folder to
           add the platform name (x64), but the msix is not able to deal with this, so...
           DON'T INSTALL NEWER VERSION OF FLUTTER!   

Install (unzip and copy) flutter in the folder c:\src\flutter (it cannot have spaces!)

Close VSCode and open it again. When the flutter extension asks for the Flutter SDK, click on "Locate SDK..." and select the previous folder.

Then, click on "Run 'pub get'".

This step will warn us that we need to run this on the terminal:

    $ start ms-settings:developers

And activate: "Install apps from any source, including loose files."

Close and open again the VSCode.

To create an app for Windows, you will need to install the Visual Studio (without Code). The student version (Free) is enough. Select the "Universal Windows Platform Development" and "Desktop development with C++" and install.

You could check that everything works running on VSCode Terminal:

    $ flutter doctor

The only error that should appear is "Cannot find chrome".

Then, remove (or rename) the folder "windows" and create a new platform:

    $ flutter create --platforms windows .

Now, you will be able to compile and run the windows app.

    $ flutter build windows


To run the previous build, you must download the SQLite DLL from https://www.sqlite.org/download.html, something like: sqlite-dll-win-x86-3450100.zip

Uncompress the file and copy the file "sqlite3.dll" into:

    build/windows/x86/runner/Release 

# How to create the package for the store

$ python scripts/convert_csv_to_sqlite.py --main data/main_table.csv --columns data/main_table_columns.csv --sqlite assets/db.sqlite --overwrite --dbversion 1.xx

**Note:** The version must be different when the db is changed. The current version is written at `/lib/providers/database_connector_provider.dart:14`.

**Note:** If you change the gene columns, use the `--print-flutter-pairs` attribute and copy the text written in the console to the file `/lib/model/gene_columns.dart` (use the same format as the current file).

Run `flutter build windows` in VSCode

## Create Windows Package (OUTDATED)

Update at the `pubspec.yaml` the version value at `msix_config/msix_version`.

Run at the terminal:

    $ flutter pub run msix:create

The package will appear at: `build/windows/runner/Release` and called `find_my_understudied_genes.msix`.

# How to create an installer using Inno

Open Inno Setup Compiler, change the version in the header of CreateWindowsBinary.iss (using the same version shown in pubspec.yaml) and hit Run. Once finished, the .exe will be found in fmug/find_my_understudied_genes/InnoSetup/Output.

# How to create a new version release on GitHub

To release the windows installer, go to [github.com/amarallab/fmug](https://github.com/amarallab/fmug) (no this one) and click on Releases.

Then, click on "Draft a new release":

- Choose a tag and write "v1.x.x.x-windows". This will create a tag using the same name.
- The name must be "1.x.x.x-windows" (without the 'v')
- Write the changes (same as the App Store)
- Rename the InnoSetup exe to: InstallFMUG-1.x.x.x-windows.exe
- Add the "exe" generated
- Mark: Set as the latest release

And publish!