unit swfcompiler;

{
 This Adobe Flash compilation unit was made by Popov Evgeniy Alekseyevich.
 It is distributed under the GNU GENERAL PUBLIC LICENSE (Version 2 or higher).
}

{$IFDEF FPC}
 {$mode objfpc}
{$ENDIF}
{$H+}

interface

uses Classes, SysUtils;

function get_flash_projector():string;
function compile_flash_movie(const source:string):boolean;
function batch_compile_flash(const directory:string):LongWord;
function run_flash_compilation(const target:string;const batch:boolean):string;

implementation

function is_valid_directory(var search:TSearchRec):boolean;
begin
 is_valid_directory:=((search.Attr and faDirectory)<>0) and (search.Name<>'.') and (search.Name<>'..');
end;

function is_valid_file(var search:TSearchRec):boolean;
begin
 is_valid_file:=((search.Attr and faDirectory)=0) and (ExtractFileExt(search.Name)='.swf');
end;

function get_flash_projector():string;
begin
 get_flash_projector:=ExtractFilePath(ParamStr(0))+'flashplayer_32_sa.exe';
end;

function compile_flash_movie(const source:string):boolean;
var size,signature:LongWord;
var movie:string;
var success:boolean;
var projector,swf,target:TFileStream;
begin
 projector:=nil;
 swf:=nil;
 target:=nil;
 success:=True;
 signature:=$FA123456;
 size:=0;
 movie:=ChangeFileExt(source,'.exe');
 try
  projector:=TFileStream.Create(get_flash_projector(),fmOpenRead);
  swf:=TFileStream.Create(source,fmOpenRead);
  target:=TFileStream.Create(movie,fmCreate);
  target.CopyFrom(projector,0);
  target.CopyFrom(swf,0);
  size:=swf.Size;
  target.WriteBuffer(signature,SizeOf(LongWord));
  target.WriteBuffer(size,SizeOf(LongWord));
 except
  success:=False;
 end;
 if projector<>nil then projector.Free();
 if target<>nil then target.Free();
 if swf<>nil then swf.Free();
 if success=False then DeleteFile(movie);
 compile_flash_movie:=success;
end;

function batch_compile_flash(const directory:string):LongWord;
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
    if compile_flash_movie(target)=True then Inc(amount);
   end;
   if is_valid_directory(search)=True then
   begin
    amount:=amount+batch_compile_flash(target);
   end;
  until FindNext(search)<>0;
  FindClose(search);
 end;
 batch_compile_flash:=amount;
end;

function run_flash_compilation(const target:string;const batch:boolean):string;
var status:string;
begin
 status:='The operation was successfully completed';
 if batch=False then
 begin
  if compile_flash_movie(target)=False then status:='The operation failed';
 end
 else
 begin
  status:='Number of the converted files: '+IntToStr(batch_compile_flash(target));
 end;
 run_flash_compilation:=status;
end;

end.
