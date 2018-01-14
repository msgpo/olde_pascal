 program Pong;

uses
crt,graph;

var
GraphDriver,GraphMode : integer;
x,y,x1,x2,y1,y2,cx1,cx2,cy1,cy2,dir,done,wall,counter,score,speed,hits,wallcolor : integer;
pos,start,computer,tplayer,updated : boolean;

procedure SetGraphics;
begin
GraphDriver := Detect;
InitGraph(GraphDriver, GraphMode, 'D:\BP\BGI');
end;

procedure Pause;
var
c : char;
begin
c:=readkey;
end;

procedure Miss;

var
a,color : integer;

begin
for a:=1 to 15 do
begin
setcolor(a);
outtextxy(320,0,'MISS!');
sound(a*50);
delay(25);
nosound;
end;
setcolor(0);
outtextxy(320,0,'MISS!');
putpixel(x,y,0);
x:=320;
y:=240;
putpixel(x,y,14);
if(counter=9) then counter:=5;
dir:=counter;
counter:=counter+1;
pos:=true;
score:=score+1;
end;

procedure CheckPos;

var
color : integer;

begin
if(dir=1) then
begin
color:=getpixel(x,y-1);
end;

if(dir=2) then
begin
color:=getpixel(x,y+1);
end;

if(dir=3) then
begin
color:=getpixel(x-1,y);
end;

if(dir=4) then
begin
color:=getpixel(x+1,y);
end;

if(dir=5) then
begin
color:=getpixel(x-1,y-1);
end;

if(dir=6) then
begin
color:=getpixel(x+1,y-1);
end;

if(dir=7) then
begin
color:=getpixel(x-1,y+1);
end;

if(dir=8) then
begin
color:=getpixel(x+1,y+1);
end;

case(color) of
1:
begin
if(hits=20) then
begin
speed:=speed-1;
wallcolor:=5;
end;
pos:=false;
end;
4:
begin
hits:=hits+1;
pos:=false;
end;
5:
pos:=false;
2:
Miss;
end;
end;

procedure ActDir;
begin
case(dir) of

1:
begin
dir:=2;
pos:=true;
end;

2:
begin
dir:=1;
pos:=true;
end;

3:
begin
dir:=4;
pos:=true;
end;

4:
begin
dir:=3;
pos:=true;
end;

5:
begin
if(wall=1) then
dir:=7;
if(wall=2) then
dir:=6;
pos:=true;
end;

6:
begin
if(wall=1) then
dir:=8;
if(wall=2) then
dir:=5;
pos:=true;
end;

7:
begin
if(wall=1) then
dir:=5;
if(wall=2) then
dir:=8;
pos:=true;
end;

8:
begin
if(wall=1) then
dir:=6;
if(wall=2) then
dir:=7;
pos:=true;
end;

end;
end;

procedure TestWall;

var
color,color2 : integer;

begin
color:=getpixel(x,y-1);
color2:=getpixel(x-1,y-1);
if((color=color2) and (color<>0) and (color2<>0)) then
begin
wall:=1;
end;

color:=getpixel(x,y+1);
color2:=getpixel(x+1,y+1);
if((color=color2) and (color<>0) and (color2<>0)) then
begin
wall:=1;
end;

color:=getpixel(x-1,y);
color2:=getpixel(x-1,y-1);
if((color=color2) and (color<>0) and (color2<>0)) then
begin
wall:=2;
end;

color:=getpixel(x+1,y);
color2:=getpixel(x+1,y+1);
if((color=color2) and (color<>0) and (color2<>0)) then
begin
wall:=2;
end;

end;


procedure UpdatePixel;
begin
CheckPos;
if(pos=false) then
begin
TestWall;
ActDir;
sound(100);
delay(50);
nosound;
end;
if(pos=true) then
begin
putpixel(x,y,0);

case(dir) of

1 :
y:=y-1;

2 :
y:=y+1;

3 :
x:=x-1;

4 :
x:=x+1;

5 :
begin
x:=x-1;
y:=y-1;
end;

6 :
begin
x:=x+1;
y:=y-1;
end;

7 :
begin
x:=x-1;
y:=y+1;
end;

8 :
begin
x:=x+1;
y:=y+1;
end;

end;
putpixel(x,y,15);
end;
end;

procedure DrawPaddle1(color : integer);
begin
setcolor(color);
line(x1,y1,x2,y2);
end;

procedure DrawPaddle2(color : integer);
begin
setcolor(color);
line(cx1,cy1,cx2,cy2);
end;

procedure MovePaddle1(a,b : integer);
begin
DrawPaddle1(0);
x1:=x1+a;
x2:=x2+a;
y1:=y1+b;
y2:=y2+b;
DrawPaddle1(4);
end;

procedure MovePaddle2(a,b : integer);
begin
DrawPaddle2(0);
cx1:=cx1+a;
cx2:=cx2+a;
cy1:=cy1+b;
cy2:=cy2+b;
DrawPaddle2(4);
end;


procedure CheckKey;
var
c : char;
begin
c:=ReadKey;
case(c) of

#72 :
MovePaddle1(0,-60);

#80 :
MovePaddle1(0,60);

'e' :
if(tplayer=true) then
MovePaddle2(0,-60);

'd' :
if(tplayer=true) then
MovePaddle2(0,60);

'l' :
if(start=false) then
begin
dir:=6;
start:=true;
end;

's' :
if(speed=0) then
begin
speed:=3;
end
else
begin
speed:=speed-1;
end;

'c' :
if(computer=true) then
begin
computer:=false;
end
else
begin
computer:=true;
end;

't' :
if(tplayer=false) then
begin
tplayer:=true;
end
else
begin
tplayer:=false;
end;

'p' :
Pause;

'q' :
begin
closegraph;
writeln('Computer Score : ', score);
writeln;
writeln;
writeln('Press a key to quit');
Pause;
done:=1;
end;
end;
end;

procedure PaddleAi;
begin
DrawPaddle2(0);
cy1:=y-25;
cy2:=y+25;
DrawPaddle2(4);
end;

procedure PaddleAi2;
begin
DrawPaddle1(0);
y1:=y-25;
y2:=y+25;
DrawPaddle1(4);
end;

procedure UpdateScreen;
begin
setcolor(wallcolor);
line(10,10,630,10);
line(10,470,630,470);
end;

procedure MainLoop;
begin
while done=0 do
begin
if keypressed then
begin
CheckKey;
end;
UpdatePixel;
if((wallcolor<>1) and (updated=false)) then
begin
UpdateScreen;
updated:=true;
end;
if(tplayer=false) then
begin
if(computer=true) then
begin
PaddleAi2;
end;
PaddleAi;
end;
delay(speed);
end;
end;

begin
SetGraphics;
wallcolor:=1;
setcolor(wallcolor);
line(10,10,630,10);
line(10,470,630,470);
setcolor(2);
line(10,10,10,470);
line(630,10,630,470);
dir:=1;
done:=0;
wall:=0;
score:=0;
hits:=0;
speed:=3;
counter:=5;
pos:=true;
start:=false;
computer:=false;
tplayer:=false;
updated:=false;
x:=320;
y:=240;
x1:=60;
x2:=60;
y1:=215;
y2:=265;
cx1:=580;
cx2:=580;
cy1:=215;
cy2:=265;
DrawPaddle1(4);
DrawPaddle2(4);
MainLoop;
end.


