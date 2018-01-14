program SpaceFighters;

uses crt,vgraph,palette,pcx,anmunit,splayer;

procedure GetImages;
var loop1 : integer;
begin
     cls(vga,0);
     Load_anm('sprites\ships.anm');

     for loop1:=1 to 16 do
     begin
          put_anm(0,0,loop1);
          GetImage2(0,0,16,16,sframe[loop1],true);
     end;

     for loop1:=16 to 20 do
     begin
          put_anm(0,0,loop1);
          GetImage2(0,0,16,16,sframe[loop1],true);
     end;

     Load_anm('sprites\missile.anm');

     for loop1:=1 to 4 do
     begin
          put_anm(0,0,loop1);
          GetImage2(0,0,16,16,sprite[loop1],true);
     end;

     Load_anm('sprites\explode.anm');

     for loop1:=5 to 8 do
     begin
          put_anm(0,0,loop1-4);
          GetImage2(0,0,16,16,sprite[loop1],true);
     end;

     Load_anm('sprites\icons.anm');

     for loop1:=9 to 12 do
     begin
          put_anm(0,0,loop1-8);
          GetImage2(0,0,16,16,sprite[loop1],true);
     end;

     for loop1:=17 to 21 do
     begin
          put_anm(0,0,loop1-13);
          GetImage2(0,0,16,16,sprite[loop1],true);
     end;

     Load_anm('sprites\powerups.anm');

     for loop1:=13 to 16 do
     begin
          put_anm(0,0,loop1-12);
          GetImage2(0,0,16,16,sprite[loop1],true);
     end;

     Load_anm('sprites\ships.anm');
     put_anm(0,0,1);
     GetImage2(0,0,16,16,sframe[1],true);

     cls(vga,0);
end;

procedure StartGame;
var loop1,loop2 : integer;
    c : char;
begin
     randomize;
     clrscr;
     writeln('Enter the number of players : ');
     readln(players);

     if (players < 4) then
     begin
          writeln('Would you like a computer player [y/n]?');
          c:=Readkey;

          if (c='y') then
             SetUpAi(players+1);
     end;

     for loop1:=1 to players do
     begin
          player[loop1].x:=random(160)+20;
          player[loop1].y:=random(130)+50;
          player[loop1].dir:=3;
          player[loop1].weapon:=1;
          player[loop1].energy:=5;
          player[loop1].shield:=3;
          player[loop1].mspeed:=4;
          player[loop1].maxspeed:=4;
          player[loop1].mweapon:=1;
          player[loop1].mcounter:=1;
          player[loop1].score:=0;
          player[loop1].fire:=false;
          player[loop1].dead:=false;
          player[loop1].action:='F';

          for loop2:=1 to 20 do
              player[loop1].missiles[loop2].active:=false;
     end;
end;

procedure GetKey;
var loop1,loop2,temp : integer;
    c : char;
begin
     done:=false;
     while not done do
     begin
          if keypressed then
          begin
               if not(stuff) then
                  c:=Readkey
               else
               begin
                    c:=stchar[stcounter];
                    Dec(stcounter);
                    if (stcounter<=0) then stuff:=false;
               end;

               for loop1:=1 to players do
               begin
                    if (c=player[loop1].upkey) then
                    begin
                         player[loop1].dir:=1;
                         player[loop1].inert:=true;
                         player[loop1].speed:=player[loop1].mspeed;
                    end;

                    if (c=player[loop1].downkey) then
                    begin
                         player[loop1].dir:=2;
                         player[loop1].inert:=true;
                         player[loop1].speed:=player[loop1].mspeed;
                    end;

                    if (c=player[loop1].rightkey) then
                    begin
                         player[loop1].dir:=3;
                         player[loop1].inert:=true;
                         player[loop1].speed:=player[loop1].mspeed;
                    end;

                    if (c=player[loop1].leftkey) then
                    begin
                         player[loop1].dir:=4;
                         player[loop1].inert:=true;
                         player[loop1].speed:=player[loop1].mspeed;
                    end;

                    if (c=player[loop1].switchkey) then
                    begin
                         case player[loop1].action of
                              'F' : player[loop1].action:='S';
                              'S' : player[loop1].action:='W';
                              'W' : player[loop1].action:='s';
                              's' : player[loop1].action:='F';
                         end;
                    end;

                    if (c=player[loop1].actionkey) then
                    begin
                         case player[loop1].action of

                              {Firing}
                              'F' :
                              begin

                                   for loop2:=1 to 20 do
                                       if not(player[loop1].missiles[loop2].active) then temp:=loop2;

                                   player[loop1].missiles[temp].active:=true;
                                   player[loop1].missiles[temp].dir:=player[loop1].dir;

                                   repeat
                                         player[loop1].htarget:=random(players)+1;
                                   until (player[loop1].htarget<>loop1) and not(player[player[loop1].htarget].dead);

                                   player[loop1].missiles[temp].x:=player[loop1].x;
                                   player[loop1].missiles[temp].y:=player[loop1].y;

                                   case player[loop1].dir of
                                        1 : player[loop1].missiles[temp].y:=player[loop1].y-15;
                                        2 : player[loop1].missiles[temp].y:=player[loop1].y+15;
                                        3 : player[loop1].missiles[temp].x:=player[loop1].x+15;
                                        4 : player[loop1].missiles[temp].x:=player[loop1].x-15;
                                   end;

                                   if (player[loop1].weapon=3) then
                                   begin
                                        if (player[player[loop1].htarget].x > player[loop1].x) then
                                           player[loop1].missiles[temp].x:=player[loop1].x+15;

                                        if (player[player[loop1].htarget].x < player[loop1].x) then
                                           player[loop1].missiles[temp].x:=player[loop1].x-15;

                                        if (player[player[loop1].htarget].y > player[loop1].y) then
                                           player[loop1].missiles[temp].y:=player[loop1].y+15;

                                        if (player[player[loop1].htarget].y > player[loop1].y) then
                                           player[loop1].missiles[temp].y:=player[loop1].y-15;
                                   end;

                                      Inc(player[loop1].mcounter);
                                      player[loop1].fire:=true;
                              end;


                              {Shielding}
                              'S' :
                              begin
                                   if (player[loop1].shield > 0) then
                                   begin
                                        Dec(player[loop1].shield);
                                        player[loop1].shielded:=true;
                                        player[loop1].scounter:=0;
                                   end;
                              end;

                              {Switching Speed}
                              's' :
                              begin
                                   if (player[loop1].mspeed=player[loop1].maxspeed) then
                                      player[loop1].mspeed:=3
                                   else
                                       Inc(player[loop1].mspeed);
                              end;

                              {Switching Weapons}
                              'W' :
                              begin
                                   if (player[loop1].weapon=player[loop1].mweapon) then
                                      player[loop1].weapon:=1
                                   else
                                       Inc(player[loop1].weapon);
                              end;
                         end;
                    end;

                    if (c=#27) then done:=true;
               end;
          end;

          if (ai) then
          begin
               inc(ai_counter);
               RunAi;
          end;

          UpdateScreen;
     end;
end;

procedure GetKeys;
var loop1 : integer;
begin
     for loop1:=1 to players do
     begin
          if (ai) and (loop1=players) then break;
          writeln('Player ',loop1,' enter your upkey : ');
          player[loop1].upkey:=Readkey;
          writeln('Player ',loop1,' enter your downkey : ');
          player[loop1].downkey:=Readkey;
          writeln('Player ',loop1,' enter your rightkey : ');
          player[loop1].rightkey:=Readkey;
          writeln('Player ',loop1,' enter your leftkey : ');
          player[loop1].leftkey:=Readkey;
          writeln('Player ',loop1,' enter your actionkey : ');
          player[loop1].actionkey:=Readkey;
          writeln('Player ',loop1,' enter your switchkey : ');
          player[loop1].switchkey:=Readkey;
     end;
end;

begin
     scrdelay:=8;
     ai:=false;
     stcounter:=0;
     StartGame;
     GetKeys;
     Setup;
     GetImages;
     LoadScreen('pics\layer2.scr',vaddr2);
     GetKey;
     ShutDown;
end.
