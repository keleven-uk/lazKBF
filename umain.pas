unit Umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, Menus, StdCtrls, EditBtn, CheckLst, Buttons, PopupNotifier, UAbout,
  Uhelp, UOptions, uLicence, MMSystem;

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
    PopupNotifier1: TPopupNotifier;
    RdGrpSelect: TRadioGroup;
    stsBrInfo: TStatusBar;
    Timer1: TTimer;
    procedure btnClearClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure ChckLstBxFilesClick(Sender: TObject);
    procedure DrctryEdtRootAcceptDirectory(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure mnuItmAboutClick(Sender: TObject);
    procedure mnuItmExitClick(Sender: TObject);
    procedure mnuItmHelpClick(Sender: TObject);
    procedure mnuItmOptionsClick(Sender: TObject);
    procedure mnuLicenceClick(Sender: TObject);
    procedure RdGrpSelectClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
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
  searching : Boolean;
  searchPos : Integer;
implementation

{$R *.lfm}

{ TfrmMain }


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ChckGrpChoice.Checked[0] := true;  //  default to Thumbs.db
  RdGrpSelect.ItemIndex    := 1;     //  default to Select None
  aborting                 := false;
  searching                := false;
  searchPos                := 0;
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
  aborting                 := false;

  ChckLstBxFiles.Clear;
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

procedure TfrmMain.ChckLstBxFilesClick(Sender: TObject);
VAR
  message : string;
  fname   : string;
  fpos    : integer;
  fsize   : Int64;
begin

  if ChckLstBxFiles.Items.Count <> 0 then begin  //  noting in list box, so do nothing.
    PopupNotifier1.ShowAtPos(100,100) ;
    PopupNotifier1.Title   := 'File Info';

    fpos  := ChckLstBxFiles.ItemIndex;
    fname := ChckLstBxFiles.Items.Strings[fpos];
    fsize := fileSize(fname);

    message := format('fileName :: %s. ', [fname]);
    message := message + LineEnding + format('fileSize :: %d bytes.', [fsize]);

    if PopupNotifier1.Visible = false then begin
      PopupNotifier1.Text    := message;
      PopupNotifier1.Visible := true ;
    end
    else begin  //  toggle popup.visable - performs a refresh.
      PopupNotifier1.Visible := false ;
      PopupNotifier1.Text    := message;
      PopupNotifier1.Visible := true ;
    end;

  end;  //  if ChckLstBxFiles.Items.Count = 0

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
VAR
  fileSearch : TFileSearcher;
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

  stsBrInfo.Panels.Items[2].Text:= 'Finished walking ' + dir + ' now, Sir!' ;

  Application.Title := format(' KBF :: Found %d files', [ChckLstBxFiles.Items.Count]);
  frmMain.Caption   := format(' KBF :: Found %d files', [ChckLstBxFiles.Items.Count]);

  RdGrpSelect.Enabled := true;
  btnKill.Enabled     := true;
end;

procedure TfrmMain.fileFound(FileIterator : TFileIterator);
{  called each time a search file is found, stores file in filestore.                              }
begin
    // process all user events, like clicking on the button
    Application.ProcessMessages;
    if Aborting or Application.Terminated then closeApp;  //  exit clicked

    if ChckGrpChoice.Checked[0] and (FileIterator.FileInfo.Name = 'Thumbs.db') then
      ChckLstBxFiles.Items.Add(FileIterator.FileName);

    if ChckGrpChoice.Checked[1] and (ExtractFileExt(FileIterator.FileName) = '.nfo') then
      ChckLstBxFiles.Items.Add(FileIterator.FileName);

    if ChckGrpChoice.Checked[2] and (ExtractFileExt(FileIterator.FileName) = '.m3u') then
      ChckLstBxFiles.Items.Add(FileIterator.FileName);

    if ChckGrpChoice.Checked[3] and (ExtractFileExt(FileIterator.FileName) = '.tmp') then
      ChckLstBxFiles.Items.Add(FileIterator.FileName);

    if ChckGrpChoice.Checked[4] and (ExtractFileExt(FileIterator.FileName) = '.bac') then
      ChckLstBxFiles.Items.Add(FileIterator.FileName);

    if ChckGrpChoice.Checked[5] and (ExtractFileExt(FileIterator.FileName) = '.log') then
      ChckLstBxFiles.Items.Add(FileIterator.FileName);
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

procedure TfrmMain.closeApp;
begin
  Aborting := true;
  Close;
end;

end.

