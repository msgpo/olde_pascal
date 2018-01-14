unit pcx;

interface

uses
  crt,vgraph,palette,modex;


procedure ReadPcx(name : string; x,y : integer; where : word);
procedure XReadPcx(name : string; x,y : integer);
procedure DrawScaledPcx(name : string; x,y,step : integer; where : word);

implementation

procedure ReadPcx(name : string; x,y : integer; where : word);

type
  palettetype=array[0..255,1..3] of byte;
  pcxheader=record
    man,ver,enc,bpp: byte;
    x1,y1,xh,yh,hres,vres:word;
    palette: array [0..47] of byte;
    rsr,cp: byte;
    bpl: word;
    ptype: word;
    filler: array [0..57] of byte;
  end;

var
  header: pcxheader;
  bytes: word;
  f: file;
  c: byte;
  _pal:palettetype;
  i,j,k,z,zz:integer;
  width,height:integer;

begin
  assign(f,name);
  {$I-} reset(f,1); {$I+}
  if ioresult=0 then
  begin
    blockread(f,header,sizeof(header));
    if (header.man=10) and (header.ver=5) and (header.bpp=8) and (header.cp=1) then
    begin
      seek (f,filesize(f)-769);
      blockread (f,c,1);
      if (c=12) then
      begin
        blockread (f,_pal, 768);
        for i:=0 to 255 do for j:=1 to 3 do _pal[i,j]:=_pal[i,j] shr 2;
        for i:=0 to 255 do pal(i,_pal[i,1],_pal[i,2],_pal[i,3]);
        seek (f, 128);
        width:=header.xh-header.x1;
        height:=header.yh-header.y1;
        bytes:=header.bpl;
        for j:=0 to height do
        begin
          I:=0;
          K:=0;
          while (bytes>k) do
          begin
            blockread(f,c,1);
            if ((c and 192) = 192) then
            begin
              z:=c and 63;
              blockread (f,c,1);
              inc(k,z);
              for zz:=0 to z-1 do
              begin
                putpixel(i+x,j,c,where);
                inc(i);
              end;
            end else
            begin
              inc(k);
              putpixel(i+y,j,c,where);
              inc(i);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure XReadPcx(name : string; x,y : integer);

type
  palettetype=array[0..255,1..3] of byte;
  pcxheader=record
    man,ver,enc,bpp: byte;
    x1,y1,xh,yh,hres,vres:word;
    palette: array [0..47] of byte;
    rsr,cp: byte;
    bpl: word;
    ptype: word;
    filler: array [0..57] of byte;
  end;

var
  header: pcxheader;
  bytes: word;
  f: file;
  c: byte;
  _pal:palettetype;
  i,j,k,z,zz:integer;
  width,height:integer;

begin
  assign(f,name);
  {$I-} reset(f,1); {$I+}
  if ioresult=0 then
  begin
    blockread(f,header,sizeof(header));
    if (header.man=10) and (header.ver=5) and (header.bpp=8) and (header.cp=1) then
    begin
      seek (f,filesize(f)-769);
      blockread (f,c,1);
      if (c=12) then
      begin
        blockread (f,_pal, 768);
        for i:=0 to 255 do for j:=1 to 3 do _pal[i,j]:=_pal[i,j] shr 2;
        for i:=0 to 255 do pal(i,_pal[i,1],_pal[i,2],_pal[i,3]);
        seek (f, 128);
        width:=header.xh-header.x1;
        height:=header.yh-header.y1;
        bytes:=header.bpl;
        for j:=0 to height do
        begin
          I:=0;
          K:=0;
          while (bytes>k) do
          begin
            blockread(f,c,1);
            if ((c and 192) = 192) then
            begin
              z:=c and 63;
              blockread (f,c,1);
              inc(k,z);
              for zz:=0 to z-1 do
              begin
                c4putpixel(i+x,j+y,c);
                inc(i);
              end;
            end else
            begin
              inc(k);
              c4putpixel(i+x,j+y,c);
              inc(i);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure DrawScaledPcx(name : string; x,y,step : integer; where : word);

type
  palettetype=array[0..255,1..3] of byte;
  pcxheader=record
    man,ver,enc,bpp: byte;
    x1,y1,xh,yh,hres,vres:word;
    palette: array [0..47] of byte;
    rsr,cp: byte;
    bpl: word;
    ptype: word;
    filler: array [0..57] of byte;
  end;

var
  header: pcxheader;
  bytes: word;
  f: file;
  c: byte;
  _pal:palettetype;
  i,j,k,z,zz:integer;
  width,height:integer;
  counter : integer;

begin
  assign(f,name);
  {$I-} reset(f,1); {$I+}
  if ioresult=0 then
  begin
    blockread(f,header,sizeof(header));
    if (header.man=10) and (header.ver=5) and (header.bpp=8) and (header.cp=1) then
    begin
      seek (f,filesize(f)-769);
      blockread (f,c,1);
      if (c=12) then
      begin
        blockread (f,_pal, 768);
        for i:=0 to 255 do for j:=1 to 3 do _pal[i,j]:=_pal[i,j] shr 2;
        for i:=0 to 255 do pal(i,_pal[i,1],_pal[i,2],_pal[i,3]);
        seek (f, 128);
        width:=header.xh-header.x1;
        height:=header.yh-header.y1;
        bytes:=header.bpl;
        for j:=0 to height do
        begin
          I:=0;
          K:=0;
          while (bytes>k) do
          begin
            blockread(f,c,1);
            if ((c and 192) = 192) then
            begin
              z:=c and 63;
              blockread (f,c,1);
              inc(k,z);
              for zz:=0 to z-1 do
              begin
                   putpixel(i+x,j+y,c,where);
                   inc(i);
              end;
            end else
            begin
              inc(k);
              if (counter=step) then
              begin
                   putpixel(i+x,j+y,c,where);
                   counter:=0;
                   inc(i);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

end.