unit Umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, Menus, StdCtrls, EditBtn, UAbout, Uhelp, UOptions, uLicence;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnKill: TButton;
    btnSearch: TButton;
    btnClear: TButton;
    btnExit: TButton;
    ChckGrpChoice: TCheckGroup;
    DrctryEdtRoot: TDirectoryEdit;
    GrpBxRoot: TGroupBox;
    MmFiles: TMemo;
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
    stsBrInfo: TStatusBar;
    Timer1: TTimer;
    procedure btnClearClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure DrctryEdtRootAcceptDirectory(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure mnuItmAboutClick(Sender: TObject);
    procedure mnuItmExitClick(Sender: TObject);
    procedure mnuItmHelpClick(Sender: TObject);
    procedure mnuItmOptionsClick(Sender: TObject);
    procedure mnuLicenceClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure walkDirectory(dir : string);
    procedure fileFound(FileIterator : TFileIterator);
    procedure closeApp;
  public
    noOfTicks : integer ;
  end; 

var
  frmMain  : TfrmMain;
  aborting : Boolean;
implementation

{$R *.lfm}

{ TfrmMain }


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ChckGrpChoice.Checked[0] := true;
  aborting := false;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  DrctryEdtRoot.Directory := '';
  DrctryEdtRoot.Enabled   := true;
  ChckGrpChoice.Enabled   := true;
  btnSearch.Enabled       := false;
  btnClear.Enabled        := false;

  MmFiles.Clear;
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
begin
  btnSearch.Enabled     := false;
  DrctryEdtRoot.Enabled := false;
  ChckGrpChoice.Enabled := false;
  btnClear.Enabled      := true;

  walkDirectory(DrctryEdtRoot.Directory);
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
  fileSearch := TFileSearcher.Create;
  fileSearch.OnFileFound := @fileFound;
  fileSearch.Search(dir, '*.*', true);
  fileSearch.Free;
  //  search finished.

  stsBrInfo.Panels.Items[2].Text:= 'Finished walking ' + dir + ' now, Sir!' ;
end;

procedure TfrmMain.fileFound(FileIterator : TFileIterator);
{  called each time a search file is found, stores file in filestore.                              }
begin
    // process all user events, like clicking on the button
    Application.ProcessMessages;
    if Aborting or Application.Terminated then closeApp;  //  exit clicked

    if ChckGrpChoice.Checked[0] and (FileIterator.FileInfo.Name = 'Thumbs.db') then
      MmFiles.Append(FileIterator.FileName);

    if ChckGrpChoice.Checked[1] and (ExtractFileExt(FileIterator.FileName) = '.nfo') then
      MmFiles.Append(FileIterator.FileName);

    if ChckGrpChoice.Checked[2] and (ExtractFileExt(FileIterator.FileName) = '.m3u') then
      MmFiles.Append(FileIterator.FileName);

    if ChckGrpChoice.Checked[3] and (ExtractFileExt(FileIterator.FileName) = '.tmp') then
      MmFiles.Append(FileIterator.FileName);

    if ChckGrpChoice.Checked[4] and (ExtractFileExt(FileIterator.FileName) = '.bac') then
      MmFiles.Append(FileIterator.FileName);

    if ChckGrpChoice.Checked[5] and (ExtractFileExt(FileIterator.FileName) = '.log') then
      MmFiles.Append(FileIterator.FileName);
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

