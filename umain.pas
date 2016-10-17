unit Umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, Menus, StdCtrls, EditBtn, CheckLst, Buttons, PopupNotifier, UAbout,
  Uhelp, UOptions, uLicence;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnKill: TButton;
    btnSearch: TButton;
    btnClear: TButton;
    btnExit: TButton;
    ChckGrpChoice: TCheckGroup;
    ChckLstBxFiles: TCheckListBox;
    DrctryEdtRoot: TDirectoryEdit;
    GrpBxRoot: TGroupBox;
    mnuLicence: TMenuItem;
    mnuItmOptions: TMenuItem;
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
    procedure DrctryEdtRootAcceptDirectory(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure GrpBxRootClick(Sender: TObject);
    procedure mnuItmAboutClick(Sender: TObject);
    procedure mnuItmExitClick(Sender: TObject);
    procedure mnuItmHelpClick(Sender: TObject);
    procedure mnuItmOptionsClick(Sender: TObject);
    procedure mnuLicenceClick(Sender: TObject);
    procedure RdGrpSelectClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TmrInfoTimer(Sender: TObject);
  private
    procedure displayMessage(message : String ; message1 : String);
    function  checkATTR(fattr : LongInt): String;
    procedure walkDirectory(dir : string);
    procedure fileFound(FileIterator : TFileIterator);
    procedure deleteFiles;
    procedure closeApp;
  public
    noOfTicks : integer ;
  end; 

var
  frmMain   : TfrmMain;
  aborting  : Boolean;
  searching : Boolean;  //  true is search being performed.
  filesSize : LongInt;  //  used to hold the total size of all files.

  fileSearch : TFileSearcher;
implementation

{$R *.lfm}

{ TfrmMain }


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ChckGrpChoice.Checked[0] := true;  //  default to Thumbs.db
  RdGrpSelect.ItemIndex    := 1;     //  default to Select None
  aborting                 := false;
  searching                := false;
end;

procedure TfrmMain.GrpBxRootClick(Sender: TObject);
begin

end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnKillClick(Sender: TObject);
{  Start the killing by calling deletefiles, disable stuff used so far.                            }
begin
  btnClear.Enabled    := false;
  btnKill.Enabled     := false;
  RdGrpSelect.Enabled := false;

  deleteFiles;
end;

procedure TfrmMain.deleteFiles;
{  Delete all the checked entries in the list box.
   When an entry is deleted, all the above entries move down. So, if all entries are checked - then
   the delete is always callat at position 0. That's why the position p is only incremented at
   an uncheck entry.                                                                               }
VAR
  f : integer;
  p : integer;  //  kill at position
begin

  f := ChckLstBxFiles.Items.Count;
  p := 0;

  for f := 0 to (f - 1) do begin
      if ChckLstBxFiles.Checked[p] then begin                           //  square brackets
        try
          DeleteFile(ChckLstBxFiles.Items.Strings[p]);                  //  square brackets
          ChckLstBxFiles.Items.Delete(p)                                //  round brackets !!
        except                                                          //  function Vs string list.
          //  TODO :: log error here.
        end;

      end
      else
        p := p + 1;                    //  only increment with no delete.
  end;

  Application.Title := ' KBF';
  frmMain.Caption   := ' KBF';
//  stsBrInfo.Panels.Items[2].Text := ' KBF :: Finished Killing';

  btnClear.Caption := 'Reset';
  btnClear.Enabled := true;
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
{  clear/reset the form, can be called for anywhere - so clear everything.                         }
begin
  if btnClear.Caption = 'Reset' then
    btnClear.Caption := 'Clear';

  DrctryEdtRoot.Directory := '';
  DrctryEdtRoot.Enabled   := true;
  ChckGrpChoice.Enabled   := true;
  RdGrpSelect.Enabled     := false;
  btnSearch.Enabled       := false;
  btnClear.Enabled        := false;
  btnKill.Enabled         := false;

  Application.Title := ' KBF';
  frmMain.Caption   := ' KBF';
  stsBrInfo.Panels.Items[2].Text:= '';

  ChckGrpChoice.Checked[0] := true;  //  default to Thumbs.db
  RdGrpSelect.ItemIndex    := 1;     //  default to Select None

  searching := false;
  aborting  := false;

  PpNtfrFiles.Visible := false ;

  ChckLstBxFiles.Clear;

  if searching then fileSearch.Free;
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
{  start search by calling the walk directory procedure, disable stuff used so far.                }
begin
  btnSearch.Enabled     := false;
  DrctryEdtRoot.Enabled := false;
  ChckGrpChoice.Enabled := false;
  btnClear.Enabled      := true;

  walkDirectory(DrctryEdtRoot.Directory);
end;

procedure TfrmMain.ChckLstBxFilesDblClick(Sender: TObject);
VAR
  message : string;
  fname   : string;
  fpos    : integer;
  fsize   : Int64;
  fdate   : TDateTime;
  fattr   : LongInt;
begin

  if (ChckLstBxFiles.Items.Count <> 0) then begin  //  noting in list box, so do nothing.
    PpNtfrFiles.ShowAtPos(100,100) ;
    PpNtfrFiles.Title   := 'File Info';

    fpos  := ChckLstBxFiles.ItemIndex;
    fname := ChckLstBxFiles.Items.Strings[fpos];
    fsize := fileSize(fname);
    fdate := FileDateToDateTime(FileAge(fname));
    fattr := FilegetAttr(fname);

    message := format('fileName :: %s. ', [fname]);
    message := message + LineEnding + format('fileSize :: %d bytes.', [fsize]);
    message := message + LineEnding + format('filedate :: %s',[formatDateTime('dddd mmmm yyyy  hh:nn', fdate)]);
    message := message + LineEnding + checkATTR(fattr);

    if PpNtfrFiles.Visible = false then begin
      PpNtfrFiles.Text    := message;
      PpNtfrFiles.Visible := true ;
    end
    else begin  //  toggle popup.visable - performs a refresh.
      PpNtfrFiles.Visible := false ;
      PpNtfrFiles.Text    := message;
      PpNtfrFiles.Visible := true ;
    end;

  end;  //  if ChckLstBxFiles.Items.Count = 0
end;

function TfrmMain.checkATTR(fattr : LongInt): String;
begin

  if fattr <> -1 then begin
    If (fattr and faReadOnly)<>0 then
      checkATTR := 'File is ReadOnly';
    If (fattr and faHidden)<>0 then
      checkATTR := 'File is hidden';
    If (fattr and faSysFile)<>0 then
      checkATTR := 'File is a system file';
    If (fattr and faVolumeID)<>0 then
      checkATTR := 'File is a disk label';
    If (fattr and faArchive)<>0 then
      checkATTR := 'File is archive file';
    If (fattr and faDirectory)<>0 then
      checkATTR := 'File is a directory';
  end
  else
    checkATTR := '';

end;

procedure TfrmMain.RdGrpSelectClick(Sender: TObject);
{  check all or clears all entries in the list box.
   must be an easir way - can't finf a listbox checkall or clearall finction call.                 }
VAR
  f : integer;
begin
  f := ChckLstBxFiles.Items.Count;

  if (RdGrpSelect.ItemIndex = 0) then
    for f := 0 to (f - 1) do
      ChckLstBxFiles.Checked[f] := true;

  if (RdGrpSelect.ItemIndex = 1) then
    for f := 0 to (f - 1) do
      ChckLstBxFiles.Checked[f] := false;
end;

procedure TfrmMain.DrctryEdtRootAcceptDirectory(Sender: TObject; var Value: String);
{  When the source directory is chosen, enable next stage.
   direcory must exist at this point                                                               }
begin
  btnSearch.Enabled := true;
end;

procedure TfrmMain.walkDirectory(dir : string);
{  Walk a directory passed into procedure.
   All files that match a certain pattern are added to filestore, filestore is declared globably..
   The pattern in a chosen file extension - from a combo box.
   Does not check if directory exists.                                         }

begin
  stsBrInfo.Panels.Items[2].Text:= 'Walking ' + dir + ' now, Sir!' ;

  //  actual search
  searching  := true;
  fileSearch := TFileSearcher.Create;
  fileSearch.OnFileFound := @fileFound;
  fileSearch.Search(dir, '*.*', true);
  fileSearch.Free;
  searching := false;
  //  search finished.

  if ChckLstBxFiles.Items.Count = 0 then begin
    DisplayMessage('Finished walking and found nowt, Sir!', '');
  end
  else begin
    DisplayMessage(format(' KBF :: Found %d files', [ChckLstBxFiles.Items.Count]),
                   format('       :: in %d bytes', [filesSize]));

    RdGrpSelect.Enabled := true;
    btnKill.Enabled     := true;
  end;
end;

procedure TfrmMain.displayMessage(message : String ; message1 : String);
begin
  PpNtfrInfo.ShowAtPos(frmmain.Left, frmmain.top) ;
  PpNtfrInfo.Title   := 'File Info';
  PpNtfrInfo.Text    := message + LineEnding + message1;
  PpNtfrInfo.Visible := true;
  TmrInfo.Enabled    := true;

  stsBrInfo.Panels.Items[2].Text := message;
  Application.Title              := message;
  frmMain.Caption                := message; ;
end;

procedure TfrmMain.fileFound(FileIterator : TFileIterator);
{  called each time a search file is found, stores file in filestore.                              }
begin
    // process all user events, like clicking on the button
    Application.ProcessMessages;
    if Aborting or Application.Terminated then closeApp;  //  exit clicked

    if ChckGrpChoice.Checked[0] and (FileIterator.FileInfo.Name = 'Thumbs.db') then begin
      filesSize := filesSize + FileIterator.FileInfo.Size;
      ChckLstBxFiles.Items.Add(FileIterator.FileName);
    end;

    if ChckGrpChoice.Checked[1] and (ExtractFileExt(FileIterator.FileName) = '.nfo') then begin
      filesSize := filesSize + FileIterator.FileInfo.Size;
      ChckLstBxFiles.Items.Add(FileIterator.FileName);
    end;

    if ChckGrpChoice.Checked[2] and (ExtractFileExt(FileIterator.FileName) = '.m3u') then begin
      filesSize := filesSize + FileIterator.FileInfo.Size;
      ChckLstBxFiles.Items.Add(FileIterator.FileName);
    end;

    if ChckGrpChoice.Checked[3] and (ExtractFileExt(FileIterator.FileName) = '.tmp') then begin
      filesSize := filesSize + FileIterator.FileInfo.Size;
      ChckLstBxFiles.Items.Add(FileIterator.FileName);
    end;

    if ChckGrpChoice.Checked[4] and (ExtractFileExt(FileIterator.FileName) = '.bac') then begin
      filesSize := filesSize + FileIterator.FileInfo.Size;
      ChckLstBxFiles.Items.Add(FileIterator.FileName);
    end;

    if ChckGrpChoice.Checked[5] and (ExtractFileExt(FileIterator.FileName) = '.log') then begin
      filesSize := filesSize + FileIterator.FileInfo.Size;
      ChckLstBxFiles.Items.Add(FileIterator.FileName);
    end;
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

procedure TfrmMain.mnuItmOptionsClick(Sender: TObject);
begin
  frmOptions.ShowModal;
end;

procedure TfrmMain.mnuLicenceClick(Sender: TObject);
begin
  frmLicence.Show;
end;



procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  stsBrInfo.Panels.Items[0].Text := TimeToStr(Time) ;
  stsBrInfo.Panels.Items[1].Text := FormatDateTime('DD MMM YYYY', Now);
end;

procedure TfrmMain.TmrInfoTimer(Sender: TObject);
begin
  PpNtfrInfo.Visible := false;
end;

procedure TfrmMain.closeApp;
begin
  Aborting := true;
  Close;
end;

end.

