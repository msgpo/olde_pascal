unit vgraph2;

interface

uses crt,palette;

type image=object
     bits : array[1..20,1..20] of byte;
     max_x,max_y : integer;
end;

const
     vga=$a000;
     AndPut=1;
     NormalPut=2;
     XORPut=3;
     ORPut=4;
     NoDistort=5;
     vidseg:word=$a000;
     rom_char_set=$F000FA6E;

type vscreen = array[1..64000] of byte;
     vptr=^vscreen;

var
   virscr,virscr2 : vptr;
   vaddr,vaddr2 : word;

procedure SetGraphics;
procedure Pause;
procedure SetText;
procedure Cls(where : word; col : byte);
procedure SetVirtual;
procedure RemoveVirtual;
procedure Flip(source,dest : word);
procedure PutPixel(x,y : integer; col : byte; where : word);
function GetPixel(x,y : integer; where : word) : byte;
procedure Hline(x1,x2,y : integer; col : byte; where : word);
procedure Vline(y1,y2,x : integer; col : byte; where : word);
procedure Line(a,b,c,d : integer; col : byte; where : word);
procedure Circle(x,y,rad : integer; col : byte; where : word);
procedure Box(x,y,incx,incy : integer; color : byte; where : word);
procedure Box2(x,y,incx1,incx2,incy1,incy2 : integer; color : byte; where : word);
procedure GetImage(var pic : image; x1,y1,x2,y2 : integer; where : word);
procedure GetImage2(x1,y1,x2,y2:integer; var bitmap:pointer; needmem:boolean);
procedure PutImage(pic : image; x,y : integer; trans : byte; where : word);
procedure PutImage2(x,y:integer; bitmap:pointer; mode:byte;where:word);
procedure XGetImage(x1,y1,x2,y2:integer; var bitmap:pointer; needmem:boolean);
procedure XPutImage(x,y:integer; bitmap:pointer; mode:byte; where : word);
procedure SaveImage(pic : image; filename : string);
procedure LoadImage(filename : string; var pic : image);
procedure ClearImage(var pic : image; col : integer);
procedure LoadScreen(filename : string; where : word);
procedure Text(x,y: integer; str: string; col :byte; where : word);
procedure Fill(x,y : integer; col : byte; boundcol : byte; where : word);
procedure Setup;
procedure SetupSVGA;
procedure putpixel_svga(x,y : integer; col : byte);
procedure ShutDown;

implementation

procedure SetGraphics;
begin
     asm
        mov ax,0013h
        int 10h
     end;
end;

procedure Pause;
var c : char;
begin
     c:=Readkey;
end;

procedure SetText;
begin
     asm
        mov ax,0003h
        int 10h
     end;
end;

Procedure Cls (Where:word;Col : Byte);
   { This clears the screen to the specified color }
begin
     asm
        push    es
        mov     cx, 32000;
        mov     es,[where]
        xor     di,di
        mov     al,[col]
        mov     ah,al
        rep     stosw
        pop     es
     end;
end;

procedure SetVirtual;
begin
     GetMem(virscr,64000);
     vaddr:=seg(virscr^);
     GetMem(virscr2,64000);
     vaddr2:=seg(virscr2^);
end;

procedure RemoveVirtual;
begin
     FreeMem(virscr,64000);
     FreeMem(virscr2,64000);
end;

procedure flip(source,dest:Word);
  { This copies the entire screen at "source" to destination }
begin
  asm
    push    ds
    mov     ax, [Dest]
    mov     es, ax
    mov     ax, [Source]
    mov     ds, ax
    xor     si, si
    xor     di, di
    mov     cx, 32000
    rep     movsw
    pop     ds
  end;
end;

procedure xflip(source:word);
begin
     asm
        push ds
        mov ax,[vga]
        mov es,ax
        mov ax,[source]
        mov ds,ax
        xor si,si
        xor di,di
        mov   dx, 03c4h         { 03c4h                                    }
        mov   al, 2             { Map Mask Register                        }
        out   dx, al
        inc   dx
        mov   al, 00001111b     { Select all planes to write to            }
        out   dx, al
        mov cx,32000
        cld
        rep movsw
        pop ds
     end;
end;

Procedure Putpixel (X,Y : Integer; Col : Byte; where:word);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Asm
    mov     ax,[where]
    mov     es,ax
    mov     bx,[X]
    mov     dx,[Y]
    mov     di,bx
    mov     bx, dx                  {; bx = dx}
    shl     dx, 8
    shl     bx, 6
    add     dx, bx                  {; dx = dx + bx (ie y*320)}
    add     di, dx                  {; finalise location}
    mov     al, [Col]
    stosb
  End;
END;

function GetPixel(x,y : integer; where : word) : byte;
var temp : byte;
begin
     asm
        mov ax,[where]
        mov es,ax
        xor di,di
        mov ax,y
        mov bx,y
        shl ax,8
        shl bx,6
        add ax,bx
        add ax,x
        mov di,ax
        mov al,es:[di]
        mov temp,al
     end;
     GetPixel:=temp;
end;

procedure Hline(x1,x2,y : integer; col : byte; where : word);
var temp : integer;
begin
     if (x1>x2) then
     begin
          temp:=x1;
          x1:=x2;
          x2:=temp;
     end;

     asm
        mov ax,[where]
        mov es,ax
        mov ax,y
        mov bx,y
        shl ax,8
        shl bx,6
        add ax,bx
        add ax,x1
        mov di,ax
        mov cx,x2
        sub cx,x1
        mov al,col
        rep stosb
     end;
end;

procedure Vline(y1,y2,x : integer; col : byte; where : word);
var temp : integer;
begin
     if (y1>y2) then
     begin
          temp:=y1;
          y1:=y2;
          y2:=temp;
     end;

     asm
        mov ax,[where]
        mov es,ax
        mov ax,y1
        mov bx,y1
        shl ax,8
        shl bx,6
        add ax,bx
        add ax,x
        mov di,ax
        mov cx,y2
        sub cx,y1
        mov al,col
        @loop1:
               mov es:[di],al
               add di,320
        loop @loop1
     end;
end;

Procedure Line(a,b,c,d:integer;col:byte;where:word);
  { This draws a solid line from a,b to c,d in colour col }
  function sgn(a:real):integer;
  begin
       if a>0 then sgn:=+1;
       if a<0 then sgn:=-1;
       if a=0 then sgn:=0;
  end;
var i,s,d1x,d1y,d2x,d2y,u,v,m,n:integer;
begin
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := m shr 1;
     FOR i := 0 TO m DO
     BEGIN
          putpixel(a,b,col,where);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a + d1x;
               b := b + d1y;
          END
          ELSE
          BEGIN
               a := a + d2x;
               b := b + d2y;
          END;
     end;
END;

procedure Circle(x,y,rad : integer; col : byte; where : word);
var tempx,tempy : integer;
    deg : real;
begin
     deg:=0;
     tempx:=0;
     tempy:=0;

     while (deg<6.4) do
     begin
          tempx:=round(rad*cos(deg));
          tempy:=round(rad*sin(deg));
          putpixel(tempx+x,tempy+y,col,where);
          deg:=deg+0.05;
     end;
end;

procedure Box(x,y,incx,incy : integer; color : byte; where : word);
begin
     line(x-incx,y-incy,x+incx,y-incy,color,where);
     line(x-incx,y+incy,x+incx,y+incy,color,where);
     line(x-incx,y-incy,x-incx,y+incy,color,where);
     line(x+incx,y-incy,x+incx,y+incy,color,where);
end;

procedure Box2(x,y,incx1,incx2,incy1,incy2 : integer; color : byte; where : word);
begin
     line(x-incx1,y-incy1,x+incx2,y-incy1,color,where);
     line(x-incx1,y+incy2,x+incx2,y+incy2,color,where);
     line(x-incx1,y-incy1,x-incx1,y+incy2,color,where);
     line(x+incx2,y-incy1,x+incx2,y+incy2,color,where);
end;

procedure GetImage2(x1,y1,x2,y2:integer; var bitmap:pointer; needmem:boolean);
{This simply stores the box designated by (x1,y1)-(x2,y2) into the pointer
   NeedMem is a boolean.  If true, then this procedure gets the necessary
   memory for the pointer.  Else, it relies on the programmer getting the mem
   in his procs. (if NeedMem is false)}
var l1,l2,factor:word;
begin
     factor:=3;
     if needmem then
        getmem(bitmap,(x2-x1+1)*(y2-y1+1)+4);
     memw[seg(bitmap^):ofs(bitmap^)]:=(x2-x1);
     memw[seg(bitmap^):ofs(bitmap^)+2]:=(y2-y1);
     for l1:=y1 to y2 do
         for l2:=x1 to x2 do begin
             inc(factor);
             mem[seg(bitmap^):ofs(bitmap^)+factor]:=mem[$A000:(l1*320)+l2];
         end;
end;


procedure PutImage2(x,y:integer; bitmap:pointer; mode:byte;where:word);
var l1,l2,factor,xdiff,ydiff:word;
{This simply puts the image stored in a pointer back onto the screen.  It can
 XorPut it, AndPut it, NOrmal Put it, NoDistort (doesn't distort background,
 or ORPut it...}
begin
     factor:=3;
     xdiff:=memw[seg(bitmap^):ofs(bitmap^)];
     ydiff:=memw[seg(bitmap^):ofs(bitmap^)+2];
     for l1:=y to (y+ydiff) do
         for l2:=x to (x+xdiff) do begin
             inc(factor);
             case mode of
               NormalPut:mem[where:(320*l1)+l2]:=
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               AndPut:mem[where:(320*l1)+l2]:=mem[where:(320*l1)+l2] and
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               XORPut:mem[where:(320*l1)+l2]:=mem[where:(320*l1)+l2] xor
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               ORPut:mem[where:(320*l1)+l2]:=mem[where:(320*l1)+l2] or
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               NoDistort:if mem[seg(bitmap^):ofs(bitmap^)+factor]<>0 then
                                mem[where:(320*l1)+l2]:=
                                   mem[seg(bitmap^):ofs(bitmap^)+factor];
             end;
         end;
end;

procedure XGetImage(x1,y1,x2,y2:integer; var bitmap:pointer; needmem:boolean);
{This simply stores the box designated by (x1,y1)-(x2,y2) into the pointer
   NeedMem is a boolean.  If true, then this procedure gets the necessary
   memory for the pointer.  Else, it relies on the programmer getting the mem
   in his procs. (if NeedMem is false)}
var l1,l2,factor:word;
begin
     factor:=3;
     if needmem then
        getmem(bitmap,(x2-x1+1)*(y2-y1+1)+4);
     memw[seg(bitmap^):ofs(bitmap^)]:=(x2-x1);
     memw[seg(bitmap^):ofs(bitmap^)+2]:=(y2-y1);
     for l1:=y1 to y2 do
         for l2:=x1 to x2 do begin
             inc(factor);
             mem[seg(bitmap^):ofs(bitmap^)+factor]:=mem[$A000:(l1*320)+l2];
         end;
end;


procedure XPutImage(x,y:integer; bitmap:pointer; mode:byte; where : word);
var l1,l2,factor,xdiff,ydiff:word;
{This simply puts the image stored in a pointer back onto the screen.  It can
 XorPut it, AndPut it, NOrmal Put it, NoDistort (doesn't distort background,
 or ORPut it...}
begin
     factor:=3;
     xdiff:=memw[seg(bitmap^):ofs(bitmap^)];
     ydiff:=memw[seg(bitmap^):ofs(bitmap^)+2];
     for l1:=y to (y+ydiff) do
         for l2:=x to (x+xdiff) do begin
             inc(factor);
             case mode of
               NormalPut:mem[where:(320*l1)+l2]:=
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               AndPut:mem[where:(320*l1)+l2]:=mem[where:(320*l1)+l2] and
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               XORPut:mem[where:(320*l1)+l2]:=mem[where:(320*l1)+l2] xor
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               ORPut:mem[where:(320*l1)+l2]:=mem[where:(320*l1)+l2] or
                                 mem[seg(bitmap^):ofs(bitmap^)+factor];
               NoDistort:if mem[seg(bitmap^):ofs(bitmap^)+factor]<>0 then
                                mem[where:(320*l1)+l2]:=
                                   mem[seg(bitmap^):ofs(bitmap^)+factor];
             end;
         end;
end;

procedure SaveImage(pic : image; filename : string);
var loop1,loop2 : integer;
    temp : byte;
    fp : file of byte;
begin
     assign(fp,filename);
     rewrite(fp);

     temp:=pic.max_x;
     write(fp,temp);
     temp:=pic.max_y;
     write(fp,temp);

     for loop1:=1 to pic.max_x do
         for loop2:=1 to pic.max_y do
         begin
              temp:=pic.bits[loop1,loop2];
              write(fp,temp);
         end;
     close(fp);
end;

procedure LoadImage(filename : string; var pic : image);
var loop1,loop2 : integer;
    temp : byte;
    fp : file of byte;
begin
     assign(fp,filename);
     reset(fp);

     read(fp,temp);
     pic.max_x:=temp;
     read(fp,temp);
     pic.max_y:=temp;

     for loop1:=1 to pic.max_x do
         for loop2:=1 to pic.max_y do
         begin
              read(fp,temp);
              pic.bits[loop1,loop2]:=temp;
         end;
     close(fp);
end;

procedure ClearImage(var pic : image; col : integer);
var loop1,loop2 : integer;
begin
     for loop1:=1 to pic.max_x do
         for loop2:=1 to pic.max_y do
             pic.bits[loop1,loop2]:=col;
end;

procedure PutImage(pic : image; x,y : integer; trans : byte; where : word);
var loop1,loop2 : integer;
begin
     Dec(x);
     Dec(y);
     for loop1:=1 to pic.max_x do
         for loop2:=1 to pic.max_y do
             if not(pic.bits[loop2,loop1]=trans) then
                putpixel(loop1+x,loop2+y,pic.bits[loop2,loop1],where);
end;

procedure GetImage(var pic : image; x1,y1,x2,y2 : integer; where : word);
var loop1,loop2,temp : integer;
begin
     if (x1>x2) then
     begin
          temp:=x1;
          x1:=x2;
          x2:=temp;
     end;

     if (y1>y2) then
     begin
          temp:=y1;
          y1:=y2;
          y2:=temp;
     end;

     pic.max_x:=x2-x1;
     pic.max_y:=y2-y1;

     for loop1:=x1 to x2 do
         for loop2:=y1 to y2 do
             pic.bits[loop1,loop2]:=getpixel(loop1,loop2,where);
end;

procedure SaveScreen(filename:string);
{Saves the entire screen!}
var f:file;  dummy:word;
    p:pointer;
begin
     assign(f,filename);
     rewrite(f,1);
     p:=ptr($a000,0);           {P = pointer to beginning of video mem}
     blockwrite(f,p^,64000,dummy);
     close(f);
end;

procedure LoadScreen(filename:string; where: word);
{Loads an entire screen-saved image}
var f:file;   dummy:word;
    p:pointer;
begin
     assign(f,filename);
     {$I-}
        reset(f,1);
     {$I+}
     if IOResult<>0 then exit;

     p:=ptr(where,0);
     blockread(f,p^,64000,dummy);
     close(f);
end;

procedure Fill(x,y : integer; col : byte; boundcol : byte; where : word);
var loop1,max_x,min_x,max_y,min_y,temp_x,temp_y : integer;
begin
     temp_x:=x;
     temp_y:=y;

     while not(getpixel(temp_x,temp_y,where)=boundcol) do
           Inc(temp_x);

     max_x:=temp_x;

     temp_x:=x;

     while not(getpixel(temp_x,temp_y,where)=boundcol) do
           Dec(temp_x);

     min_x:=temp_x;

     temp_x:=x;

     while not(getpixel(temp_x,temp_y,where)=boundcol) do
           Inc(temp_y);

     max_y:=temp_y;

     temp_y:=y;

     while not(getpixel(temp_x,temp_y,where)=boundcol) do
           Dec(temp_y);

     min_y:=temp_y;

     for loop1:=min_y+1 to max_y-1 do
         Hline(min_x+1,max_x,loop1,col,where);
end;

procedure Setup;
begin
     SetGraphics;
     SetVirtual;
     cls(vga,0);
     cls(vaddr,0);
     cls(vaddr2,0);
     GrabPalette(pal1);
end;

procedure SetupSVGA;
begin
     asm
        mov ax,4f02h
        mov bx,101h
        int 10h
     end;
end;

procedure SetWriteBank(newbank : integer);
begin
     asm
        mov ax,4f05h
        xor bx,bx
        mov dx,newbank
        int 10h
     end;
end;

procedure putpixel_svga(x,y : integer; col : byte);
var coord : longint;
    off : integer;
begin
     coord:=x+y*1280;
     SetWriteBank(coord div 65536);
     off:=coord mod 65536;

     asm
        mov ax,vga
        mov es,ax
        mov di,off
        mov al,col
        stosb
     end;
end;

procedure Text(x,y : integer; str : string; col : byte; where : word);
var
   len,cloop,loop1,loop2,counter,tmpx,tmpy : integer;
   curr : char;
   bit : string;
begin
     len:=Length(str);
     tmpx:=x;
     tmpy:=y;

     for cloop:=1 to len do
     begin
          curr:=upcase(str[cloop]);
          counter:=1;

          case curr of
               'A' : bit:='1111110100101001010011111';
               'B' : bit:='1111110101101011010111111';
               'C' : bit:='1111110001100011000110001';
               'D' : bit:='1111110001100011000111111';
               'E' : bit:='1111110101101011010110001';
               'F' : bit:='1111110100101001010010000';
               'G' : bit:='1111110001101011010110111';
               'H' : bit:='1111100100001000010011111';
               'I' : bit:='1000110001111111000110001';
               'J' : bit:='1001110001111111000010000';
               'K' : bit:='1111100100001000101010001';
               'L' : bit:='1111100001000010000100001';
               'M' : bit:='1111110000011001000011111';
               'N' : bit:='1111110000010000010011111';
               'O' : bit:='1111110001100011000111111';
               'P' : bit:='1111110100101001010011100';
               'Q' : bit:='1111110001100111000111111';
               'R' : bit:='1111110100101001011011101';
               'S' : bit:='1110110101101011010110111';
               'T' : bit:='1000010000111111000010000';
               'U' : bit:='1111100001000010000111111';
               'V' : bit:='1110000010000010001011100';
               'W' : bit:='1111100001000110000111111';
               'X' : bit:='1000101010001000101010001';
               'Y' : bit:='1000001000001110100010000';
               'Z' : bit:='1001110101101011000111001';
               ' ' : bit:='0000000000000000000000000';
               '1' : bit:='1000110001111110000100001';
               '2' : bit:='1011110101101011010111101';
               '3' : bit:='1000110101101011010111111';
               '4' : bit:='0001000110010101001011111';
               '5' : bit:='1110110101101011010110010';
               '6' : bit:='1111110101101011010110111';
               '7' : bit:='1000010000100001000011111';
               '8' : bit:='1101110101101011010111011';
               '9' : bit:='1110110101101011010111111';
               '0' : bit:='1111110001101011000111111';
               '-' : bit:='0010000100001000010000100';
               '.' : bit:='0000000000000010000000000';
          end;

          for loop1:=1 to 5 do
          begin
               tmpy:=y;

               for loop2:=1 to 5 do
               begin
                    if (bit[counter]='1') then putpixel(tmpx,tmpy,col,where);
                    Inc(counter);
                    Inc(tmpy);
               end;
               Inc(tmpx);
          end;

          tmpx:=tmpx+2;
     end;
end;

procedure ShutDown;
begin
     RemoveVirtual;
     SetText;
end;

end.
