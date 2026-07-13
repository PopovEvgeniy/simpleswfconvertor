unit simpleswfconvertorcode;

{
 This sofware was made by Popov Evgeniy Alekseyevich.
 It is distributed under the GNU GENERAL PUBLIC LICENSE (Version 2 or higher).
}

{$mode objfpc}
{$H+}

interface

uses Classes, SysUtils, Forms, Controls, Dialogs, ExtCtrls, StdCtrls, ComCtrls, LCLIntf, swfcompiler;

type

  { TMainWindow }

  TMainWindow = class(TForm)
    SetButton: TButton;
    ConvertButton: TButton;
    TargetField: TLabeledEdit;
    OpenDialog: TOpenDialog;
    procedure SetButtonClick(Sender: TObject);
    procedure ConvertButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TargetFieldChange(Sender: TObject);
  private
    procedure window_setup();
    procedure dialog_setup();
    procedure interface_setup();
    procedure language_setup();
    procedure setup();
  public
    { public declarations }
  end; 

var MainWindow: TMainWindow;

implementation

procedure check_projector();
var target:string;
begin
 target:=get_flash_projector();
 if FileExists(target)=False then
 begin
  if MessageDlg(Application.Title,'The Flash Player Projector was not found. Do you want to open the download page?',mtConfirmation,mbYesNo,0)=mrYes then
  begin
   OpenDocument('https://archive.org/details/flash-projectors');
  end;

 end;

end;

procedure TMainWindow.window_setup();
begin
 Application.Title:='Simple SWF convertor';
 Self.Caption:='Simple SWF convertor 2.0.4';
 Self.BorderStyle:=bsDialog;
 Self.Font.Name:=Screen.MenuFont.Name;
 Self.Font.Size:=14;
end;

procedure TMainWindow.dialog_setup();
begin
 Self.OpenDialog.InitialDir:='';
 Self.OpenDialog.FileName:='';
 Self.OpenDialog.DefaultExt:='*.swf';
 Self.OpenDialog.Filter:='Adobe flash movies|*.swf';
end;

procedure TMainWindow.interface_setup();
begin
 Self.SetButton.ShowHint:=False;
 Self.ConvertButton.ShowHint:=False;
 Self.ConvertButton.Enabled:=False;
 Self.TargetField.Text:='';
 Self.TargetField.LabelPosition:=lpLeft;
 Self.TargetField.Enabled:=False;
end;

procedure TMainWindow.language_setup();
begin
 Self.TargetField.EditLabel.Caption:='Target';
 Self.SetButton.Caption:='Set';
 Self.ConvertButton.Caption:='Convert';
 Self.OpenDialog.Title:='Open an Adobe flash movie';
end;

procedure TMainWindow.setup();
begin
 Self.window_setup();
 Self.interface_setup();
 Self.dialog_setup();
 Self.language_setup();
end;

{ TMainWindow }

procedure TMainWindow.FormCreate(Sender: TObject);
begin
 Self.setup();
 check_projector();
end;

procedure TMainWindow.TargetFieldChange(Sender: TObject);
begin
 Self.ConvertButton.Enabled:=Self.TargetField.Text<>'';
end;

procedure TMainWindow.SetButtonClick(Sender: TObject);
begin
 if Self.OpenDialog.Execute()=True then Self.TargetField.Text:=Self.OpenDialog.FileName;
end;

procedure TMainWindow.ConvertButtonClick(Sender: TObject);
begin
  Self.SetButton.Enabled:=False;
  Self.ConvertButton.Enabled:=False;
  if compile_flash_movie(Self.TargetField.Text)=True then
  begin
   ShowMessage('The operation was successfully completed');
  end
  else
  begin
   ShowMessage('The operation failed');
  end;
  Self.SetButton.Enabled:=True;
  Self.ConvertButton.Enabled:=True;
end;

{$R *.lfm}

end.
