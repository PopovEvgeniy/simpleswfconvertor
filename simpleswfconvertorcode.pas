unit simpleswfconvertorcode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, LazFileUtils ,LCLIntf;

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
    { private declarations }
  public
    { public declarations }
  end; 

var MainWindow: TMainWindow;

implementation

procedure window_setup();
begin
 Application.Title:='Simple swf convertor';
 MainWindow.Caption:='Simple swf convertor 1.7.6';
 MainWindow.BorderStyle:=bsDialog;
 MainWindow.Font.Name:=Screen.MenuFont.Name;
 MainWindow.Font.Size:=14;
end;

procedure dialog_setup();
begin
 MainWindow.SelectDirectoryDialog.InitialDir:='';
 MainWindow.OpenDialog.InitialDir:='';
 MainWindow.OpenDialog.FileName:='*.swf';
 MainWindow.OpenDialog.DefaultExt:='*.swf';
 MainWindow.OpenDialog.Filter:='Adobe flash movies|*.swf';
end;

procedure interface_setup();
begin
 MainWindow.SetButton.ShowHint:=False;
 MainWindow.ConvertButton.ShowHint:=False;
 MainWindow.ConvertButton.Enabled:=False;
 MainWindow.TargetField.Text:='';
 MainWindow.TargetField.LabelPosition:=lpLeft;
 MainWindow.TargetField.Enabled:=False;
 MainWindow.BatchCheckBox.Checked:=False;
 MainWindow.DeleteCheckBox.Checked:=False;
end;

procedure language_setup();
begin
 MainWindow.TargetField.EditLabel.Caption:='Target';
 MainWindow.SetButton.Caption:='Set';
 MainWindow.ConvertButton.Caption:='Convert';
 MainWindow.OpenDialog.Title:='Open an Adobe flash movie';
 MainWindow.OperationStatus.SimpleText:='Please set the target';
 MainWindow.BatchCheckBox.Caption:='Batch mode';
 MainWindow.DeleteCheckBox.Caption:='Delete a source movie after conversion';
 MainWindow.SelectDirectoryDialog.Title:='Select the target directory';
end;

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

procedure setup();
begin
 window_setup();
 interface_setup();
 dialog_setup();
 language_setup();
 check_projector();
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

{ TMainWindow }

procedure TMainWindow.FormCreate(Sender: TObject);
begin
 setup();
end;

procedure TMainWindow.TargetFieldChange(Sender: TObject);
begin
 if MainWindow.TargetField.Text<>'' then
 begin
  MainWindow.ConvertButton.Enabled:=True;
  MainWindow.OperationStatus.SimpleText:='Ready';
 end;

end;

procedure TMainWindow.SetButtonClick(Sender: TObject);
begin
 if MainWindow.BatchCheckBox.Checked=True then
 begin
  if MainWindow.SelectDirectoryDialog.Execute()=True then MainWindow.TargetField.Text:=MainWindow.SelectDirectoryDialog.FileName;
 end
 else
 begin
  if MainWindow.OpenDialog.Execute()=True then MainWindow.TargetField.Text:=MainWindow.OpenDialog.FileName;
 end;

end;

procedure TMainWindow.ConvertButtonClick(Sender: TObject);
begin
  MainWindow.OperationStatus.SimpleText:='Please wait';
  MainWindow.SetButton.Enabled:=False;
  MainWindow.ConvertButton.Enabled:=False;
  MainWindow.OperationStatus.SimpleText:=do_job(MainWindow.TargetField.Text,MainWindow.BatchCheckBox.Checked,MainWindow.DeleteCheckBox.Checked);
  MainWindow.SetButton.Enabled:=True;
  MainWindow.ConvertButton.Enabled:=True;
end;

{$R *.lfm}

end.
