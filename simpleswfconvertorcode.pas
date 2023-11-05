unit simpleswfconvertorcode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, LazFileUtils ,LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    LabeledEdit1: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var Form1: TForm1;

implementation

procedure window_setup();
begin
 Application.Title:='Simple swf convertor';
 Form1.Caption:='Simple swf convertor 1.7.2';
 Form1.BorderStyle:=bsDialog;
 Form1.Font.Name:=Screen.MenuFont.Name;
 Form1.Font.Size:=14;
end;

procedure dialog_setup();
begin
 Form1.SelectDirectoryDialog1.InitialDir:='';
 Form1.OpenDialog1.InitialDir:='';
 Form1.OpenDialog1.FileName:='*.swf';
 Form1.OpenDialog1.DefaultExt:='*.swf';
 Form1.OpenDialog1.Filter:='Adobe flash movies|*.swf';
end;

procedure interface_setup();
begin
 Form1.Button1.ShowHint:=False;
 Form1.Button2.ShowHint:=False;
 Form1.Button2.Enabled:=False;
 Form1.LabeledEdit1.Text:='';
 Form1.LabeledEdit1.LabelPosition:=lpLeft;
 Form1.LabeledEdit1.Enabled:=False;
 Form1.CheckBox1.Checked:=False;
 Form1.CheckBox2.Checked:=False;
end;

procedure language_setup();
begin
 Form1.LabeledEdit1.EditLabel.Caption:='Target';
 Form1.Button1.Caption:='Set';
 Form1.Button2.Caption:='Convert';
 Form1.OpenDialog1.Title:='Open a Adobe flash movie';
 Form1.StatusBar1.SimpleText:='Please set the target';
 Form1.CheckBox1.Caption:='Batch mode';
 Form1.CheckBox2.Caption:='Delete source Adobe Flash movie after conversion';
 Form1.SelectDirectoryDialog1.Title:='Select target directory';
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
  if MessageDlg(Application.Title,'Flash player projector not found. Do you want open download page?',mtConfirmation,mbYesNo,0)=mrYes then
  begin
   OpenDocument('https://archive.org/details/adobe-flash-player-projector');
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
 status:='Operation was successfully complete';
 if batch=False then
 begin
  if compile_flash_movie(target,delete_source)=False then status:='Operation failed';
 end
 else
 begin
  status:='Amount of converted files: '+IntToStr(batch_compile_flash(target,delete_source));
 end;
 do_job:=status;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
 setup();
end;

procedure TForm1.LabeledEdit1Change(Sender: TObject);
begin
 if Form1.LabeledEdit1.Text<>'' then
 begin
  Form1.Button2.Enabled:=True;
  Form1.StatusBar1.SimpleText:='Ready';
 end;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 if Form1.CheckBox1.Checked=True then
 begin
  if Form1.SelectDirectoryDialog1.Execute()=True then Form1.LabeledEdit1.Text:=Form1.SelectDirectoryDialog1.FileName;
 end
 else
 begin
  if Form1.OpenDialog1.Execute()=True then Form1.LabeledEdit1.Text:=Form1.OpenDialog1.FileName;
 end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form1.StatusBar1.SimpleText:='Please wait';
  Form1.Button1.Enabled:=False;
  Form1.Button2.Enabled:=False;
  Form1.StatusBar1.SimpleText:=do_job(Form1.LabeledEdit1.Text,Form1.CheckBox1.Checked,Form1.CheckBox2.Checked);
  Form1.Button1.Enabled:=True;
  Form1.Button2.Enabled:=True;
end;

{$R *.lfm}

end.
