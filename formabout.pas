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
    btnAboutExit         : TButton;
    Image1               : TImage;
    lblContact           : TLabel;
    lblKBCompileDate     : TLabel;
    lblDiskSize          : TLabel;
    lblKBFversion        : TLabel;
    lblProgrammer        : TLabel;
    lblProgramDescription: TLabel;
    lblProgramName       : TLabel;
    lblLazarusVersion    : TLabel;
    Panel1               : TPanel;
    Panel2               : TPanel;

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
  dskSize  : string;
  dskFree  : string;
  cmpDate  : string;
  cmpUkDate: string;

begin
  dskFree := FloatToStrF(DiskFree(0) / 1073741824, ffFixed, 3, 2);
  dskSize := FloatToStrF(DiskSize(0) / 1073741824, ffFixed, 3, 2);

  {$ifdef WIN32}
    lblLazarusVersion.Caption := format('Built with 32 bit Lazarus Version :: %s', [lcl_version]);
  {$else}
    lblLazarusVersion.Caption := format('Built with 64 bit Lazarus Version :: %s', [lcl_version]);
  {$endif}

  //  {$I %DATE%} returns the compile date, but in American [ignores local date format]
  //  So, we string slice it to give good old English date format.
  cmpDate               := {$I %DATE%};
  cmpUkDate             := format('%s/%s/%s', [copy(cmpDate, 9, 2),
                                               copy(cmpDate, 6, 2),
                                               copy(cmpDate, 1, 4)]);

  lblProgramName.Caption   := appName;
  lblProgrammer.Caption    := myName;
  lblContact.Caption       := myEmail;
  lblKBCompileDate.Caption := format('KBF Built   :: %s', [cmpUkDate + ' @ ' + {$I %TIME%}]);
  lblKBFversion.Caption    := appVersion;
  lblDiskSize.Caption      := ' Disk Free / Size :: ' + dskFree + ' / ' + dskSize + ' Gbytes';
end;

end.
