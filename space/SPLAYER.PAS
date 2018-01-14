unit splayer;

interface

uses crt,vgraph,palette;

type missile=object
     x,y,dir : integer;
     active : boolean;
end;

type ship=object
     x,y,dir : integer;
     counter,scounter,speed,mspeed,maxspeed,mcounter : integer;
     energy,weapon,mweapon,htarget,score,shield : integer;
     fire,inert,shielded,dead : boolean;
     upkey,downkey,leftkey,rightkey,actionkey,switchkey : char;
     action : char;
     missiles : array[1..20] of missile;
end;

type powup=object
     frame : array[1..4] of pointer;
     x,y,ptype,counter : integer;
     on : boolean;
end;

var
   players : integer;
   numdead,scrdelay,ai_player,ai_target,ai_counter,stcounter,ai_x,ai_y : integer;
   done,ai,stuff : boolean;
   stchar : array[1..5] of char;
   player : array[1..4] of ship;
   sprite : array[1..20] of pointer;
   sframe : array[1..20] of pointer;
   powerup : powup;

procedure CheckPos(p : integer);
procedure CheckPowerPos;
procedure UpdatePlayer;
procedure UpdatePowerup;
procedure UpdatePlayerFire;
procedure UpdateEnergy;
procedure RestartGame;
procedure EndGame(p : integer);
procedure UpdateScreen;
procedure RunAi;
procedure SetUpAi(p : integer);

implementation

procedure RestartGame;
var loop1 : integer;
begin
     for loop1:=1 to players do
     begin
          player[loop1].x:=random(160)+20;
          player[loop1].y:=random(130)+50;
          player[loop1].dir:=3;
          player[loop1].weapon:=1;
          player[loop1].energy:=5;
          player[loop1].mspeed:=4;
          player[loop1].maxspeed:=4;
          player[loop1].mweapon:=1;
          player[loop1].mcounter:=0;
          player[loop1].fire:=false;
          player[loop1].dead:=false;
          player[loop1].action:='F';
     end;
     numdead:=0;
     UpdateScreen;
     FadeUp(10);
end;

procedure EndGame(p : integer);
var loop1 : integer;
begin
     Inc(numdead);
     UpdateScreen;
     for loop1:=1 to 4 do
     begin
          PutImage2(player[p].x-8,player[p].y-8,sprite[loop1+4],NormalPut,vga);
          delay(40);
     end;
     IncColor(0,0,1,1);
     DecColor(0,0,1,1);
     if (numdead=players) then
        done:=true
     else if (numdead=(players-1)) then
     begin
          FadeDown(10);
          RestartGame;
     end;
end;

procedure CheckPos(p : integer);
var loop1,loop2 : integer;
begin
     for loop1:=1 to players do
     begin
          for loop2:=1 to 20 do
          begin
               if (player[p].missiles[loop2].x in [player[loop1].x-8..player[loop1].x+8]) and
                  (player[p].missiles[loop2].y in [player[loop1].y-8..player[loop1].y+8]) and
                  (player[p].missiles[loop2].active) then
               begin
                    if (player[loop1].energy > 0) and (not player[loop1].shielded) and (player[loop1].energy > 0) then
                    begin
                         Dec(player[loop1].energy);
                         player[p].missiles[loop2].active:=false;
                    end;
                    if (player[loop1].energy <=0) then
                    begin
                         if (not player[loop1].dead) then
                         begin
                              player[loop1].dead:=true;
                              Inc(player[p].score);
                              EndGame(loop1);
                         end;
                    end;
               end;
          end;
     end;
end;

procedure CheckPowerPos;
var loop1,temp : integer;
begin
     if not powerup.on then exit;

     for loop1:=1 to players do
     begin
          if (player[loop1].x in [powerup.x-8..powerup.x+8]) and (player[loop1].y in [powerup.y-8..powerup.y+8]) then
          begin
               IncColor(1,1,1,0);
               DecColor(1,1,1,0);
               case powerup.ptype of
                    1 : Inc(player[loop1].energy);

                    2 :
                    begin
                         if not(loop1=ai_player) then
                         begin
                              repeat
                                    temp:=random(players)+1;
                              until (temp <> loop1) and not(player[temp].dead);
                              if player[temp].energy > 0 then
                                 Dec(player[temp].energy);
                              if player[temp].energy <=0 then
                                 EndGame(temp);
                         end;
                    end;

                    3 :
                    begin
                         Inc(player[loop1].mspeed);
                         Inc(player[loop1].maxspeed);
                    end;

                    4 : if player[loop1].weapon < 3 then
                        begin
                             Inc(player[loop1].weapon);
                             Inc(player[loop1].mweapon);
                        end;
               end;
               powerup.on:=false;
          end;
     end;
end;

procedure UpdatePowerup;
begin
     inc(powerup.counter);

     if not powerup.on then
     begin
          if powerup.counter > 200 then
          begin
               powerup.x:=random(160)+20;
               powerup.y:=random(130)+50;
               powerup.on:=true;
               powerup.ptype:=random(4)+1;
               powerup.counter:=0;
          end;
     end
     else
         PutImage2(powerup.x-8,powerup.y-8,sprite[powerup.ptype+12],NormalPut,vaddr);
end;

procedure UpdatePlayer;
var loop1 : integer;
begin
     for loop1:=1 to players do
     begin
          if player[loop1].counter > 20 then
          begin
               Dec(player[loop1].speed);
               player[loop1].counter:=0;
          end;

          if player[loop1].speed <=0 then
          begin
               player[loop1].inert:=false;
               player[loop1].dir:=3;
          end;

          if player[loop1].scounter > 100 then
             player[loop1].shielded:=false;

          case player[loop1].dir of
               1 : if player[loop1].y > 35 then player[loop1].y:=player[loop1].y-player[loop1].speed;
               2 : if player[loop1].y < 170 then player[loop1].y:=player[loop1].y+player[loop1].speed;
               3 : if player[loop1].x < 300 then player[loop1].x:=player[loop1].x+player[loop1].speed;
               4 : if player[loop1].x > 20 then player[loop1].x:=player[loop1].x-player[loop1].speed;
          end;

          if (player[loop1].energy > 0) and (not player[loop1].shielded) then
             PutImage2(player[loop1].x-8,player[loop1].y-8,sframe[((loop1*4)-4)+player[loop1].dir],NormalPut,vaddr)
          else if player[loop1].shielded then
               PutImage2(player[loop1].x-8,player[loop1].y-8,sframe[player[loop1].dir+16],NormalPut,vaddr);

          if player[loop1].inert then
             Inc(player[loop1].counter);
          if player[loop1].shielded then
             Inc(player[loop1].scounter);

     end;
end;

procedure UpdatePlayerFire;
var loop1,loop2 : integer;
begin
     for loop1:=1 to players do
     begin
          if (player[loop1].dead) then continue;

          for loop2:=1 to 20 do
          begin
               if (player[loop1].fire) and (player[loop1].missiles[loop2].x < 310)
                  and (player[loop1].missiles[loop2].x > 5) and
                      (player[loop1].missiles[loop2].y > 30) and (player[loop1].missiles[loop2].y < 170)
                  and (player[loop1].missiles[loop2].active) then
               begin
                    case player[loop1].weapon of
                         1 :
                         begin
                              case player[loop1].missiles[loop2].dir of
                                   1 : player[loop1].missiles[loop2].y:=player[loop1].missiles[loop2].y-5;
                                   2 : player[loop1].missiles[loop2].y:=player[loop1].missiles[loop2].y+5;
                                   3 : player[loop1].missiles[loop2].x:=player[loop1].missiles[loop2].x+5;
                                   4 : player[loop1].missiles[loop2].x:=player[loop1].missiles[loop2].x-5;
                              end;
                              PutImage2(player[loop1].missiles[loop2].x-8,player[loop1].missiles[loop2].y-8,
                                  sprite[player[loop1].missiles[loop2].dir],NormalPut,vaddr);
                         end;

                         2 :
                         begin
                              case player[loop1].dir of
                                   1 : player[loop1].missiles[loop2].y:=player[loop1].missiles[loop2].y-5;
                                   2 : player[loop1].missiles[loop2].y:=player[loop1].missiles[loop2].y+5;
                                   3 : player[loop1].missiles[loop2].x:=player[loop1].missiles[loop2].x+5;
                                   4 : player[loop1].missiles[loop2].x:=player[loop1].missiles[loop2].x-5;
                              end;

                              PutImage2(player[loop1].missiles[loop2].x-8,player[loop1].missiles[loop2].y-8,
                                 sprite[player[loop1].dir],NormalPut,vaddr);
                         end;

                         3 :
                         begin
                              if (player[loop1].missiles[loop2].x < player[player[loop1].htarget].x) then
                                 player[loop1].missiles[loop2].x:=player[loop1].missiles[loop2].x+5;
                              if (player[loop1].missiles[loop2].x > player[player[loop1].htarget].x) then
                                 player[loop1].missiles[loop2].x:=player[loop1].missiles[loop2].x-5;
                              if (player[loop1].missiles[loop2].y < player[player[loop1].htarget].y) then
                                 player[loop1].missiles[loop2].y:=player[loop1].missiles[loop2].y+5;
                              if (player[loop1].missiles[loop2].y > player[player[loop1].htarget].y) then
                                 player[loop1].missiles[loop2].y:=player[loop1].missiles[loop2].y-5;

                                 PutImage2(player[loop1].missiles[loop2].x-8,player[loop1].missiles[loop2].y-8,
                                   sprite[player[loop1].missiles[loop2].dir],NormalPut,vaddr);
                         end;
                    end;
               end
               else
                   player[loop1].missiles[loop2].active:=false;
          end;
     end;
end;

procedure UpdateEnergy;
var loop1,loop2,ex,temp : integer;
begin
     for loop1:=1 to players do
     begin
          if player[loop1].energy <=0 then continue;

          if (loop1=1) then
             ex:=10
          else
              ex:=(10+((loop1-1)*80));
          for loop2:=1 to player[loop1].energy do
          begin
               PutImage2(ex-8,5,sprite[9],NormalPut,vaddr);
               ex:=ex+6;
          end;

          case player[loop1].action of
               'F' : temp:=1;
               'S' : temp:=2;
               'W' : temp:=3;
               's' : temp:=4;
          end;

          PutImage2(ex+8,5,sprite[16+temp],NormalPut,vaddr);

          if (loop1=1) then
             ex:=10
          else
              ex:=(10+((loop1-1)*80));
          for loop2:=1 to player[loop1].score do
          begin
               PutImage2(ex-8,15,sprite[10],NormalPut,vaddr);
               ex:=ex+6;
          end;

          if (loop1=1) then
             ex:=10
          else
              ex:=(10+((loop1-1)*80));
          for loop2:=1 to player[loop1].shield do
          begin
               PutImage2(ex-8,187,sprite[11],NormalPut,vaddr);
               ex:=ex+6;
          end;
     end;
end;

procedure UpdateScreen;
var loop1 : integer;
begin
     flip(vaddr2,vaddr);

     for loop1:=1 to players do
         CheckPos(loop1);

     CheckPowerPos;
     UpdatePowerup;
     UpdatePlayerFire;
     UpdatePlayer;
     UpdateEnergy;

     line(1,24,319,24,6,vaddr);
     line(1,185,319,185,6,vaddr);

     flip(vaddr,vga);

     for loop1:=0 to 198 do
         Move(mem[vaddr2:loop1*320],mem[vaddr2:loop1*320+1],320);

     delay(scrdelay);
end;

procedure SetupAi(p : integer);
begin
     inc(players);
     ai:=true;
     ai_player:=p;
     player[ai_player].upkey:='[';
     player[ai_player].downkey:=']';
     player[ai_player].rightkey:='{';
     player[ai_player].leftkey:='}';
     player[ai_player].actionkey:='|';
     player[ai_player].switchkey:='\';

     ai_x:=player[ai_player].x;
     ai_y:=player[ai_player].y;

     repeat
           ai_target:=random(players)+1;
     until (ai_target<>ai_player) and not(player[ai_target].dead);
end;

procedure StuffKey(keys : integer; key1,key2 : char);
begin
     stuff:=true;
     stcounter:=keys;
     stchar[1]:=key1;
     stchar[2]:=key2;
end;

procedure RunAi;
var tx,ty,px,py : integer;
begin
     if (player[ai_target].dead) then
        repeat
              ai_target:=random(players)+1;
        until (ai_target<>ai_player) and not(player[ai_target].dead);

     tx:=player[ai_target].x;
     ty:=player[ai_target].y;
     px:=player[ai_player].x;
     py:=player[ai_player].y;

     if not(powerup.on) or (powerup.ptype=3) then
     begin

          if (tx > px) and ((tx-px) > 20) then
          begin
               player[ai_player].dir:=3;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;

          if (tx < px) and ((px-tx) > 20) then
          begin
               player[ai_player].dir:=4;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;

          if (ty > py) and ((ty-py) > 20) then
          begin
               player[ai_player].dir:=2;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;

          if (ty < py) and ((py-ty) > 20) then
          begin
               player[ai_player].dir:=1;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;
     end
     else
     begin
          if (powerup.x > px) and not(px in [powerup.x-8..powerup.x+8]) then
          begin
               player[ai_player].dir:=3;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;

          if (powerup.x < px) and not(px in [powerup.x-8..powerup.x+8]) then
          begin
               player[ai_player].dir:=4;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;

          if (powerup.y > py) and not(py in [powerup.y-8..powerup.y+8]) then
          begin
               player[ai_player].dir:=2;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;

          if (powerup.y < py) and not(py in [powerup.y-8..powerup.y+8]) then
          begin
               player[ai_player].dir:=1;
               player[ai_player].inert:=true;
               player[ai_player].speed:=player[ai_player].mspeed;
          end;
     end;

     if (player[ai_player].energy <=2) and (player[ai_player].shield > 0) and not(player[ai_player].shielded) then
     begin
          player[ai_player].shielded:=true;
          player[ai_player].scounter:=0;
          Dec(player[ai_player].shield);
     end;

     if (ai_counter > 10) then
     begin
          StuffKey(1,'|','|');
          ai_counter:=0;
     end;

end;

end.





