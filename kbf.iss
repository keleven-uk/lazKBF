; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "lazKBF"
#define MyAppVersion "16"
#define MyAppPublisher "Keleven"
#define MyAppURL "www.keleven.co.uk"
#define MyAppExeName "kbf.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{B9B4FE98-53B7-4D3A-9BCD-3804C30D690A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

;  all source files here
SourceDir=D:\My\shed\Projects\pascal\lazKBF

DefaultDirName={pf}\keleven\kbf
DefaultGroupName={#MyAppName}
LicenseFile=GNU GENERAL PUBLIC LICENSE.txt
InfoAfterFile=help.txt
OutputDir=D:\My\shed\Projects\pascal
OutputBaseFilename={#MyAppName}_{#MyAppVersion}
SetupIconFile=kbf.ico
Compression=lzma
SolidCompression=yes
DisableStartupPrompt=False
UsePreviousAppDir=False
SetupLogging=True

; "ArchitecturesInstallIn64BitMode=x64" requests that the install be done in "64-bit mode" 
; on x64, meaning it should use the native 64-bit Program Files directory and the 64-bit 
; view of the registry. On all other architectures it will install in "32-bit mode".
ArchitecturesInstallIn64BitMode=x64
; Note: We don't set ProcessorsAllowed because we want this installation to run on 
; all architectures (including Itanium,since it's capable of running 32-bit code too).

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

; NOTE: Don't use "Flags: ignoreversion" on any shared system files
; installs either klock_x64 or klock_x86 - but names them klock.exe
[Files]
Source: "kbf_Release 32-bit.exe"         ; DestDir: "{app}"; DestName: {#MyAppExeName}; Flags: ignoreversion ; Check: not Is64BitInstallMode
Source: "kbf_Release 64 bit.exe"         ; DestDir: "{app}"; DestName: {#MyAppExeName}; Flags: ignoreversion ; Check: Is64BitInstallMode
Source: "GNU GENERAL PUBLIC LICENSE.txt" ; DestDir: "{app}"; Flags: ignoreversion
Source: "help.txt"                       ; DestDir: "{app}"; Flags: ignoreversion
Source: "history.txt"                    ; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

