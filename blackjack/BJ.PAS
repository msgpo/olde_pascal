program BlackJack;

uses crt,graph,graphbj;

type player=object
     score,bet,cash,cardx,acecount,dval : integer;
     name : string;
     downlooked,done,busted,insured,blackjack : boolean;
     dcard : char;
end;

{Function Prototypes}

procedure Game(var p,dealer : player); forward;
procedure EndGame(var p,dealer : player); forward;
procedure SetPlayer(var p : player; cash : boolean); forward;

function GetMoney(var p : player) : string;
var num : string;
begin
     str(p.cash,num);
     GetMoney:=num;
end;

procedure Message(var p : player; message,card : char);
var str : string;
begin

     setfillstyle(1,0);
     floodfill(350,50,15);
     settextstyle(3,0,3);
     settextjustify(CenterText,CenterText);

     case message of

          'B' :
          begin
               setcolor(4);
               str:=p.name + ' Is Busted!';
          end;

          'C' :
          begin
               setcolor(7);
               str:=p.name + 's Downcard is ';
               case card of
                    '0' : str:=str+'A Ten';
                    '1' : str:=str+'An Ace';
                    '2' : str:=str+'A Deuce';
                    '3' : str:=str+'A Three';
                    '4' : str:=str+'A Four';
                    '5' : str:=str+'A Five';
                    '6' : str:=str+'A Six';
                    '7' : str:=str+'A Seven';
                    '8' : str:=str+'An Eight';
                    '9' : str:=str+'A Nine';
                    'J' : str:=str+'A Jack';
                    'Q' : str:=str+'A Queen';
                    'K' : str:=str+'A King';
               end;
          end;


          'D' :
          begin
               setcolor(1);
               str:=p.name + ' Is Dealt ';
               case card of
                    '1' : str:=str+'An Ace';
                    '2' : str:=str+'A Deuce';
                    '3' : str:=str+'A Three';
                    '4' : str:=str+'A Four';
                    '5' : str:=str+'A Five';
                    '6' : str:=str+'A Six';
                    '7' : str:=str+'A Seven';
                    '8' : str:=str+'An Eight';
                    '9' : str:=str+'A Nine';
                    'J' : str:=str+'A Jack';
                    'Q' : str:=str+'A Queen';
                    'K' : str:=str+'A King';
               end;
          end;

          'I' :
          begin
               setcolor(7);
               str:='Would You Like To Buy Insurance [y/n]?';
          end;

          'J' :
          begin
               setcolor(14);
               str:=p.name + ' Has A BlackJack!';
          end;

          'L' :
          begin
               setcolor(12);
               str:=p.name + ' Loses';
          end;

          'M' :
          begin
               setcolor(2);
               str:=p.name + ' Has $ ' + GetMoney(p);
          end;

          'N' :
          begin
               setcolor(4);
               str:=p.name + ' Is Out Of Money';
          end;

          'O' :
          begin
               setcolor(1);
               str:=p.name +' Doubled Down';
          end;

          'P' :
          begin
               setcolor(6);
               str:=p.name + ' Pushes With Dealer';
          end;

          'S' :
          begin
               setcolor(10);
               str:=p.name + ' Stands';
          end;

          'R' :
          begin
               setcolor(4);
               str:='New Hand [y/n] ?';
          end;

          'U' :
          begin
               setcolor(3);
               str:=p.name + ' Buys Insurance';
          end;

          'W' :
          begin
               setcolor(14);
               str:=p.name + ' Wins!';
          end;

     end;

     outtextxy(350,50,str);

end;

procedure CheckInsurance(var p,dealer : player);
var c : char;
begin
     if dealer.dcard='1' then
     begin
          Message(p,'I','0');
          c:=Readkey;
          if c='y' then
          begin
               Message(p,'U','0');
               p.bet:=p.bet+(p.bet div 2);
               delay(500);
               p.insured:=true;
          end;
     end;
end;

procedure CheckBlackJack(var p : player);
begin
     if (p.acecount > 0) and (p.score=10)  then
     begin
          Message(p,'J','0');
          p.cash:=p.cash+(p.bet*2) + (p.bet div 2);
          p.done:=true;
          p.blackjack:=true;
     end;
end;

procedure ChangeScore(var p : player; add : integer);
var num : string;
begin
     settextstyle(3,0,3);
     settextjustify(CenterText,CenterText);
     setcolor(0);
     str(p.score,num);
     outtextxy(200,150,num);
     p.score:=p.score+add;
     setcolor(9);
     str(p.score,num);
     outtextxy(200,150,num);
end;

procedure CheckValue(var p : player);
begin
     if p.score > 21 then
     begin
          Message(p,'B','0');
          p.busted:=true;
          p.done:=true;
     end;
end;

function GetCard(var p : player; dealer,ace : boolean) : char;
var temp : integer;
    temp2 : char;
begin
     temp:=random(14);

     case temp of
          0 :
          begin
               temp:=10;
               temp2:='0';
          end;

          1 : temp2:='1';
          2 : temp2:='2';
          3 : temp2:='3';
          4 : temp2:='4';
          5 : temp2:='5';
          6 : temp2:='6';
          7 : temp2:='7';
          8 : temp2:='8';
          9 : temp2:='9';
          10 : temp2:='0';
          11 : temp2:='J';
          12 : temp2:='Q';
          13 : temp2:='K';
     end;

     if temp > 10 then temp:=10;

     if not ace then
     begin
          if (not dealer) and (temp2 <> '1') then
             ChangeScore(p,temp)

          else if temp2='1' then
               inc(p.acecount);
     end
     else if (ace) and (not dealer) and (temp2='1') then
         ChangeScore(p,11)
     else if (ace) and (not dealer) and (temp2 <> '1') then
          ChangeScore(p,temp);

     if (dealer) and (temp2 <> '1') then
        p.dval:=temp
     else if (dealer) and (temp2='1') then
          p.dval:=11;

     GetCard:=temp2;
end;

procedure SetScreen;
begin
     {Dealt Card Window}
     Box(40,60,35,55,15);
     Box2(40,60,35,40,55,55,15);

     {Down Card Window}
     Box(40,200,35,55,15);
     Box2(40,200,35,40,55,55,15);

     DrawCard(40,200,'B');

     {Card Window}
     Box2(320,400,320,300,50,50,15);
     Box2(320,400,320,305,50,50,15);

     {Score Window}
     Box(200,150,50,50,15);
     Box2(200,150,50,55,50,50,15);

     {Message Window}
     Box(350,50,250,25,15);
     Box2(350,50,250,255,25,25,15);

     {Dealer Card Windows}
     Box(475,200,35,55,15);
     Box2(475,200,35,40,55,55,15);

     Box(575,200,35,55,15);
     Box2(575,200,35,40,55,55,15);

     settextstyle(3,0,2);
     settextjustify(CenterText,CenterText);
     setcolor(12);
     outtextxy(500,100,'Dealer Cards :');

     DrawCard(575,200,'B');
end;

procedure SetCards(var p : player; newcard : char);
begin
     DrawCard(p.cardx,400,newcard);
     p.cardx:=p.cardx+65;
end;

procedure Deal(var p : player; x,y : integer; dealer,ace : boolean);
var temp : char;
begin
     sound(100);
     delay(50);
     nosound;
     temp:=GetCard(p,dealer,ace);

     if dealer then
        p.dcard:=temp;

     Message(p,'D',temp);

     DrawCard(x,y,'C');
     DrawCard(x,y,temp);

     if not dealer then
        SetCards(p,temp);

     CheckValue(p);
end;

procedure DealerAi(var p : player);
var temp : char;
begin
     delay(500);
     cleardevice;
     SetScreen;
     ChangeScore(p,p.dval);
     DrawCard(475,200,p.dcard);
     SetCards(p,p.dcard);
     delay(500);

     temp:=GetCard(p,false,true);
     FlipCard(575,200,1,temp);
     SetCards(p,temp);
     CheckBlackJack(p);
     CheckValue(p);

     if (p.score >=17) then
     begin
          Message(p,'S','0');
          p.done:=true;
     end;

     delay(500);

     while not p.done do
     begin
          Deal(p,475,200,false,true);
          delay(250);
          if (p.score >=17) and (p.score <= 21) then
          begin
               Message(p,'S','0');
               p.done:=true;
          end;
     end;
end;

procedure GetKey(var p,dealer : player);
var c,temp : char;
begin
     c:=Readkey;

     case c of

          'a' :
          begin
               if p.acecount > 0 then
               begin
                    c:=Readkey;
                    case c of
                         '1' : ChangeScore(p,1);
                         '2' : ChangeScore(p,11);
                    end;
                    CheckValue(p);
                    dec(p.acecount);
               end;
          end;

          'h' : Deal(p,40,60,false,false);

          ' ' :
          begin
               if p.downlooked=false then
               begin
                    temp:=GetCard(p,false,false);
                    FlipCard(40,200,1,temp);
                    SetCards(p,temp);
                    Message(p,'C',temp);
                    CheckValue(p);
                    p.downlooked:=true;
                    CheckBlackJack(p);
               end;
          end;

          's' :
          begin
               Message(p,'S','0');
               delay(250);
               p.done:=true;
          end;

          'd' :
          begin
               Message(p,'O','0');
               p.bet:=p.bet*2;
               delay(500);
               Deal(p,40,60,false,false);
               p.done:=true;
          end;
     end;
end;

procedure RestartGame(p,dealer : player);
begin
     SetPlayer(p,false);
     SetPlayer(dealer,false);
     cleardevice;
     ResetText;
     settextstyle(3,0,3);
     setcolor(2);
     outtextxy(50,50,'Enter Your Bet');
     gotoxy(20,10);
     readln(p.bet);
     cleardevice;
     Game(p,dealer);
end;


procedure StartGame(var p : player);
begin
     Randomize;
     SetGraphics;
     gettextsettings(orgsettings);
     TitleScreen;
     Pause;
     delay(100);
     cleardevice;
     settextstyle(3,0,3);
     setcolor(6);
     outtextxy(50,50,'Enter Your Name');
     gotoxy(20,5);
     readln(p.name);
     setcolor(2);
     outtextxy(50,200,'Enter Your Bet');
     gotoxy(20,15);
     readln(p.bet);
     cleardevice;
end;

procedure Game(var p,dealer : player);
begin
     dealer.name:='Dealer';
     SetScreen;
     delay(250);
     Deal(dealer,475,200,true,true);
     CheckInsurance(p,dealer);
     Deal(p,40,60,false,false);

     while not p.done do
          GetKey(p,dealer);

     DealerAi(dealer);

     delay(750);
     EndGame(p,dealer);
end;


procedure EndGame(var p,dealer : player);
var c : char;
begin
     if (not p.blackjack) and (not dealer.blackjack) then
     begin
        if (dealer.busted) and (not p.busted) then
        begin
             Message(p,'W','0');
             p.cash:=p.cash+p.bet;
        end

        else if (not dealer.busted) and (not p.busted) and (p.score > dealer.score) then
        begin
             Message(p,'W','0');
             p.cash:=p.cash+p.bet;
        end

        else if (p.busted) or (p.score < dealer.score) then
        begin
             Message(p,'L','0');
             p.cash:=p.cash-p.bet;
        end

        else if (p.score=dealer.score) then
             Message(p,'P','0');
     end
     else if (dealer.blackjack) and (not p.blackjack) and (not p.insured) then
     begin
          Message(p,'L','0');
          p.cash:=p.cash-p.bet;
     end
     else if (dealer.blackjack) and (not p.blackjack) and (p.insured) then
     begin
          Message(p,'L','0');
          p.cash:=p.cash-p.bet;
     end;

     delay(900);

     Message(p,'M','0');

     delay(900);

     if p.cash > 0 then
     begin
          Message(p,'R','0');

          c:=Readkey;

          if c='y' then RestartGame(p,dealer);
     end
     else
     begin
          Message(p,'N','0');
          delay(1000);
     end;
end;

procedure SetPlayer(var p : player; cash : boolean);
begin
     p.score:=0;
     if cash then
        p.cash:=1000;
     p.cardx:=40;
     p.dval:=0;
     p.dcard:='N';
     p.done:=false;
     p.busted:=false;
     p.downlooked:=false;
     p.insured:=false;
end;

var dealer,player1 : player;
    dcard : char;

begin
     StartGame(player1);
     SetPlayer(dealer,true);
     SetPlayer(player1,true);
     Game(player1,dealer);
     closegraph;
end.

