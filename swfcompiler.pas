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

function get_flash_projector():string;
begin
 Result:=ExtractFilePath(ParamStr(0))+'flashplayer_32_sa.exe';
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
  projector:=TFileStream.Create(get_flash_projector(),fmOpenRead or fmShareDenyWrite);
  swf:=TFileStream.Create(source,fmOpenRead or fmShareDenyWrite);
  target:=TFileStream.Create(movie,fmCreate or fmShareExclusive);
  target.CopyFrom(projector,0);
  target.CopyFrom(swf,0);
  size:=swf.Size;
  target.Write(signature,SizeOf(LongWord));
  target.Write(size,SizeOf(LongWord));
 except
  success:=False;
 end;
 if target<>nil then target.Free();
 if swf<>nil then swf.Free();
 if projector<>nil then projector.Free();
 if success=False then DeleteFile(movie);
 Result:=success;
end;

end.
