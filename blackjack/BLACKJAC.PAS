program BlackJack;

uses crt,graph;

type _player=object
score,downval,bet,cash,cardcount : integer;
name : string;
done,busted,blackjack,downlooked : boolean;
cards : array[1..5] of char;
downcard : char;
end;

function GetCard(dcard : integer) : char; forward;
procedure Box(x,y,incx,incy,color : integer); forward;
procedure Box2(x,y,incx,incx2,incy,incy2,color : integer); forward;
procedure DrawTable; forward;
procedure SetPlayers(cash : boolean); forward;
procedure Deal(dcard : integer); forward;
procedure GetHit; forward;
procedure GetKey; forward;
procedure EndGame; forward;
procedure DealerAi; forward;
procedure CheckValue; forward;
procedure SetScreen(del : integer); forward;
procedure SetCards; forward;
procedure ChangeScore(add : integer); forward;

var
   GraphDriver,GraphMode : integer;
   cards : array[1..13] of integer;
   player : array[1..10] of _player;
   currplayer,numplayers : integer;
   orgsettings : TextSettingsType;
   currcard,dealercard : char;
   hit,done : boolean;


procedure SetGraphics;
begin
     GraphDriver:=Detect;
     InitGraph(GraphDriver,GraphMode,'D:\BP\BGI\');
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

procedure Message(message : char);
var str : string;
begin
     case upcase(message) of

          'D' :
          begin
               str:=player[currplayer].name+' is dealt ';
               case currcard of
                    '0' : str:=str+'a ten';
                    'A' : str:=str+'an ace';
                    '2' : str:=str+'a deuce';
                    '3' : str:=str+'a three';
                    '4' : str:=str+'a four';
                    '5' : str:=str+'a five';
                    '6' : str:=str+'a six';
                    '7' : str:=str+'a seven';
                    '8' : str:=str+'an eight';
                    '9' : str:=str+'a nine';
                    'J' : str:=str+'a jack';
                    'Q' : str:=str+'a queen';
                    'K' : str:=str+'a king';
               end;
          end;

          'B' : str:=player[currplayer].name + ' is busted';

          'S' : str:=player[currplayer].name + ' stands';

          'H' : str:='Dealer card is a(n) ' + dealercard;

          'A' : str:='Ace counts as [1] one or [2] eleven';

          'C' :
          begin
               if player[currplayer].downcard='0' then
                  str:=player[currplayer].name + 's downcard is a(n) 10'
               else
                   str:=player[currplayer].name + 's downcard is a(n) ' + player[currplayer].downcard;
          end;
     end;

     setfillstyle(1,0);
     floodfill(320,20,15);
     settextstyle(3,0,3);
     settextjustify(CenterText,CenterText);
     setcolor(6);
     outtextxy(320,20,str);
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
          outtextxy(x-20,y,str);
          if num='0' then
          begin
             outtextxy(x-25,y-35,'10');
             outtextxy(x+10,y+40,'10');
          end
          else
          begin
               outtextxy(x-25,y-35,num);
               outtextxy(x+20,y+40,num);
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

procedure LookCard(x,y : integer; num : char);
var c : char;
begin
     FlipCard(x,y,1,num);
     if currplayer=1 then
        delay(1000)
     else
         Pause;
     FlipCard(x,y,2,num);
end;

function CheckCard(num : integer) : integer;
begin
     if cards[num] < 4 then
     begin
          cards[num]:=cards[num]+1;
          CheckCard:=1;
     end
     else
         CheckCard:=-1;
end;

function GetCard(dcard : integer) : char;
var temp,card : integer;
temp2 : char;
begin
     card:=-1;
     while card < 0 do
     begin
          temp:=random(13);

          case temp of
               0 :
               begin
                    temp:=10;
                    temp2:='0';
               end;

               1 : temp2:='a';
               2 : temp2:='2';
               3 : temp2:='3';
               4 : temp2:='4';
               5 : temp2:='5';
               6 : temp2:='6';
               7 : temp2:='7';
               8 : temp2:='8';
               9 : temp2:='9';
               10 : temp2:='0';
               11 : temp2:='j';
               12 : temp2:='q';
               13 : temp2:='k';
          end;
          card:=CheckCard(temp);
     end;
     if temp > 10 then temp:=10;

     if temp2='a' then
     begin
          Message('a');
          currcard:=upcase(temp2)
     end

     else if (dcard > 0) and (temp2 <> 'a') then
     begin
          ChangeScore(temp);
          currcard:=upcase(temp2);
     end
     else
     begin
          player[currplayer].downcard:=upcase(temp2);
          player[currplayer].downval:=temp;
          currcard:=upcase(temp2);
     end;
     GetCard:=upcase(temp2);
end;

procedure GetKey;
var c,temp : char;
temp2 : integer;
num : string;
begin
     c:=Readkey;
     case c of
          'm' :
          begin
               c:=Readkey;
               case c of
                    'o' :
                    begin
                         c:=Readkey;
                         case c of
                              'n' :
                              begin
                                   c:=Readkey;
                                   case c of
                                        'e' :
                                        begin
                                             c:=Readkey;
                                             case c of
                                                  'y' :
                                                  begin
                                                       player[currplayer].cash:=player[currplayer].cash+1000;
                                                       SetScreen(0);
                                                  end;
                                             end;
                                        end;
                                   end;
                              end;
                         end;
                    end;
               end;
          end;

          'b' :
          begin
               c:=Readkey;
               if c='l' then
               begin
                    c:=Readkey;
                    if c='a' then
                    begin
                         c:=Readkey;
                         if c='c' then
                         begin
                              c:=Readkey;
                              if c='k' then
                              begin
                                   c:=Readkey;
                                   if c='j' then
                                   begin
                                        c:=Readkey;
                                        if c='a' then
                                        begin
                                             c:=Readkey;
                                             if c='c' then
                                             begin
                                                  c:=Readkey;
                                                  if c='k' then
                                                  begin
                                                       temp2:=(21-player[currplayer].score);
                                                       player[currplayer].downval:=temp2;
                                                       case temp2 of
                                                            1 : temp:='1';
                                                            2 : temp:='2';
                                                            3 : temp:='3';
                                                            4 : temp:='4';
                                                            5 : temp:='5';
                                                            6 : temp:='6';
                                                            7 : temp:='7';
                                                            8 : temp:='8';
                                                            9 : temp:='9';
                                                            10 : temp:='0';
                                                       end;
                                                  end;
                                             end;
                                        end;
                                   end;
                              end;
                         end;
                    end;
               end;
          end;


          '1' :
          begin
               if currcard='A' then
               begin
                    ChangeScore(1);
                    currcard:='N';
               end;
          end;

          '2' :
          begin
               if currcard='A' then
               begin
                    ChangeScore(11);
                    currcard:='N';
               end;
          end;

          'd' : Message('h');

          's' :
          begin
               player[currplayer].done:=true;
               Message('s');
          end;

          'q' : done:=true;

          ' ' :
          begin
               if player[currplayer].downlooked=false then
               begin
                    FlipCard(400,240,1,player[currplayer].downcard);
                    ChangeScore(player[currplayer].downval);
                    player[currplayer].downlooked:=true;
                    Message('c');
                    CheckValue;
               end;
          end;

          'h' : GetHit;
     end;
end;


procedure GetNames;
var a,b : integer;
sa : string;
begin
     cleardevice;
     settextstyle(3,0,3);
     setcolor(6);
     gotoxy(2,5);
     outtextxy(10,30,'Enter The Number Of Players [1-3] :');
     readln(b);
     sound(800);
     delay(50);
     nosound;
     numplayers:=b;
     cleardevice;
     outtextxy(10,30,'Player One Is Dealer');
     setcolor(1);
     outtextxy(10,50,'Press a key');
     setcolor(6);
     Pause;
     sound(800);
     delay(50);
     nosound;
     b:=b+1;
     for a:=2 to b do
     begin
          cleardevice;
          outtextxy(10,30,'Player ');
          str(a,sa);
          outtextxy(80,30,sa);
          outtextxy(100,30,' Enter Your Name : ');
          gotoxy(2,5);
          readln(player[a].name);
          sound(800);
          delay(50);
          nosound;
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

procedure CheckValue;
var a,lastplayer,winner : integer;
begin
     if player[currplayer].score > 21 then
     begin
          player[currplayer].busted:=true;
          player[currplayer].done:=true;
          Message('b');
          Pause;
     end;
end;

procedure ChangeScore(add : integer);
var num : string;
begin
     settextstyle(3,0,5);
     settextjustify(CenterText,CenterText);
     str(player[currplayer].score,num);
     setcolor(0);
     outtextxy(100,100,num);
     player[currplayer].score:=player[currplayer].score+add;
     str(player[currplayer].score,num);
     setcolor(4);
     outtextxy(100,100,num);
end;

procedure SetCards;
var a : integer;
begin
     for a:=1 to 5 do
     begin
          DrawCard(a*100,400,player[currplayer].cards[a]);
     end;
end;

procedure SetScreen(del : integer);
var a : integer;
num : string;
begin
     delay(del);
     cleardevice;
     DrawTable;
     Box(320,100,100,50,15);
     Box(100,100,50,50,15);
     Box(500,100,50,50,15);
     Box(320,20,300,20,15);
     setfillstyle(1,0);
     floodfill(320,100,15);
     floodfill(100,100,15);
     floodfill(500,100,15);
     floodfill(320,20,15);
     settextstyle(3,0,3);
     settextjustify(CenterText,CenterText);
     setcolor(6);
     outtextxy(320,100,player[currplayer].name);
     settextstyle(3,0,5);
     str(player[currplayer].score,num);
     setcolor(4);
     outtextxy(100,100,num);
     settextstyle(3,0,3);
     str(player[currplayer].cash,num);
     setcolor(2);
     outtextxy(500,100,num);
     SetCards;
end;

procedure Deal(dcard : integer);
var temp : char;
begin
     begin
          temp:=GetCard(1);
          if dcard < 0 then
             dealercard:=temp;

          player[currplayer].cards[player[currplayer].cardcount]:=temp;
          player[currplayer].cardcount:=player[currplayer].cardcount+1;
          DrawCard(200,240,temp);
          DrawCard(400,240,player[currplayer].downcard);
          temp:=GetCard(-1);
          player[currplayer].downcard:=temp;
          SetCards;
          Message('d');
     end;
end;

procedure GetHit;
var temp : char;
begin
     begin
          sound(100);
          delay(50);
          nosound;
          temp:=GetCard(1);
          player[currplayer].cards[player[currplayer].cardcount]:=temp;
          player[currplayer].cardcount:=player[currplayer].cardcount+1;
          DrawCard(200,240,'c');
          DrawCard(200,240,temp);
          SetCards;
          CheckValue;
          Message('d');
     end;
end;

procedure DealerAi;
begin
     DrawCard(200,240,dealercard);
     DrawCard(400,240,'b');
     delay(1000);
     FlipCard(400,240,1,player[1].downcard);
     Message('c');
     ChangeScore(player[1].downval);
     player[1].downlooked:=true;
     CheckValue;
     while player[1].score <=17 do
     begin
          delay(500);
          GetHit;
     end;
     done:=true;
end;

procedure Game;
begin
     done:=false;
     currplayer:=1;
     SetScreen(0);
     Deal(-1);
     Pause;
     currplayer:=2;
     while not done do
     begin
          if currplayer > numplayers+1 then currplayer:=1;

          SetScreen(0);

          if currplayer <> 1 then
          begin
               Deal(1);
               while not player[currplayer].done do
                     GetKey;

               Pause;

               currplayer:=currplayer+1;
          end
          else
              DealerAi;
     end;
     EndGame;
end;

procedure StartGame;
var a : integer;
num : string;
begin
     for a:=2 to numplayers+1 do
     begin
          cleardevice;
          settextstyle(3,0,3);
          settextjustify(CenterText,CenterText);
          setcolor(6);
          outtextxy(320,50,player[a].name);
          outtextxy(320,70,'You Have $ ');
          setcolor(2);
          str(player[a].cash,num);
          outtextxy(450,70,num);
          setcolor(3);
          outtextxy(320,100,'How Much Do You Want To Bet?');
          DrawMoney;
          gotoxy(40,15);
          readln(player[a].bet);
          if player[a].bet > player[a].cash then
          begin
               settextstyle(3,0,3);
               setcolor(5);
               outtextxy(320,280,'Your bet is greater than your cash');
               outtextxy(320,320,'Bet set to $100');
               player[a].bet:=100;
               Pause;
          end;
     end;
end;

procedure RestartGame;
begin
     SetPlayers(false);
     StartGame;
     Game;
end;

procedure EndGame;
var a : integer;
c : char;
num : string;
begin
     Pause;
     for a:=2 to numplayers+1 do
     begin
          cleardevice;
          settextstyle(3,0,5);
          settextjustify(CenterText,CenterText);
          setcolor(2);
          if (player[1].busted=false) then
          begin
               if (player[a].busted=false) and (player[a].score > player[1].score) then
               begin
                    outtextxy(320,240,player[a].name);
                    outtextxy(320,280,'Wins Against Dealer');
                    player[a].cash:=player[a].cash*2;
               end
               else if (player[a].busted=true) or (player[a].score < player[1].score) then
               begin
                    outtextxy(320,240,player[a].name);
                    outtextxy(320,280,'Loses To Dealer');
                    player[a].cash:=player[a].cash-player[a].bet;
               end
               else if (player[1].busted=false) and (player[a].score=player[1].score) then
               begin
                    outtextxy(320,240,player[a].name);
                    outtextxy(320,280,'Ties With Dealer');
               end;
          end
          else if (player[1].busted=true) then
          begin
              outtextxy(320,240,player[a].name);
              outtextxy(320,280,'Wins Against Dealer');
              player[a].cash:=player[a].cash+player[1].bet;
          end;
          str(player[a].cash,num);
          settextstyle(3,0,3);
          setcolor(3);
          outtextxy(320,320,'With');
          outtextxy(320,360,num);
          outtextxy(320,400,'Dollars');
          Pause;
     end;
     cleardevice;
     settextstyle(3,0,5);
     settextjustify(CenterText,CenterText);
     setcolor(2);
     outtextxy(320,240,'Play Again [y/n] ?');
     c:=Readkey;
     if c='y' then
        RestartGame;
end;

procedure SetPlayers(cash : boolean);
var a,b : integer;
begin
     hit:=false;
     player[1].name:='Dealer';
     dealercard:='N';
     b:=1;
     for a:=1 to numplayers+1 do
     begin
          if cash=true then
             player[a].cash:=1000;
          player[a].busted:=false;
          player[a].done:=false;
          player[a].downlooked:=false;
          player[a].score:=0;
          player[a].bet:=0;
          player[a].cardcount:=1;
          player[a].downcard:='N';
          for b:=1 to 5 do
          player[a].cards[b]:='N';
     end;
     player[1].bet:=100;
end;

begin
     Randomize;
     gettextsettings(orgsettings);
     SetGraphics;
     TitleScreen;
     GetNames;
     SetPlayers(true);
     StartGame;
     Game;
     closegraph;
end.