unit Vgraph;

interface

uses crt;

const
     vga=$A000;

type vscreen=array[1..64000] of byte;
     vptr=^vscreen;

type palette=array[0..255,1..3] of byte;
type pal64col=array[0..63,1..3] of byte;
type pal16col=array[0..15,1..3] of byte;

type image=record
     size_x,size_y : byte;
     bits : array[1..20,1..20] of byte;
end;

var
   virscr,virscr2 : vptr;
   vaddr,vaddr2 : word;
   pal1 : palette;
   pal64_1 : pal64col;
   pal16_1 : pal16col;
   fp : text;

procedure SetMode(mode : word);
procedure Setup;
procedure ShutDown;
procedure Putpixel(x,y : integer; col : byte; where : word);
procedure Pixel_Clip(x,y : integer; col : byte; where : word);
function Getpixel(x,y : integer; where : word) : byte;
procedure Cls(where : word; col : byte);
procedure Flip(source,dest : word);
procedure Hline(x1,x2,y : integer; col : byte; where : word);
procedure Hline_Clip(x1,x2,y : integer; col : byte; where : word);
procedure Vline(y1,y2,x : integer; col : byte; where : word);
procedure Vline_Clip(y1,y2,x : integer; col : byte; where : word);
procedure Line(a,b,c,d : integer; col : byte; where : word);
procedure Circle(x,y,rad : integer; col : byte; where : word);
procedure Square(x,y,incx,incy : integer; col : byte; where : word);
procedure Square_Clip(x,y,incx,incy : integer; col : byte; where : word);
procedure Box(x,y,incx1,incx2,incy1,incy2 : integer; col : byte; where : word);
procedure Fill(x,y : integer; col : byte; boundcol : byte; where : word);
procedure Text(x,y : integer; str : string; col : byte; where : word);

procedure Pal(col : byte; r,g,b : byte);
procedure Getpal(col : byte; var r,g,b : byte);
procedure GrabPalette(var vpal : palette);
procedure Grab64Pal(min,max : byte; var vpal : pal64col);
procedure Grab16Pal(min,max : byte; var vpal : pal16col);
procedure RestorePalette(vpal : palette);
procedure Restore64pal(min,max : byte; vpal : pal64col);
procedure Restore16pal(min,max : byte; vpal : pal16col);
procedure CopyPalette(vpal : palette; var vpal2 : palette);
procedure SavePalette(vpal : palette; filename : string);
procedure LoadPalette(var vpal : palette; filename : string);
procedure Blackout;
procedure MaxOut(r,g,b : byte);
procedure FadeUp(del : integer; vpal : palette);
procedure FadeDown(del : integer);
procedure IncColor(r,g,b,del : byte);
procedure DecColor(r,g,b,del : byte; vpal : palette);
procedure SetPal64(r,g,b : byte);
procedure SetPal64_2(r,g,b : byte);
procedure SetPal64_3(r,g,b : byte);
procedure SetPal64_4(r,g,b : byte);
procedure SetPal32(r,g,b : byte);
procedure SetPal32_2(r,g,b : byte);
procedure SetPal32_3(r,g,b : byte);
procedure SetPal32_4(r,g,b : byte);
procedure SetPal32_5(r,g,b : byte);
procedure SetPal32_6(r,g,b : byte);
procedure SetPal32_7(r,g,b : byte);
procedure SetPal32_8(r,g,b : byte);

procedure ResetImage(var img : image; size_x,size_y,col : byte);
procedure PutImage(img : image; x,y : integer; trans : byte; where : word);
procedure GetImage(var img : image; x,y : integer; where : word);
procedure SaveImage(img : image; filename : string; inum : byte);
function LoadImage(var img : image; filename : string; inum : byte) : boolean;
procedure CopyImage(source : image; var dest : image);
procedure TransCopyImage(source : image; var dest : image; trans : byte);
procedure ReverseImage(var img : image);
procedure AddImage(var img : image; k : byte);

procedure ReadPCX(name : string; x,y : integer; where : word);

procedure Pause;
function KeyReady : boolean;
function GetKey : char;

implementation

procedure SetMode(mode : word);
begin
     asm
        mov ax,mode
        int 10h
     end;
end;

procedure Setup;
begin
     SetMode($13);
     GetMem(virscr,64000);
     GetMem(virscr2,64000);
     vaddr:=SEG(virscr^);
     vaddr2:=SEG(virscr2^);
     cls(vga,0);
     cls(vaddr,0);
     cls(vaddr2,0);
end;

procedure ShutDown;
begin
     FreeMem(virscr,64000);
     FreeMem(virscr2,64000);
     vaddr:=0;
     vaddr2:=0;
     SetMode($03);
end;

procedure Putpixel(x,y : integer; col : byte; where : word);
begin
     asm
        mov ax,where
        mov es,ax
        mov ax,y
        mov bx,y
        shl ax,8
        shl bx,6
        add ax,bx
        add ax,x
        mov di,ax
        mov al,col
        mov es:[di],al
     end;
end;

procedure Pixel_Clip(x,y : integer; col : byte; where : word);
begin
     if ((((x>=0) and (x<=319) and (y>=0) and (y<=199)))) then
        asm
        mov ax,where
        mov es,ax
        mov ax,y
        mov bx,y
        shl ax,8
        shl bx,6
        add ax,bx
        add ax,x
        mov di,ax
        mov al,col
        mov es:[di],al
     end;
end;

function Getpixel(x,y : integer; where : word) : byte;
var temp : byte;
begin
     asm
        mov ax,where
        mov es,ax
        mov ax,y
        mov bx,y
        shl ax,8
        shl bx,6
        add ax,bx
        add ax,x
        mov di,ax
        xor ah,ah
        mov al,es:[di]
        mov temp,al
     end;
     getpixel:=temp;
end;

procedure Cls(where : word; col : byte);
begin
     asm
        mov ax,where
        mov es,ax
        xor di,di
        mov cx,32000
        mov al,col
        mov ah,col
        rep stosw
     end;
end;

procedure Flip(source,dest : word);
begin
     asm
        push ds
        mov ax,dest
        mov es,ax
        mov ax,source
        mov ds,ax
        xor di,di
        xor si,si
        mov cx,32000
        rep movsw
        pop ds
     end;
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
        inc cx
        mov al,col
        rep stosb
     end;
end;

procedure Hline_Clip(x1,x2,y : integer; col : byte; where : word);
var temp : integer;
    loop1 : integer;
begin
     if ((y<0) or (y>199)) then exit;

     if (x1>x2) then
     begin
          temp:=x1;
          x1:=x2;
          x2:=temp;
     end;

     for loop1:=x1 to x2 do
         if ((loop1>=1) and (loop1<=319)) then
            putpixel(loop1,y,col,where);
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
        inc cx
        mov al,col
        @loop1:
               mov es:[di],al
               add di,320
        loop @loop1
     end;
end;

procedure Vline_Clip(y1,y2,x : integer; col : byte; where : word);
var temp : integer;
    loop1 : integer;
begin
     if ((x<0) or (x>319)) then exit;

     if (y1>y2) then
     begin
          temp:=y1;
          y1:=y2;
          y2:=temp;
     end;

     for loop1:=y1 to y2 do
         if ((loop1>=0) and (loop1<=199)) then
            putpixel(x,loop1,col,where);
end;

procedure Line(a,b,c,d : integer; col : byte; where : word);
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

procedure Square(x,y,incx,incy : integer; col : byte; where : word);
begin
     hline(x,x+incx,y,col,where);
     hline(x,x+incx,y+incy,col,where);
     vline(y,y+incy,x,col,where);
     vline(y,y+incy,x+incx,col,where);
end;

procedure Square_Clip(x,y,incx,incy : integer; col : byte; where : word);
begin
     hline_clip(x,x+incx,y,col,where);
     hline_clip(x,x+incx,y+incy,col,where);
     vline_clip(y,y+incy,x,col,where);
     vline_clip(y,y+incy,x+incx,col,where);
end;

procedure Box(x,y,incx1,incx2,incy1,incy2 : integer; col : byte; where : word);
begin
     hline(x-incx1,x+incx2,y-incy1,col,where);
     hline(x-incx1,x+incx2,y+incy2,col,where);
     vline(y-incy1,y+incy2,x-incx1,col,where);
     vline(y-incy1,y+incy2,x+incx2,col,where);
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
         Hline(min_x+1,max_x-1,loop1,col,where);
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
               'D' : bit:='1111110001100011000101110';
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
               'O' : bit:='0111010001100011000101110';
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
                #8 : bit:='1111111111111111111111111';
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
               '+' : bit:='0000000100011100010000000';
               '-' : bit:='0010000100001000010000100';
               '.' : bit:='0000000000000010000000000';
               'ù' : bit:='0000000000001000000000000';
               '!' : bit:='0000001000111010100000000';
               ',' : bit:='0000000000000000000100011';
               '?' : bit:='1100010000101111010011100';
               '*' : bit:='0010010101011101010100100';
               ':' : bit:='0000000000001010000000000';
               '\' : bit:='1000001000001000001000001';
               '/' : bit:='0000100010001000100010000';
               '(' : bit:='0000000000011101000100000';
               ')' : bit:='0000010001011100000000000';
               '_' : bit:='0000100001000010000100001';
               '>' : bit:='0000010001010100010000000';
               '<' : bit:='0000000100010101000100000';
               '' : bit:='0000011111011100010000000';
               'þ' : bit:='1111111111111111111111111';
               'ý' : bit:='1111110001100011000111111';
               #39 : bit:='0000000000010001100000000';
          end;

          for loop1:=1 to 5 do
          begin
               tmpy:=y;

               for loop2:=1 to 5 do
               begin
                    if (bit[counter]='1') then pixel_clip(tmpx,tmpy,col,where);
                    Inc(counter);
                    Inc(tmpy);
               end;
               Inc(tmpx);
          end;

          tmpx:=tmpx+2;
     end;
end;

procedure Pal(col : byte; r,g,b : byte);
begin
     asm
        mov dx,3c8h
        mov al,col
        out dx,al
        inc dx
        mov al,r
        out dx,al
        mov al,g
        out dx,al
        mov al,b
        out dx,al
     end;
end;

procedure Getpal(col : byte; var r,g,b : byte);
var rr,gg,bb : byte;
begin
     asm
        mov dx,3c7h
        mov al,col
        out dx,al
        add dx,2
        in al,dx
        mov rr,al
        in al,dx
        mov gg,al
        in al,dx
        mov bb,al
     end;
     r:=rr;
     g:=gg;
     b:=bb;
end;

procedure GrabPalette(var vpal : palette);
var loop1 : byte;
begin
     for loop1:=0 to 255 do
         getpal(loop1,vpal[loop1,1],vpal[loop1,2],vpal[loop1,3]);
end;

procedure Grab64Pal(min,max : byte; var vpal : pal64col);
var loop1,counter : byte;
begin
     counter:=0;

     for loop1:=min to max do
     begin
          getpal(loop1,vpal[counter,1],vpal[counter,2],vpal[counter,3]);
          Inc(counter);
     end;
end;

procedure Grab16Pal(min,max : byte; var vpal : pal16col);
var loop1,counter : byte;
begin
     counter:=0;

     for loop1:=min to max do
     begin
          getpal(loop1,vpal[counter,1],vpal[counter,2],vpal[counter,3]);
          Inc(counter);
     end;
end;

procedure RestorePalette(vpal : palette);
var loop1 : byte;
begin
     for loop1:=0 to 255 do
         pal(loop1,vpal[loop1,1],vpal[loop1,2],vpal[loop1,3]);
end;

procedure Restore64pal(min,max : byte; vpal : pal64col);
var loop1,counter : byte;
begin
     counter:=0;

     for loop1:=min to max do
     begin
          pal(loop1,vpal[counter,1],vpal[counter,2],vpal[counter,3]);
          Inc(counter);
     end;
end;


procedure Restore16pal(min,max : byte; vpal : pal16col);
var loop1,counter : byte;
begin
     counter:=0;

     for loop1:=min to max do
     begin
          pal(loop1,vpal[counter,1],vpal[counter,2],vpal[counter,3]);
          Inc(counter);
     end;
end;

procedure CopyPalette(vpal : palette; var vpal2 : palette);
var loop1 : byte;
begin
     for loop1:=0 to 255 do
     begin
          vpal2[loop1,1]:=vpal[loop1,1];
          vpal2[loop1,2]:=vpal[loop1,2];
          vpal2[loop1,3]:=vpal[loop1,3];
     end;
end;

procedure SavePalette(vpal : palette; filename : string);
var loop1 : byte;
    fp : file of byte;
begin
     assign(fp,filename);
     rewrite(fp);

     for loop1:=0 to 255 do
     begin
          write(fp,vpal[loop1,1]);
          write(fp,vpal[loop1,2]);
          write(fp,vpal[loop1,3]);
     end;

     close(fp);
end;

procedure LoadPalette(var vpal : palette; filename : string);
var loop1,temp : byte;
    fp : file of byte;
begin
     assign(fp,filename);
     reset(fp);

     for loop1:=0 to 255 do
     begin
          read(fp,temp);
          vpal[loop1,1]:=temp;
          read(fp,temp);
          vpal[loop1,2]:=temp;
          read(fp,temp);
          vpal[loop1,3]:=temp;
     end;

     close(fp);
end;

procedure Blackout;
var loop1 : byte;
begin
     for loop1:=0 to 255 do
         pal(loop1,0,0,0);
end;

procedure MaxOut(r,g,b : byte);
var loop1 : byte;
    temp : array[1..3] of byte;
begin
     if (r=1) then temp[1]:=63;
     if (g=1) then temp[2]:=63;
     if (b=1) then temp[3]:=63;

     for loop1:=0 to 255 do
         pal(loop1,temp[1],temp[2],temp[3]);
end;

procedure FadeUp(del : integer; vpal : palette);
var temp : array[1..3] of byte;
    loop1,loop2 : integer;
begin
     BlackOut;
     for loop1:=1 to 64 do
     begin
          for loop2:=0 to 255 do
          begin
               GetPal(loop2,temp[1],temp[2],temp[3]);
               if temp[1] < vpal[loop2,1] then inc(temp[1]);
               if temp[2] < vpal[loop2,2] then inc(temp[2]);
               if temp[3] < vpal[loop2,3] then inc(temp[3]);
               Pal(loop2,temp[1],temp[2],temp[3]);
          end;
          delay(del);
     end;
end;

procedure FadeDown(del : integer);
var loop1,loop2 : integer;
    temp : array[1..3] of byte;
begin
     for loop1:=1 to 64 do
     begin
          for loop2:=0 to 255 do
          begin
               GetPal(loop2,temp[1],temp[2],temp[3]);
               if temp[1] > 0 then dec(temp[1]);
               if temp[2] > 0 then dec(temp[2]);
               if temp[3] > 0 then dec(temp[3]);
               Pal(loop2,temp[1],temp[2],temp[3]);
          end;
          delay(del);
     end;
end;

procedure IncColor(r,g,b,del : byte);
var loop1,loop2 : byte;
    temp : array[1..3] of byte;
begin
     for loop1:=0 to 63 do
     begin
          for loop2:=0 to 255 do
          begin
               getpal(loop2,temp[1],temp[2],temp[3]);

               if (r=1) then
                  if (temp[1]<63) then Inc(temp[1]);

               if (g=1) then
                  if (temp[2]<63) then Inc(temp[2]);

               if (b=1) then
                  if (temp[3]<63) then Inc(temp[3]);

               pal(loop2,temp[1],temp[2],temp[3]);
          end;
          delay(del);
     end;
end;

procedure DecColor(r,g,b,del : byte; vpal : palette);
var loop1,loop2 : byte;
    temp : array[1..3] of byte;
begin
     for loop1:=0 to 63 do
     begin
          for loop2:=0 to 255 do
          begin
               getpal(loop2,temp[1],temp[2],temp[3]);

               if (r=1) then
                  if (temp[1]>vpal[loop2,1]) then Dec(temp[1]);

               if (g=1) then
                  if (temp[2]>vpal[loop2,2]) then Dec(temp[2]);

               if (b=1) then
                  if (temp[3]>vpal[loop2,3]) then Dec(temp[3]);

               pal(loop2,temp[1],temp[2],temp[3]);
          end;
          delay(del);
     end;
end;

procedure SetPal64(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=0;

     for loop1:=0 to 63 do
     begin
          if (r=1) then temp[1]:=loop1;
          if (g=1) then temp[2]:=loop1;
          if (b=1) then temp[3]:=loop1;
          Inc(counter);
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal64_2(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=0;

     for loop1:=64 to 127 do
     begin
          if (r=1) then temp[1]:=counter;
          if (g=1) then temp[2]:=counter;
          if (b=1) then temp[3]:=counter;
          Inc(counter);
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal64_3(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=0;

     for loop1:=128 to 191 do
     begin
          if (r=1) then temp[1]:=counter;
          if (g=1) then temp[2]:=counter;
          if (b=1) then temp[3]:=counter;
          Inc(counter);
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal64_4(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=0;

     for loop1:=192 to 255 do
     begin
          if (r=1) then temp[1]:=counter;
          if (g=1) then temp[2]:=counter;
          if (b=1) then temp[3]:=counter;
          Inc(counter);
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=0;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32_2(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=32;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32_3(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=64;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32_4(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=96;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32_5(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=128;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32_6(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=160;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32_7(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=192;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal32_8(r,g,b : byte);
var loop1,counter : byte;
    temp : array[1..3] of byte;
begin
     counter:=223;

     for loop1:=0 to 63 do
     begin
          if ((loop1 mod 2)=0) then
          begin
               if (r=1) then temp[1]:=loop1;
               if (g=1) then temp[2]:=loop1;
               if (b=1) then temp[3]:=loop1;
               Inc(counter);
          end;

          pal(counter,temp[1],temp[2],temp[3]);
     end;
end;

procedure ResetImage(var img : image; size_x,size_y,col : byte);
var loop1,loop2 : byte;
begin
     img.size_x:=size_x;
     img.size_y:=size_y;

     for loop1:=1 to img.size_x do
         for loop2:=1 to img.size_y do
             img.bits[loop1,loop2]:=col;
end;

procedure PutImage(img : image; x,y : integer; trans : byte; where : word);
var loop1,loop2 : byte;
begin
     Dec(x);
     Dec(y);

     for loop1:=1 to img.size_x do
         for loop2:=1 to img.size_y do
             if (img.bits[loop1,loop2]<>trans) then
                pixel_clip(x+loop1,y+loop2,img.bits[loop1,loop2],where);
end;

procedure GetImage(var img : image; x,y : integer; where : word);
var loop1,loop2 : byte;
begin
     Dec(x);
     Dec(y);

     for loop1:=1 to img.size_x do
         for loop2:=1 to img.size_y do
             img.bits[loop1,loop2]:=getpixel(x+loop1,y+loop2,where);
end;

procedure SaveImage(img : image; filename : string; inum : byte);
var loop1,loop2 : byte;
    temp : byte;
    fp : file of byte;
begin
     assign(fp,filename);

     {$I-}
     reset(fp);
     {$I+}

     if (IOResult=0) then reset(fp)
     else rewrite(fp);

     temp:=img.size_x;
     write(fp,temp);
     temp:=img.size_y;
     write(fp,temp);

     seek(fp,0);
     seek(fp,2+((img.size_x*img.size_y)*(inum-1)));

     for loop1:=1 to img.size_x do
         for loop2:=1 to img.size_y do
             write(fp,img.bits[loop1,loop2]);

     close(fp);
end;

function LoadImage(var img : image; filename : string; inum : byte) : boolean;
var loop1,loop2 : byte;
    temp : byte;
    fp : file of byte;
begin
     assign(fp,filename);

     {$I-}
     reset(fp);
     {$I+}

     if not(IOResult=0) then
     begin
          LoadImage:=false;
          exit;
     end;

     read(fp,temp);
     img.size_x:=temp;
     read(fp,temp);
     img.size_y:=temp;

     if (inum>((FileSize(fp)-2) div (img.size_x*img.size_y))) then
     begin
          LoadImage:=false;
          exit;
     end;

     seek(fp,0);
     seek(fp,2+((img.size_x*img.size_y)*(inum-1)));

     for loop1:=1 to img.size_x do
         for loop2:=1 to img.size_y do
         begin
              read(fp,temp);
              img.bits[loop1,loop2]:=temp;
         end;

     close(fp);

     LoadImage:=true;
end;

procedure CopyImage(source : image; var dest : image);
var loop1,loop2 : byte;
begin
     for loop1:=1 to source.size_x do
         for loop2:=1 to source.size_y do
             dest.bits[loop1,loop2]:=source.bits[loop1,loop2];
end;

procedure TransCopyImage(source : image; var dest : image; trans : byte);
var loop1,loop2 : byte;
begin
     for loop1:=1 to source.size_x do
         for loop2:=1 to source.size_y do
             if (source.bits[loop1,loop2]<>trans) then
                dest.bits[loop1,loop2]:=source.bits[loop1,loop2];
end;

procedure ReverseImage(var img : image);
var loop1,loop2 : byte;
    temp : image;
begin
     CopyImage(img,temp);

     for loop1:=1 to img.size_x do
         for loop2:=1 to img.size_y do
             img.bits[loop2,loop1]:=temp.bits[loop1,loop2];
end;

procedure AddImage(var img : image; k : byte);
var loop1,loop2 : byte;
begin
     for loop1:=1 to img.size_x do
         for loop2:=1 to img.size_y do
             img.bits[loop1,loop2]:=img.bits[loop1,loop2]+k;
end;

procedure ReadPCX(name : string; x,y : integer; where : word);

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

procedure Pause;
begin
     Readkey;
end;

function KeyReady : boolean;
var temp : byte;
begin
     temp:=0;

     asm
        mov ah,1
        int 16h

        jz @Exit
        mov temp,1

        @Exit:
     end;
     if (temp=1) then
        KeyReady:=true
     else KeyReady:=false;
end;

function GetKey : char;
var temp : char;
begin
     asm
        xor ax,ax
        int 16h
        mov temp,al
     end;
     GetKey:=temp;
end;

end.