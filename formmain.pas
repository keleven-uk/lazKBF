unit formMain;

{
  Kill those bothersome files with KBF.

  Kill Bothersome Files - kills those bothersome files, that get in the way.

  See uInfo.pas for program detail and licence information.

}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, AdvLed, Forms, EditBtn, ShellApi, strutils,
  Controls, Graphics, Dialogs, ExtCtrls, ComCtrls, Menus, StdCtrls,
  CheckLst, Buttons, PopupNotifier, formAbout, formHelp, formLicence, uInfo;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    AdvLedSearch: TAdvLed;
    ChckGrpOptions: TCheckGroup;
    lblInfo: TLabel;
    lblTaken: TLabel;
    btnKill: TButton;
    btnSearch: TButton;
    btnClear: TButton;
    btnExit: TButton;
    ChckGrpChoice: TCheckGroup;
    ChckLstBxFiles: TCheckListBox;
    DrctryEdtRoot: TDirectoryEdit;
    Information: TGroupBox;
    GrpBxRoot: TGroupBox;
    mnuLicence: TMenuItem;
    mnuItmHelp: TMenuItem;
    mnuItmAbout: TMenuItem;
    mnuItmExit: TMenuItem;
    mnuhelp: TMenuItem;
    mnuFile: TMenuItem;
    mnuMain: TMainMenu;
    Panel1: TPanel;
    Panel2: TPanel;
    PpNtfrFiles: TPopupNotifier;
    RdGrpSelect: TRadioGroup;
    stsBrInfo: TStatusBar;
    TmrMain: TTimer;
    TmrInfo: TTimer;
    procedure btnClearClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure ChckLstBxFilesDblClick(Sender: TObject);
    procedure DrctryEdtRootAcceptDirectory(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuItmAboutClick(Sender: TObject);
    procedure mnuItmExitClick(Sender: TObject);
    procedure mnuItmHelpClick(Sender: TObject);
    procedure mnuLicenceClick(Sender: TObject);
    procedure RdGrpSelectClick(Sender: TObject);
    procedure TmrMainTimer(Sender: TObject);
    procedure TmrInfoTimer(Sender: TObject);
  private
    function checkATTR(fattr: longint): string;
    function FileSizeToHumanReadableString(FileSize: Int64): string;
    function cleanDirectoryName(fileName: string): string;
    procedure walkDirectory(dir: string);
    procedure fileFound(FileIterator: TFileIterator);
    procedure DirectoryFound(FileIterator: TFileIterator);
    procedure setDefaults;
    procedure deleteFiles;
    procedure closeApp;
    procedure deleteToRycycle(aFile: string);
  public
    noOfTicks: integer;
  end;

var
  frmMain: TfrmMain;
  aborting: boolean;    //  true if aborting.
  searching: boolean;   //  true if search being performed.
  filesSize: longint;   //  used to hold the total size of all files.
  noOfFiles: longint;   //  used to hold the total number of files.
  noOfDirs: longint;    //  used to hold the total number of directories.

  fileSearch: TFileSearcher;

implementation

{$R *.lfm}

{ TfrmMain }


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  setDefaults;
end;

procedure TfrmMain.setDefaults;
{  set all options to sensible defaults  }

begin
  ChckGrpOptions.Checked[0] := True;       //  default to delete to recycle bin.
  ChckGrpOptions.Checked[1] := True;       //  default to confirm deletes.
  ChckGrpChoice.Checked[0] := True;        //  default to Thumbs.db.
  DrctryEdtRoot.Directory := '';           //  clear directory search.
  DrctryEdtRoot.Enabled := True;           //  turn off directory search.
  ChckGrpChoice.Enabled := True;
  RdGrpSelect.ItemIndex := 1;              //  default to Select None.
  RdGrpSelect.Enabled := False;            //  turn off select group.
  PpNtfrFiles.Visible := False;            //  turn off pop up.
  AdvLedSearch.Blink := False;             //  set deafults for LED.
  AdvLedSearch.State := lsOn;
  AdvLedSearch.Kind := lkRedLight;
  btnSearch.Enabled := False;              //  turn off search button till needed.
  Application.Title := appName;            //  set application title.
  btnClear.Enabled := False;               //  turn off clear button till needed.
  lblTaken.Caption := '';                  //  Clear labels.
  lblInfo.Caption := '';
  btnKill.Enabled := False;                //  turn off kill button till needed.
  frmMain.Caption := appName;              //  set form title.

  aborting := False;
  searching := False;
  filesSize := 0;
  noOfFiles := 0;
  noOfDirs := 0;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnKillClick(Sender: TObject);
{  Start the killing by calling deletefiles, disable stuff used so far. }

begin
  RdGrpSelect.Enabled := False;
  btnClear.Enabled := False;
  btnKill.Enabled := False;

  deleteFiles;
  setDefaults;
end;

function TfrmMain.cleanDirectoryName(fileName: string): string;
{  Because emptry directories are added to the list box thus,
   ChckLstBxFiles.Items.Add(format('Empty DIR :: %s', [FileIterator.FileName]));
   They need the first bit stripping off before they are passed to the delete proc.
}
var
  fileLength: integer;                             //  length of filename.
begin
  fileLength := length(fileName);                  //  length of filename.
  Result := AnsiMidStr(fileName, 14, fileLength);  //  start of sub string is hard coded.
end;

procedure TfrmMain.deleteFiles;
{  Delete all the checked entries in the list box.
   When an entry is deleted, all the above entries move down. So, if all entries
   are checked - then the delete is always callat at position 0. That's why the
   position p is only incremented at an uncheck entry.

   Because emptry directories are added to the list box thus,
   ChckLstBxFiles.Items.Add(format('Empty DIR :: %s', [FileIterator.FileName]));
   They need the first bit stripping off before they are passed to the delete proc.
}

var
  f: integer = 0;
  count : integer;         //  total number of files - total entries in list box.
  killPos: integer = 0;    //  kill at position
  fileName: string;        //  filename

begin

  count := ChckLstBxFiles.Items.Count;

  for f := 0 to (count - 1) do
  begin
    if ChckLstBxFiles.Checked[killPos] then                   //  square brackets
    begin

      fileName := ChckLstBxFiles.Items.Strings[killPos];

      if AnsiStartsStr('Empty', fileName) then                //  Strip off the empty dir tag.
        fileName := cleanDirectoryName(fileName);

      deleteToRycycle(fileName);                              //  square brackets
      ChckLstBxFiles.Items.Delete(killPos);                   //  round brackets !!
    end
    else
      killPos += 1;                                           //  only increment with no delete.
                                                              //  becase if entry is killed, all entries move up.
  end;    //  for

  stsBrInfo.Panels.Items[2].Text := ' KBF :: Finished Killing';
  Application.Title := ' KBF';
  frmMain.Caption := ' KBF';
  btnClear.Caption := 'Reset';
  btnClear.Enabled := True;
end;

procedure TfrmMain.deleteToRycycle(aFile: string);
{  Delets files to the Rycycle bin.
    Thanks to Lush - http://forum.lazarus-ide.org/index.php?topic=12288.0

    FOF_ALLOWUNDO -> moves file to the bin.
    FOF_SILENT -> deletes the file permanently.
    Add FOF_NOCONFIRMATION to any of the previous constants to disable the "are you sure" dialog box.

    NB : Seems to ignore directories at the moment.
}

var
  fileOpStruct: TSHFileOpStruct;

begin
  with fileOpStruct do
  begin
    Wnd := Application.MainForm.Handle;
    wFunc := FO_DELETE;
    pFrom := PChar(aFile + #0#0);
    pTo := nil;
    hNameMappings := nil;

    if ChckGrpOptions.Checked[0] then
      fFlags := FOF_ALLOWUNDO                    //  Use recycle bin.
    else
      fFlags := FOF_SILENT;                      //  Delete permanently.

    if not ChckGrpOptions.Checked[1] then        //  confirm deletes.
      fFlags := fFlags or FOF_NOCONFIRMATION;
  end;  //  with

  try
    SHFileOperation(fileOpStruct);
  except
    //  TODO :: log error here.
    on E: Exception do
      ShowMessage(E.Message);
  end;

end;

procedure TfrmMain.btnClearClick(Sender: TObject);
{  clear/reset the form, can be called for anywhere - so clear everything.}

var
  f: integer;

begin
  setDefaults;

  stsBrInfo.Panels.Items[2].Text := '';

  if btnClear.Caption = 'Reset' then
    btnClear.Caption := 'Clear';

  for f := 0 to ChckGrpChoice.Items.Count - 1 do
    //  Clears all choices prevously selected.
    ChckGrpChoice.Checked[f] := False;

  ChckLstBxFiles.Clear;

  if searching then
    fileSearch.Free;
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
{  start search by calling the walk directory procedure, disable stuff used so far. }

var
  dtStart: TDateTime;
  dtEnd: TDateTime;

begin
  DrctryEdtRoot.Enabled := False;
  ChckGrpChoice.Enabled := False;
  btnSearch.Enabled := False;
  AdvLedSearch.Blink := True;                 //  Start flashing the LED.
  AdvLedSearch.Kind := lkGreenLight;
  btnClear.Enabled := True;

  dtStart := time;                            //  Start timing.

  walkDirectory(DrctryEdtRoot.Directory);

  dtEnd := time;                              //  End timing.

  AdvLedSearch.Blink := False;                //  reset LED
  AdvLedSearch.Kind := lkRedLight;
  AdvLedSearch.State := lsOn;

  lblTaken.Caption := 'Search took :[mins:secs:milli]]:  ' + FormatDateTime('nn:ss:zzz', dtEnd - dtStart);
end;

procedure TfrmMain.ChckLstBxFilesDblClick(Sender: TObject);
{  Pops up a info meassage when a entry is clicked in the list box.

   Assumes entry is a valid filename.
}

var
  message: string;                  //  message to display.
  fname: string;                    //  filename
  fpos: integer;
  fsize: string;
  fdate: string;
  fattr: longint;
begin

  if (ChckLstBxFiles.Items.Count <> 0) then
  begin                                            //  something in list box, show popup.
    PpNtfrFiles.ShowAtPos(100, 100);
    PpNtfrFiles.Title := 'File Info';

    fpos := ChckLstBxFiles.ItemIndex;
    fname := ChckLstBxFiles.Items.Strings[fpos];

    if AnsiStartsStr('Empty', fname) then
    begin                                          //  entry is a directory.
      fname := cleanDirectoryName(fname);          //  Strip off the empty dir tag.
      message := format('Directory :: %s. ', [fname]);
      message := message + LineEnding + '';
      message := message + LineEnding + ' Empty Directory';
    end
    else
    begin                                          //  entry is a file.
      fattr := FilegetAttr(fname);
      fdate := format('%s', [formatDateTime('dddd mmmm yyyy  hh:nn', FileDateToDateTime(FileAge(fname)))]);
      fsize := format('fileSize :: %d bytes [%s]', [fileSize(fname), FileSizeToHumanReadableString(fileSize(fname))]);

      message := format('fileName :: %s. ', [fname]);
      message := message + LineEnding + format('fileSize :: %S.', [fsize]);
      message := message + LineEnding + format('filedate :: %s.', [fdate]);
      message := message + LineEnding + checkATTR(fattr);
    end;

    if PpNtfrFiles.Visible = False then
    begin
      TmrInfo.Enabled := True;
      PpNtfrFiles.Text := message;
      PpNtfrFiles.Visible := True;
    end
    else
    begin                                                //  toggle popup.visable - performs a refresh.
      TmrInfo.Enabled := False;                          //  switch off and then on time to reset time interval.
      PpNtfrFiles.Visible := False;
      PpNtfrFiles.Text := message;
      PpNtfrFiles.Visible := True;
      TmrInfo.Enabled := True;
    end;

  end;  //  if ChckLstBxFiles.Items.Count <> 0
end;

function TfrmMain.checkATTR(fattr: longint): string;
{  return file attributes of a filename.

   NOTE :: This procedure is windows only apparently, if that is important to you.
}

begin

  if fattr <> -1 then
  begin
    if (fattr and faReadOnly) <> 0 then
      Result := 'File is ReadOnly';
    if (fattr and faHidden) <> 0 then
      Result := 'File is hidden';
    if (fattr and faSysFile) <> 0 then
      Result := 'File is a system file';
    if (fattr and faVolumeID) <> 0 then
      Result := 'File is a disk label';
    if (fattr and faArchive) <> 0 then
      Result := 'File is archive file';
    if (fattr and faDirectory) <> 0 then
      Result := 'File is a directory';
  end
  else
    Result := '';
end;

procedure TfrmMain.RdGrpSelectClick(Sender: TObject);
{  check or clears all entries in the list box.  }

begin
  if (RdGrpSelect.ItemIndex = 0) then
    ChckLstBxFiles.CheckAll(cbChecked, false, true);

  if (RdGrpSelect.ItemIndex = 1) then
    ChckLstBxFiles.CheckAll(cbUnchecked, true, false);
end;

procedure TfrmMain.DrctryEdtRootAcceptDirectory(Sender: TObject);
{  When the source directory is chosen, enable next stage.
   direcory must exist at this point.
}

begin
  btnSearch.Enabled := True;
end;

procedure TfrmMain.walkDirectory(dir: string);
{  Walk a directory passed into procedure.
   All files that match a certain pattern are added to filestore, filestore is declared globably.
   All emptry directories are aslo added to the filestore, if option selected.
   The pattern in a chosen file extension - from a combo box.
   Does not check if directory exists.
}

begin
  stsBrInfo.Panels.Items[2].Text := 'Walking ' + dir + ' now, Sir!';

  //  actual search
  searching := True;
  fileSearch := TFileSearcher.Create;
  fileSearch.OnFileFound := @fileFound;
  fileSearch.OnDirectoryFound := @DirectoryFound;
  fileSearch.Search(dir, '*.*', True);
  fileSearch.Free;
  searching := False;
  //  search finished.

  if ChckLstBxFiles.Items.Count = 0 then
  begin
    stsBrInfo.Panels.Items[2].Text := 'Finished walking and found nowt, Sir!';
  end
  else
  begin
    stsBrInfo.Panels.Items[2].Text := 'Finished walking';
    RdGrpSelect.Enabled := True;
    btnKill.Enabled := True;
  end;
end;

procedure TfrmMain.DirectoryFound(FileIterator: TFileIterator);
 {  Called each time a directory is found, stores directory if filestore.

    NB :: Adds the string 'Empty DIr :: ' to start, this has to be removed later.
}

var
  filesInDir: TStringList;

begin
  if ChckGrpChoice.Checked[11] then
  begin

    // process all user events, like clicking on the button
    Application.ProcessMessages;
    if Aborting or Application.Terminated then
      closeApp;  //  exit clicked

    filesInDir := FindAllFiles(FileIterator.FileName, '', True);

    if filesInDir.Count = 0 then
    begin
      noOfDirs += 1;
      ChckLstBxFiles.Items.Add(format('Empty DIR :: %s', [FileIterator.FileName]));
    end;  //  if filesInDir.Count = 0
  end;    //  if ChckGrpChoice.Checked[11]

  lblInfo.Caption := format(' KBF :: Found %d files, %d Empty Directories :: %s bytes [%s]',
    [noOfFiles, noOfDirs, FormatFloat('#,###', filesSize), FileSizeToHumanReadableString(filesSize)]);
end;

procedure TfrmMain.fileFound(FileIterator: TFileIterator);
{  called each time a search file is found, stores file in filestore.

   NB :: All filenames and check boxes are hard coded.
}

var
  AddFile: boolean;
  fname: string;
  flExt: String;

begin
  // process all user events, like clicking on the button
  Application.ProcessMessages;
  if Aborting or Application.Terminated then
    closeApp;  //  exit clicked

  addFile := False;
  fname := FileIterator.FileInfo.Name;             //  file name only, no path.
  flExt := ExtractFileExt(fname);

  if ChckGrpChoice.Checked[0] and (fname = 'Thumbs.db') then addFile := True;
  if ChckGrpChoice.Checked[1] and (flExt = '.nfo') then addFile := True;
  if ChckGrpChoice.Checked[2] and (flExt = '.m3u') then addFile := True;
  if ChckGrpChoice.Checked[3] and (flExt = '.tmp') then addFile := True;
  if ChckGrpChoice.Checked[4] and (flExt = '.bac') then addFile := True;
  if ChckGrpChoice.Checked[5] and (flExt = '.log') then addFile := True;
  if ChckGrpChoice.Checked[6] and (flExt = '.jpg') then addFile := True;
  if ChckGrpChoice.Checked[7] and (flExt = '.bmp') then addFile := True;
  if ChckGrpChoice.Checked[8] and (flExt = '.png') then addFile := True;
  if ChckGrpChoice.Checked[9] and (flExt = '.txt') then addFile := True;
  if ChckGrpChoice.Checked[10] and (AnsiLastChar(flExt) = '~') then addFile := True;

  if addFile then
  begin
    ChckLstBxFiles.Items.Add(FileIterator.FileName);           //  full path name.
    noOfFiles := ChckLstBxFiles.Items.Count - noOfDirs;
    filesSize := filesSize + FileIterator.FileInfo.Size;
    lblInfo.Caption := format(' KBF :: Found %d files, %d Empty Directories :: %s bytes [%s]',
      [noOfFiles, noOfDirs, FormatFloat('#,###', filesSize), FileSizeToHumanReadableString(filesSize)]);
  end;

end;

function TfrmMain.FileSizeToHumanReadableString(fileSize: Int64): string;
{  Returns filesize in a human readable form.
   Does not use ther silly ISO standard unit of Pib, TiB, GiB, MiB & KiB.
   Used the gold old fashion units of Pib, TB, GB, MB & KB.

   NOTE : constants defined in uInfo.pas
}

begin
  if fileSize > OnePB then
    result := FormatFloat(fmt + 'PB', fileSize / OnePB)
  else
    if fileSize > OneTB then
      result := FormatFloat(fmt + 'TB', fileSize / OneTB)
    else
      if fileSize > OneGB then
        result := FormatFloat(fmt + 'GB', fileSize / OneGB)
      else
        if fileSize > OneMB then
          result := FormatFloat(fmt + 'MB', fileSize / OneMB)
        else
          if fileSize > OneKB then
            result := FormatFloat(fmt + 'KB', fileSize / OneKB)
          else
            if fileSize > 0 then
              result := FormatFloat(fmt + 'bytes', fileSize)
            else
              result := ''

end;

procedure TfrmMain.mnuItmAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

procedure TfrmMain.mnuItmExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.mnuItmHelpClick(Sender: TObject);
begin
  frmHelp.ShowModal;
end;

procedure TfrmMain.mnuLicenceClick(Sender: TObject);
begin
  frmLicence.Show;
end;

procedure TfrmMain.TmrMainTimer(Sender: TObject);
begin
  stsBrInfo.Panels.Items[0].Text := TimeToStr(Time);
  stsBrInfo.Panels.Items[1].Text := FormatDateTime('DD MMMM YYYY', Now);
end;

procedure TfrmMain.TmrInfoTimer(Sender: TObject);
begin
  PpNtfrFiles.Visible := False;
  TmrInfo.Enabled := False;
end;

procedure TfrmMain.closeApp;
begin
  Searching := False;
  Aborting := True;
  Close;
end;

end.  // end of KBF.
