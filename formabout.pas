unit formAbout;

{  Display About info.  }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  LCLVersion, ExtCtrls, uInfo;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    btnAboutExit: TButton;
    Image1: TImage;
    lblContact: TLabel;
    lblKBCompileDate: TLabel;
    lblDiskSize: TLabel;
    lblKBFversion: TLabel;
    lblProgrammer: TLabel;
    lblProgramDescription: TLabel;
    lblProgramName: TLabel;
    lblLazarusVersion: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btnAboutExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }


procedure TfrmAbout.btnAboutExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  dskSize: string;
  dskFree: string;

begin
  dskFree := FloatToStrF(DiskFree(0) / 1073741824, ffFixed, 3, 2);
  dskSize := FloatToStrF(DiskSize(0) / 1073741824, ffFixed, 3, 2);

  {$ifdef WIN32}
    lblLazarusVersion.Caption := format('Built with 32 bit Lazarus Version :: %s', [lcl_version]);
  {$else}
    lblLazarusVersion.Caption := format('Built with 64 bit Lazarus Version :: %s', [lcl_version]);
  {$endif}

  lblProgramName.Caption := appName;
  lblProgrammer.Caption := myName;
  lblContact.Caption := myEmail;
  lblKBCompileDate.Caption := 'KBF built :: 20/09/2017 22:43:01';
  lblKBFversion.Caption := appVersion;
  lblDiskSize.Caption := ' Disk Free / Size :: ' + dskFree + ' / ' + dskSize + ' Gbytes';
end;

end.
