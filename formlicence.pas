unit formLicence;

{  Display Licence info.
   The Licence info is loaded from a text file.  }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  ExtCtrls, uInfo;

type

  { TfrmLicence }

  TfrmLicence = class(TForm)
    btnLicenceExit: TButton;
    mmoLicence: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btnLicenceExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmLicence: TfrmLicence;

implementation

{$R *.lfm}

{ TfrmLicence }

procedure TfrmLicence.FormCreate(Sender: TObject);
begin
  mmoLicence.Append('Kill those Bothersome Files.');
  mmoLicence.Append('');
  try
    mmoLicence.Lines.LoadFromFile('GNU GENERAL PUBLIC LICENSE.txt');
  except
    on Exception do
    begin
      mmoLicence.Append(' help License not found.');
      mmoLicence.Append('');
      mmoLicence.Append(' The application is issued under the GNU GENERAL PUBLIC LICENSE.');
    end;
  end;

  mmoLicence.Append('');
  mmoLicence.Append(myName);
  mmoLicence.Append(myEmail);
  mmoLicence.Append(appVersion);
end;

procedure TfrmLicence.btnLicenceExitClick(Sender: TObject);
begin
  Close;
end;

end.
