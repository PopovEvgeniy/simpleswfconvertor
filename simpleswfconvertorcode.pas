unit simpleswfconvertorcode;

{
 This sofware was made by Popov Evgeniy Alekseyevich.
 It is distributed under the GNU GENERAL PUBLIC LICENSE (Version 2 or higher).
}

{$mode objfpc}
{$H+}

interface

uses Classes, SysUtils, Forms, Controls, Dialogs, ExtCtrls, StdCtrls, ComCtrls, LazFileUtils ,LCLIntf;

type

  { TMainWindow }

  TMainWindow = class(TForm)
    SetButton: TButton;
    ConvertButton: TButton;
    BatchCheckBox: TCheckBox;
    DeleteCheckBox: TCheckBox;
    TargetField: TLabeledEdit;
    OpenDialog: TOpenDialog;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    OperationStatus: TStatusBar;
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

function get_projector(): string;
begin
 get_projector:=ExtractFilePath(ParamStr(0))+'flashplayer_32_sa.exe';
end;

procedure check_projector();
var target:string;
begin
 target:=get_projector();
 if FileExists(target)=False then
 begin
  if MessageDlg(Application.Title,'The Flash Player projector was not found. Do you want to open the download page?',mtConfirmation,mbYesNo,0)=mrYes then
  begin
   OpenDocument('https://archive.org/details/flash-projectors');
  end;

 end;

end;

function compile_flash_movie(const source:string;const delete_source:boolean):boolean;
var size,flag:LongWord;
var movie:string;
var projector,swf,target:TFileStream;
begin
 projector:=nil;
 swf:=nil;
 target:=nil;
 flag:=$FA123456;
 size:=0;
 movie:=ExtractFileNameWithoutExt(source)+'.exe';
 try
  projector:=TFileStream.Create(get_projector(),fmOpenRead);
  swf:=TFileStream.Create(source,fmOpenRead);
  target:=TFileStream.Create(movie,fmCreate);
  target.CopyFrom(projector,0);
  target.CopyFrom(swf,0);
  size:=swf.Size;
  target.WriteDWord(flag);
  target.WriteDWord(size);
 except
  ;
 end;
 if projector<>nil then projector.Free();
 if target<>nil then target.Free();
 if swf<>nil then
 begin
  swf.Free();
  if delete_source=True then DeleteFile(source);
 end;
 compile_flash_movie:=FileExists(movie);
end;

function is_valid_directory(var search:TSearchRec):boolean;
begin
 is_valid_directory:=((search.Attr and faDirectory)<>0) and (search.Name<>'.') and (search.Name<>'..');
end;

function is_valid_file(var search:TSearchRec):boolean;
begin
 is_valid_file:=((search.Attr and faDirectory)=0) and (ExtractFileExt(search.Name)='.swf');
end;

function batch_compile_flash(const directory:string;const delete_source:boolean):LongWord;
var target:string;
var amount:LongWord;
var search:TSearchRec;
begin
 amount:=0;
 if FindFirst(directory+DirectorySeparator+'*.*',faAnyFile,search)=0 then
 begin
  repeat
   target:=directory+DirectorySeparator+search.Name;
   if is_valid_file(search)=True then
   begin
    if compile_flash_movie(target,delete_source)=True then Inc(amount);
   end;
   if is_valid_directory(search)=True then
   begin
    amount:=amount+batch_compile_flash(target,delete_source);
   end;
  until FindNext(search)<>0;
  FindClose(search);
 end;
 batch_compile_flash:=amount;
end;

function do_job(const target:string;const batch:boolean;const delete_source:boolean):string;
var status:string;
begin
 status:='The operation was successfully completed';
 if batch=False then
 begin
  if compile_flash_movie(target,delete_source)=False then status:='The operation was failed';
 end
 else
 begin
  status:='Amount of the converted files: '+IntToStr(batch_compile_flash(target,delete_source));
 end;
 do_job:=status;
end;

procedure TMainWindow.window_setup();
begin
 Application.Title:='Simple swf convertor';
 Self.Caption:='Simple swf convertor 1.7.7';
 Self.BorderStyle:=bsDialog;
 Self.Font.Name:=Screen.MenuFont.Name;
 Self.Font.Size:=14;
end;

procedure TMainWindow.dialog_setup();
begin
 Self.SelectDirectoryDialog.InitialDir:='';
 Self.OpenDialog.InitialDir:='';
 Self.OpenDialog.FileName:='*.swf';
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
 Self.BatchCheckBox.Checked:=False;
 Self.DeleteCheckBox.Checked:=False;
end;

procedure TMainWindow.language_setup();
begin
 Self.TargetField.EditLabel.Caption:='Target';
 Self.SetButton.Caption:='Set';
 Self.ConvertButton.Caption:='Convert';
 Self.OpenDialog.Title:='Open an Adobe flash movie';
 Self.OperationStatus.SimpleText:='Please set the target';
 Self.BatchCheckBox.Caption:='Batch mode';
 Self.DeleteCheckBox.Caption:='Delete a source movie after conversion';
 Self.SelectDirectoryDialog.Title:='Select the target directory';
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
 if Self.TargetField.Text<>'' then
 begin
  Self.ConvertButton.Enabled:=True;
  Self.OperationStatus.SimpleText:='Ready';
 end;

end;

procedure TMainWindow.SetButtonClick(Sender: TObject);
begin
 if Self.BatchCheckBox.Checked=True then
 begin
  if Self.SelectDirectoryDialog.Execute()=True then Self.TargetField.Text:=Self.SelectDirectoryDialog.FileName;
 end
 else
 begin
  if Self.OpenDialog.Execute()=True then Self.TargetField.Text:=Self.OpenDialog.FileName;
 end;

end;

procedure TMainWindow.ConvertButtonClick(Sender: TObject);
begin
  Self.OperationStatus.SimpleText:='Please wait';
  Self.SetButton.Enabled:=False;
  Self.ConvertButton.Enabled:=False;
  Self.OperationStatus.SimpleText:=do_job(Self.TargetField.Text,Self.BatchCheckBox.Checked,Self.DeleteCheckBox.Checked);
  Self.SetButton.Enabled:=True;
  Self.ConvertButton.Enabled:=True;
end;

{$R *.lfm}

end.
