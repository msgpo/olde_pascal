unit palette;

interface

uses crt;

type pall=array[0..255,1..3] of byte;

var
   pal1 : pall;

procedure WaitRetrace;
procedure SetPal(a,b,c : integer);
procedure SetPal2(a,b,c : integer);
procedure SetPal3(a,b,c : integer);
procedure SetPal4(a,b,c : integer);
procedure RotatePal;
procedure GetPal(Colorno : byte; var R,G,B : byte);
procedure Pal(Colorno : byte; R,G,B : byte);
procedure GrabPalette(var vpal : pall);
procedure RestorePalette(vpal : pall);
procedure BlackOut;
procedure FadeUp(del : integer);
procedure FadeDown(del : integer);
procedure IncColor(one,two,three,del : integer);
procedure DecColor(one,two,three,del : integer);
procedure Flash(one,two,three : byte; max,del : integer);
procedure EatScreen(one,two,three : byte; max,del,del2 : integer);

implementation

procedure SetPal(a,b,c : integer);
var loop1 : integer;
    temp : array[1..3] of integer;
begin
     for loop1:=1 to 63 do
     begin
          if (a=1) then temp[1]:=loop1;
          if (b=1) then temp[2]:=loop1;
          if (c=1) then temp[3]:=loop1;
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal2(a,b,c : integer);
var loop1 : integer;
    temp : array[1..3] of integer;
begin
     for loop1:=64 to 128 do
     begin
          if (a=1) then temp[1]:=loop1;
          if (b=1) then temp[2]:=loop1;
          if (c=1) then temp[3]:=loop1;
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal3(a,b,c : integer);
var loop1 : integer;
    temp : array[1..3] of integer;
begin
     for loop1:=129 to 192 do
     begin
          if (a=1) then temp[1]:=loop1;
          if (b=1) then temp[2]:=loop1;
          if (c=1) then temp[3]:=loop1;
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure SetPal4(a,b,c : integer);
var loop1 : integer;
    temp : array[1..3] of integer;
begin
     for loop1:=193 to 255 do
     begin
          if (a=1) then temp[1]:=loop1;
          if (b=1) then temp[2]:=loop1;
          if (c=1) then temp[3]:=loop1;
          pal(loop1,temp[1],temp[2],temp[3]);
     end;
end;

procedure RotatePal;
var loop1 : byte;
    temp : array[1..3] of byte;
begin
     for loop1:=0 to 255 do
     begin
          getpal(loop1,temp[1],temp[2],temp[3]);
          pal(loop1+1,temp[1],temp[2],temp[3]);
     end;
end;

procedure WaitRetrace; assembler;
{Waits for the vertical retrace}
asm
   cli
   mov dx,3DAh
@l1:
   in al,dx
   and al,08h
   jnz @l1
@l2:
   in al,dx
   and al,08h
   jz  @l2
   sti
end;

procedure GetPal(Colorno : byte; var R,G,B : byte);
begin
     Port[$3c7]:=Colorno;
     R:=Port[$3c9];
     G:=Port[$3c9];
     B:=Port[$3c9];
end;

procedure Pal(Colorno:byte; R,G,B:byte);
begin
asm
  mov     dx,3c8h
  mov     al,[colorno]
  out     dx,al
  inc     dx
  mov     al,[r]
  out     dx,al
  mov     al,[g]
  out     dx,al
  mov     al,[b]
  out     dx,al
end;
end;

procedure GrabPalette(var vpal : pall);
var loop1 : integer;
begin
     for loop1:=0 to 255 do
         GetPal(loop1,vpal[loop1,1],vpal[loop1,2],vpal[loop1,3]);
end;

procedure RestorePalette(vpal : pall);
var loop1 : integer;
begin
     for loop1:=0 to 255 do
         Pal(loop1,vpal[loop1,1],vpal[loop1,2],vpal[loop1,3]);
end;

procedure BlackOut;
var
   loop1 : integer;
begin
     for loop1:=0 to 255 do
         Pal(loop1,0,0,0);
end;

procedure FadeUp(del : integer);
var temp : array[1..3] of byte;
    loop1,loop2 : integer;
begin
     BlackOut;
     for loop1:=1 to 64 do
     begin
          for loop2:=0 to 255 do
          begin
               GetPal(loop2,temp[1],temp[2],temp[3]);
               if temp[1] < pal1[loop2,1] then inc(temp[1]);
               if temp[2] < pal1[loop2,2] then inc(temp[2]);
               if temp[3] < pal1[loop2,3] then inc(temp[3]);
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

procedure IncColor(one,two,three,del : integer);
var loop1,loop2 : integer;
    temp : array[1..3] of byte;
begin
     for loop1:=1 to 64 do
     begin
          for loop2:=0 to 255 do
          begin
               GetPal(loop2,temp[1],temp[2],temp[3]);
               if one > 0 then
                  if temp[1] < 63 then inc(temp[1]);
               if two > 0 then
                  if temp[2] < 63 then inc(temp[2]);
               if three > 0 then
                  if temp[3] < 63 then inc(temp[3]);

               Pal(loop2,temp[1],temp[2],temp[3]);
          end;
          delay(del);
     end;
end;

procedure DecColor(one,two,three,del : integer);
var loop1,loop2 : integer;
    temp : array[1..3] of byte;
begin
     for loop1:=1 to 64 do
     begin
          for loop2:=0 to 255 do
          begin
               GetPal(loop2,temp[1],temp[2],temp[3]);
               if one > 0 then
                  if temp[1] > pal1[loop2,1] then dec(temp[1]);
               if two > 0 then
                  if temp[2] > pal1[loop2,2] then dec(temp[2]);
               if three > 0 then
                  if temp[3] > pal1[loop2,3] then dec(temp[3]);

               Pal(loop2,temp[1],temp[2],temp[3]);
          end;
          delay(del);
     end;
end;

procedure EatScreen(one,two,three : byte; max,del,del2 : integer);
var loop1 : integer;
    temp : array[1..3] of byte;
    tpal : pall;
begin
     GrabPalette(tpal);
     for loop1:=0 to 255 do
     begin
          GetPal(loop1,temp[1],temp[2],temp[3]);
          if one > 0 then
             if temp[1] < max then temp[1]:=max;
          if two > 0 then
             if temp[2] < max then temp[2]:=max;
          if three > 0 then
             if temp[3] < max then temp[3]:=max;
          Pal(loop1,temp[1],temp[2],temp[3]);
          delay(del2);
     end;
     delay(del);

     for loop1:=0 to 255 do
     begin
          Pal(loop1,tpal[loop1,1],tpal[loop1,2],tpal[loop1,3]);
          delay(del2);
     end;
end;

procedure Flash(one,two,three : byte; max,del : integer);
var loop1 : integer;
    temp : array[1..3] of byte;
    tpal : pall;
begin
     GrabPalette(tpal);
     for loop1:=0 to 255 do
     begin
          GetPal(loop1,temp[1],temp[2],temp[3]);
          if one > 0 then
             if temp[1] < max then temp[1]:=max;
          if two > 0 then
             if temp[2] < max then temp[2]:=max;
          if three > 0 then
             if temp[3] < max then temp[3]:=max;
          Pal(loop1,temp[1],temp[2],temp[3]);
     end;
     delay(del);

     for loop1:=0 to 255 do
          Pal(loop1,tpal[loop1,1],tpal[loop1,2],tpal[loop1,3]);
end;


end.
