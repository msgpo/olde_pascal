unit graphbj;

interface

uses crt,graph;

var
   GraphDriver,GraphMode : integer;
   orgsettings : textsettingstype;

procedure SetGraphics;
procedure Pause;
procedure ResetText;
procedure TitleScreen;
procedure Box(x,y,incx,incy,color : integer);
procedure Box2(x,y,incx,incx2,incy,incy2,color : integer);
procedure DrawCard(x,y : integer; num : char);
procedure FlipCard(x,y,way : integer; num : char);
procedure DrawMoney;
procedure DrawTable;

implementation

procedure SetGraphics;
begin
     GraphDriver:=Detect;
     InitGraph(GraphDriver,GraphMode,'D:\BP\BGI');
end;

procedure Pause;
var c:char;
begin
     c:=Readkey;
end;

procedure ResetText;
begin
     with orgsettings do
     begin
          settextjustify(Horiz,Vert);
          settextstyle(Font,Direction,CharSize);
     end;
end;

procedure TitleScreen;
var a,x,y,color,pcolor,temp : integer;
begin
     DrawTable;
     Box(320,140,300,75,15);
     Box2(320,400,190,180,10,20,15);
     setfillstyle(1,0);
     floodfill(320,140,15);
     floodfill(320,400,15);
     setcolor(3);
     settextstyle(4,0,8);
     settextjustify(CenterText,CenterText);
     outtextxy(320,140,'BLACK JACK');
     settextstyle(2,0,8);
     setcolor(12);
     outtextxy(320,400,'Coded by Michael Hansen');
     settextstyle(4,0,8);

     color:=1;
     pcolor:=0;
     x:=320;
     y:=390;
     temp:=100;
     putpixel(x,y,8);
     repeat
           if color=16 then
              color:=1;

           setcolor(color);
           outtextxy(320,140,'BLACK JACK');
           Box(320,140,300,75,random(15));
           color:=color+1;
           sound(temp);
           temp:=temp+100;
           if temp > 1000 then temp:=100;

           for a:=0 to 75 do
           begin
                if (x=320) and (y=390) then
                   pcolor:=random(15);

                putpixel(x,y,pcolor);

                if x=500 then
                   if y=420 then
                      x:=x-1
                   else
                       y:=y+1
                else if x=130 then
                     if y=390 then
                        x:=x+1
                     else
                         y:=y-1
                else if y=390 then
                     x:=x+1
                else if y=420 then
                     x:=x-1;

                putpixel(x,y,14);
                delay(2);
           end;

     until keypressed;

     nosound;
     settextjustify(LeftText,LeftText);
end;

procedure Box(x,y,incx,incy,color : integer);
begin
     setcolor(color);
     line(x-incx,y-incy,x+incx,y-incy);
     line(x-incx,y+incy,x+incx,y+incy);
     line(x-incx,y-incy,x-incx,y+incy);
     line(x+incx,y-incy,x+incx,y+incy);
end;

procedure Box2(x,y,incx,incx2,incy,incy2,color : integer);
begin
     setcolor(color);
     line(x-incx,y-incy,x+incx2,y-incy);
     line(x-incx,y+incy2,x+incx2,y+incy2);
     line(x-incx,y-incy,x-incx,y+incy2);
     line(x+incx2,y-incy,x+incx2,y+incy2);
end;


procedure DrawCard(x,y : integer; num : char);
var str : string;
begin

     Box(x,y,30,45,15);
     num:=upcase(num);
     ResetText;

     case num of
          'B' : str:='Back';
          'N' : str:='Back';
          'S' : str:='Side';
          'E' : str:='Erase';
          'C' : str:='EraseCard';
          '1' : str:='Ace';
          '2' : str:='Deuce';
          '3' : str:='Three';
          '4' : str:='Four';
          '5' : str:='Five';
          '6' : str:='Six';
          '7' : str:='Seven';
          '8' : str:='Eight';
          '9' : str:='Nine';
          '0' : str:='Ten';
          'J' : str:='Jack';
          'Q' : str:='Queen';
          'K' : str:='King';
     end;

     if str='Back' then
     begin
          setfillstyle(8,3);
          floodfill(x,y,15);
     end
     else if str='Side' then
     begin
          setfillstyle(1,0);
          floodfill(x,y,15);
          Box(x,y,30,45,0);
          Box(x,y,5,45,15);
          setfillstyle(8,3);
          floodfill(x,y,15);
     end
     else if str='Erase' then
     begin
          setfillstyle(1,0);
          floodfill(x,y,15);
          Box(x,y,5,45,0);
     end
     else if str='EraseCard' then
     begin
          Box(x,y,30,45,1);
          setfillstyle(1,0);
          floodfill(x,y,1);
          Box(x,y,30,45,0);
     end
     else
     begin
          setfillstyle(1,15);
          floodfill(x,y,15);
          setcolor(0);
          outtextxy(x-20,y-5,str);
          if num='0' then
          begin
             outtextxy(x-25,y-40,'10');
             outtextxy(x+10,y+35,'10');
          end
          else
          begin
               outtextxy(x-25,y-40,num);
               outtextxy(x+20,y+35,num);
          end;
     end;
end;

procedure FlipCard(x,y,way : integer; num : char);
begin
     case way of
          1:
          begin
               DrawCard(x,y,'b');
               sound(500);
               delay(50);
               DrawCard(x,y,'s');
               sound(600);
               delay(50);
               sound(700);
               DrawCard(x,y,'e');
               DrawCard(x,y,num);
               delay(50);
               nosound;
          end;

          2:
          begin
               DrawCard(x,y,'c');
               DrawCard(x,y,'s');
               sound(700);
               delay(50);
               DrawCard(x,y,'e');
               DrawCard(x,y,'b');
               delay(50);
               sound(600);
               delay(50);
               sound(500);
               delay(50);
               nosound;
          end;
     end;
end;

procedure DrawMoney;
var str : string;
begin
     Box(320,400,150,50,15);
     setfillstyle(5,2);
     floodfill(320,400,15);
     setcolor(14);
     circle(320,400,40);
     setfillstyle(1,15);
     floodfill(320,400,14);
     settextstyle(5,0,8);
     setcolor(2);
     outtextxy(320,380,'$');
end;

procedure DrawTable;
begin
     Box(320,240,320,240,15);
     setfillstyle(4,2);
     floodfill(10,10,15);
     Box(320,240,320,240,0);
end;

end.

