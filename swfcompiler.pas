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

implementation

procedure fast_data_copy(var source:TFileStream;var target:TFileStream);
var buffer:Pointer;
var amount:LongInt;
const size=4194304;
begin
 source.Seek(0,soFromBeginning);
 GetMem(buffer,size);
 while Source.Position<Source.Size do
 begin
  amount:=source.Read(buffer^,size);
  if amount>0 then target.Write(buffer^,amount);
 end;
 Freemem(buffer);
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
  fast_data_copy(projector,target);
  fast_data_copy(swf,target);
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

end.
