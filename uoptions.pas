unit UOptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrmOptions }

  TfrmOptions = class(TForm)
    btnExit: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btnExitClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation

{$R *.lfm}

{ TfrmOptions }

procedure TfrmOptions.btnExitClick(Sender: TObject);
begin
  Close;
end;

end.
