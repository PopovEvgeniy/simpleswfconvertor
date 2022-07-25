unit simpleswfconvertorcode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, LazFileUtils ,LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit1Change(Sender: TObject);
    procedure OpenDialog1CanClose(Sender: TObject; var CanClose: boolean);
    procedure SelectDirectoryDialog1CanClose(Sender: TObject;
      var CanClose: Boolean);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var Form1: TForm1;

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
  if MessageDlg(Application.Title,'Flash player projector not found. Do you want open download page?',mtConfirmation,mbYesNo,0)=mrYes then
  begin
   OpenDocument('https://archive.org/details/adobe-flash-player-projector');
  end;

 end;

end;

procedure window_setup();
begin
 Application.Title:='Simple swf convertor';
 Form1.Caption:='Simple swf convertor 1.5';
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
 Form1.Button2.ShowHint:=Form1.Button1.ShowHint;
 Form1.Button2.Enabled:=False;
 Form1.LabeledEdit1.Text:='';
 Form1.LabeledEdit1.LabelPosition:=lpLeft;
 Form1.LabeledEdit1.Enabled:=False;
 Form1.RadioButton1.Checked:=True;
 Form1.RadioButton2.Checked:=False;
end;

procedure common_setup();
begin
 window_setup();
 interface_setup();
 dialog_setup();
end;

procedure language_setup();
begin
 Form1.LabeledEdit1.EditLabel.Caption:='Target';
 Form1.Button1.Caption:='Set';
 Form1.Button2.Caption:='Convert';
 Form1.OpenDialog1.Title:='Open a Adobe flash movie';
 Form1.StatusBar1.SimpleText:='Please set the target';
 Form1.RadioButton1.Caption:='Normal';
 Form1.RadioButton2.Caption:='Batch';
 Form1.Label1.Caption:='Mode';
 Form1.SelectDirectoryDialog1.Title:='Select target directory';
end;

procedure setup();
begin
 common_setup();
 language_setup();
 check_projector();
end;

function compile_flash_movie(source:string):boolean;
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
  size:=0;
 end;
 if projector<>nil then projector.Free();
 if swf<>nil then swf.Free();
 if target<>nil then target.Free();
 compile_flash_movie:=FileExists(movie);
end;

function batch_compile_flash(directory:string):LongWord;
var amount:LongWord;
var search:TSearchRec;
begin
 amount:=0;
 if FindFirst(directory+DirectorySeparator+'*.swf',faAnyFile,search)=0 then
 begin
  repeat
   if compile_flash_movie(directory+DirectorySeparator+search.Name)=True then Inc(amount);
  until FindNext(search)<>0;
  FindClose(search);
 end;
 batch_compile_flash:=amount;
end;

function compile_flash(target:string):string;
var status:string;
begin
 status:='Operation was successfully complete';
 if compile_flash_movie(target)=False then
 begin
  status:='Operation failed';
 end;
 compile_flash:=status;
end;

function batch_compile(target:string):string;
begin
 batch_compile:='Amount of converted files: '+IntToStr(batch_compile_flash(target));
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
 setup();
end;

procedure TForm1.LabeledEdit1Change(Sender: TObject);
begin
 Form1.Button2.Enabled:=Form1.LabeledEdit1.Text<>'';
end;

procedure TForm1.OpenDialog1CanClose(Sender: TObject; var CanClose: boolean);
begin
 Form1.LabeledEdit1.Text:=Form1.OpenDialog1.FileName;
 Form1.StatusBar1.SimpleText:='Ready';
end;

procedure TForm1.SelectDirectoryDialog1CanClose(Sender: TObject;
  var CanClose: Boolean);
begin
 Form1.LabeledEdit1.Text:=Form1.SelectDirectoryDialog1.FileName;
 Form1.StatusBar1.SimpleText:='Ready';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 if Form1.RadioButton1.Checked=True then
 begin
  Form1.OpenDialog1.Execute();
 end
 else
 begin
  Form1.SelectDirectoryDialog1.Execute();
 end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form1.StatusBar1.SimpleText:='Please wait';
  Form1.Button1.Enabled:=False;
  Form1.Button2.Enabled:=False;
 if Form1.RadioButton1.Checked=True then
 begin
  Form1.StatusBar1.SimpleText:=compile_flash(Form1.LabeledEdit1.Text);
 end
 else
 begin
  Form1.StatusBar1.SimpleText:=batch_compile(Form1.LabeledEdit1.Text);
 end;
  Form1.Button1.Enabled:=True;
  Form1.Button2.Enabled:=True;
end;

{$R *.lfm}

end.
