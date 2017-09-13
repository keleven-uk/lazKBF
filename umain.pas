unit Umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, AdvLed, Forms, EditBtn,
  Controls, Graphics, Dialogs, ExtCtrls, ComCtrls, Menus, StdCtrls,
  CheckLst, Buttons, PopupNotifier, UAbout, Uhelp, uLicence;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    AdvLedSearch: TAdvLed;
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
    PpNtfrInfo: TPopupNotifier;
    RdGrpSelect: TRadioGroup;
    stsBrInfo: TStatusBar;
    Timer1: TTimer;
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
    procedure Timer1Timer(Sender: TObject);
    procedure TmrInfoTimer(Sender: TObject);
  private
    function checkATTR(fattr: longint): string;
    procedure walkDirectory(dir: string);
    procedure fileFound(FileIterator: TFileIterator);
    procedure DirectoryFound(FileIterator: TFileIterator);
    procedure setDefaults;
    procedure deleteFiles;
    procedure closeApp;
  public
    noOfTicks: integer;
  end;

var
  frmMain  : TfrmMain;
  aborting : boolean;   //  true if aborting.
  searching: boolean;   //  true if search being performed.
  filesSize: longint;   //  used to hold the total size of all files.
  noOfFiles: longint;   //  used to hold the total number of files.
  noOfDirs : longint;   //  used to hold the total number of directories.

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
  ChckGrpChoice.Checked[0] := True;       //  default to Thumbs.db.
  DrctryEdtRoot.Directory  := '';         //  clear directory search.
  DrctryEdtRoot.Enabled    := True;       // turn of directory search.
  ChckGrpChoice.Enabled    := True;
  RdGrpSelect.ItemIndex    := 1;          //  default to Select None.
  RdGrpSelect.Enabled      := False;      //  turn off select group.
  PpNtfrFiles.Visible      := False;      //  turn off pop up.
  AdvLedSearch.Blink       := False;      //  set deafults for LED.
  AdvLedSearch.State       := lsOn;
  AdvLedSearch.Kind        := lkRedLight;
  btnSearch.Enabled        := False;      //  turn off search button till needed.
  Application.Title        := ' KBF';     //  set application title.
  btnClear.Enabled         := False;      //  turn off clear button till needed.
  lblTaken.Caption         := '';         //  Clear labels.
  lblInfo.Caption          := '';
  btnKill.Enabled          := False;      //  turn off kill button till needed.
  frmMain.Caption          := ' KBF';     //  set form title.

  aborting  := False;
  searching := False;
  noOfFiles := 0;
  noOfDirs  := 0;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnKillClick(Sender: TObject);
{  Start the killing by calling deletefiles, disable stuff used so far.                            }
begin
  RdGrpSelect.Enabled := False;
  btnClear.Enabled    := False;
  btnKill.Enabled     := False;

  deleteFiles;
end;

procedure TfrmMain.deleteFiles;
{  Delete all the checked entries in the list box.
   When an entry is deleted, all the above entries move down. So, if all entries are checked - then
   the delete is always callat at position 0. That's why the position p is only incremented at
   an uncheck entry.                                                                               }
var
  f: integer;
  p: integer;  //  kill at position
begin

  f := ChckLstBxFiles.Items.Count;
  p := 0;

  for f := 0 to (f - 1) do
  begin
    if ChckLstBxFiles.Checked[p] then                 //  square brackets
    begin
      try
        DeleteFile(ChckLstBxFiles.Items.Strings[p]);  //  square brackets
        ChckLstBxFiles.Items.Delete(p)                //  round brackets !!
      except
        //  function Vs string list.
        //  TODO :: log error here.
      end;

    end
    else
      p += 1;                    //  only increment with no delete.
  end;

  Application.Title := ' KBF';
  frmMain.Caption   := ' KBF';
  stsBrInfo.Panels.Items[2].Text := ' KBF :: Finished Killing';

  btnClear.Caption := 'Reset';
  btnClear.Enabled := True;
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
{  clear/reset the form, can be called for anywhere - so clear everything.}

var
  i: integer;

begin
  setDefaults;

  stsBrInfo.Panels.Items[2].Text := '';

  if btnClear.Caption = 'Reset' then
    btnClear.Caption := 'Clear';

  for i := 0 to ChckGrpChoice.Items.Count - 1 do
    //  Clears all choices prevously selected.
    ChckGrpChoice.Checked[i] := False;

  ChckLstBxFiles.Clear;

  if searching then
    fileSearch.Free;
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
{  start search by calling the walk directory procedure, disable stuff used so far.                }
var
  dtStart: TDateTime;
  dtEnd: TDateTime;
begin
  btnSearch.Enabled := False;
  DrctryEdtRoot.Enabled := False;
  ChckGrpChoice.Enabled := False;
  AdvLedSearch.Blink := True;
  AdvLedSearch.Kind := lkGreenLight;
  btnClear.Enabled := True;

  dtStart := time;

  walkDirectory(DrctryEdtRoot.Directory);

  dtEnd := time;

  AdvLedSearch.Blink := False;
  AdvLedSearch.Kind := lkRedLight;
  AdvLedSearch.State := lsOn;

  lblTaken.Caption := 'Search took :[mins:secs:milli]]:  ' +
    FormatDateTime('nn:ss:zzz', dtEnd - dtStart);
end;

procedure TfrmMain.ChckLstBxFilesDblClick(Sender: TObject);
var
  message: string;
  fname: string;
  fpos: integer;
  fsize: string;
  fdate: string;
  fattr: longint;
begin

  if (ChckLstBxFiles.Items.Count <> 0) then
  begin  //  noting in list box, so do nothing.
    PpNtfrFiles.ShowAtPos(100, 100);
    PpNtfrFiles.Title := 'File Info';

    fpos := ChckLstBxFiles.ItemIndex;
    fname := ChckLstBxFiles.Items.Strings[fpos];

    fattr := FilegetAttr(fname);

    try
      begin
        fdate := format('%s', [formatDateTime('dddd mmmm yyyy  hh:nn',
          FileDateToDateTime(FileAge(fname)))]);
        fsize := format('fileSize :: %d bytes.', [fileSize(fname)]);

        message := format('fileName :: %s. ', [fname]);
        message := message + LineEnding + format('fileSize :: %S.', [fsize]);
        message := message + LineEnding + format('filedate :: %s.', [fdate]);
        message := message + LineEnding + checkATTR(fattr);
      end;
    except
      begin
        message := format('fileName :: %s. ', [fname]);
        message := message + LineEnding + '';
        message := message + LineEnding + ' Empty Directory';
      end;

    end;

    if PpNtfrFiles.Visible = False then
    begin
      PpNtfrFiles.Text := message;
      PpNtfrFiles.Visible := True;
    end
    else
    begin  //  toggle popup.visable - performs a refresh.
      PpNtfrFiles.Visible := False;
      PpNtfrFiles.Text := message;
      PpNtfrFiles.Visible := True;
    end;

  end;  //  if ChckLstBxFiles.Items.Count = 0
end;

function TfrmMain.checkATTR(fattr: longint): string;
begin

  if fattr <> -1 then
  begin
    if (fattr and faReadOnly) <> 0 then
      checkATTR := 'File is ReadOnly';
    if (fattr and faHidden) <> 0 then
      checkATTR := 'File is hidden';
    if (fattr and faSysFile) <> 0 then
      checkATTR := 'File is a system file';
    if (fattr and faVolumeID) <> 0 then
      checkATTR := 'File is a disk label';
    if (fattr and faArchive) <> 0 then
      checkATTR := 'File is archive file';
    if (fattr and faDirectory) <> 0 then
      checkATTR := 'File is a directory';
  end
  else
    checkATTR := '';
end;

procedure TfrmMain.RdGrpSelectClick(Sender: TObject);
{  check all or clears all entries in the list box.
   must be an easir way - can't find a listbox checkall or clearall function call.                 }
var
  f: integer;
begin
  f := ChckLstBxFiles.Items.Count;

  if (RdGrpSelect.ItemIndex = 0) then
    for f := 0 to (f - 1) do
      ChckLstBxFiles.Checked[f] := True;

  if (RdGrpSelect.ItemIndex = 1) then
    for f := 0 to (f - 1) do
      ChckLstBxFiles.Checked[f] := False;
end;

procedure TfrmMain.DrctryEdtRootAcceptDirectory(Sender: TObject);
{  When the source directory is chosen, enable next stage.
   direcory must exist at this point                                                               }
begin
  btnSearch.Enabled := True;
end;

procedure TfrmMain.walkDirectory(dir: string);
{  Walk a directory passed into procedure.
   All files that match a certain pattern are added to filestore, filestore is declared globably.
   All emptry directories are aslo added to the filestore, if option selected.
   The pattern in a chosen file extension - from a combo box.
   Does not check if directory exists.                                         }

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
    end;
  end;

  lblInfo.Caption := format(' KBF :: Found %d files, %d Empty Directories :: %s bytes',
    [noOfFiles, noOfDirs, FormatFloat('#,###', filesSize)]);
end;

procedure TfrmMain.fileFound(FileIterator: TFileIterator);
{  called each time a search file is found, stores file in filestore.                              }
begin
  // process all user events, like clicking on the button
  Application.ProcessMessages;
  if Aborting or Application.Terminated then
    closeApp;  //  exit clicked

  if ChckGrpChoice.Checked[0] and (FileIterator.FileInfo.Name = 'Thumbs.db') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[1] and (ExtractFileExt(FileIterator.FileName) = '.nfo') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[2] and (ExtractFileExt(FileIterator.FileName) = '.m3u') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[3] and (ExtractFileExt(FileIterator.FileName) = '.tmp') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[4] and (ExtractFileExt(FileIterator.FileName) = '.bac') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[5] and (ExtractFileExt(FileIterator.FileName) = '.log') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[6] and (ExtractFileExt(FileIterator.FileName) = '.jpg') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[7] and (ExtractFileExt(FileIterator.FileName) = '.bmp') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[8] and (ExtractFileExt(FileIterator.FileName) = '.png') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[9] and (ExtractFileExt(FileIterator.FileName) = '.txt') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  if ChckGrpChoice.Checked[10] and (AnsiLastChar(FileIterator.FileName) = '~') then
  begin
    filesSize := filesSize + FileIterator.FileInfo.Size;
    ChckLstBxFiles.Items.Add(FileIterator.FileName);
  end;

  noOfFiles := ChckLstBxFiles.Items.Count - noOfDirs;
  lblInfo.Caption := format(' KBF :: Found %d files, %d Empty Directories :: %s bytes',
    [noOfFiles, noOfDirs, FormatFloat('#,###', filesSize)]);
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



procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  stsBrInfo.Panels.Items[0].Text := TimeToStr(Time);
  stsBrInfo.Panels.Items[1].Text := FormatDateTime('DD MMM YYYY', Now);
end;

procedure TfrmMain.TmrInfoTimer(Sender: TObject);
begin
  PpNtfrInfo.Visible := False;
end;

procedure TfrmMain.closeApp;
begin
  Aborting := True;
  Searching := False;
  Close;
end;

end.
