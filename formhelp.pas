unit formHelp;

{  Display Help info.
   The Help info is loaded from a text file.  }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, uInfo;

type

  { TfrmHelp }

  TfrmHelp = class(TForm)
    btnhelpExit: TButton;
    mmoHelp: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btnhelpExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmHelp: TfrmHelp;

implementation

{$R *.lfm}

{ TfrmHelp }

procedure TfrmHelp.FormCreate(Sender: TObject);
begin
  mmoHelp.Append('Kill those Bothersome Files.');
  mmoHelp.Append('');
  mmoHelp.Append('');

  try
    mmoHelp.Lines.LoadFromFile('help.txt');
  except
    on Exception do
    begin
      mmoHelp.Append(' help file not found.');
      mmoHelp.Append('');
      mmoHelp.Append(' This file should include full and detailed help intructions.');
    end;
  end;

  mmoHelp.Append('');
  mmoHelp.Append('');
  mmoHelp.Append(strName);
  mmoHelp.Append(strCopyRight);
  mmoHelp.Append(strVersion);
end;

procedure TfrmHelp.btnhelpExitClick(Sender: TObject);
begin
  Close;
end;

end.
