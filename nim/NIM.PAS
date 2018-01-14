program Nim;

uses crt,vgraph2,anmunit,mouseunit,buttonunit,pcx,palette;

const
     HOME=0;
     SCHOOL=1;

var
   stick : array[1..17] of pointer; {holds the stick's animations}
   sticks : array[1..3,1..7] of boolean; {true=stick is there; false=sticks is taken}
   hold,frame_counter : array[1..2] of integer; {hold=temp row and col for the mouse; frame_counter=for stick frame changing}
   stick_counter : array[1..3] of integer; {holds the number of sticks in each row left}
   mouse_counter,stick_anm_counter,dissolve_counter,curr_row,turn,scrdelay : integer;
   {mouse_counter=used to change animated sticks in mouse's box}
   {stick_anm_counter=used to change animated sticks on screen}
   {dissolve_counter=used for the dissolving inside the drop-box}
   {curr_row=IMPORTANT, if curr_row=0 then the player's turn has been reset}
   {turn= 0 : computer's turn; 1 : player's turn}
   {scrdelay : screen delay (in UpdateScreen)}
   done,mouse_hold,dissolve,computer_ai : boolean;
   {mouse_hold=is the mouse holding a stick?}
   {dissolve=has the player dropped a stick in the box?}
   {computer_ai=is the computer ai going? (to prevent an infinite loop)}
   temp_grab : array[1..7] of boolean; {tells which sticks are eligable for grabbing}
   last_status,status : string; {hold the stick's status'}
   options : array[1..10] of integer; {options}
   version : integer;

procedure UpdateScreen; forward;
procedure GrabStatus; forward;
function CheckStatus : boolean; forward;
procedure EndGame(loser : integer); forward;

{loads in the animation files and the background}
procedure GetImages;
var loop1 : integer;
begin
     if (version=HOME) then
        Load_anm('sprites\stick.anm')
     else if (version=SCHOOL) then
          Load_anm('h:\students\hansenm_.__\sprites\stick.anm');

     for loop1:=1 to 17 do
     begin
          put_anm(0,0,loop1);
          GetImage2(0,0,16,16,stick[loop1],true);
     end;

     if (version=HOME) then
        LoadScreen('pics\layer2.scr',vaddr2)
     else if (version=SCHOOL) then
          LoadScreen('h:\students\hansenm_.__\pics\layer2.scr',vaddr2);

     cls(vga,0);
end;

{initilizes all the variables and sets up the sticks}
procedure SetupGame;
var loop1,loop2 : integer;
begin
     version:=HOME;

     Randomize;

     for loop1:=1 to 3 do
         for loop2:=1 to 7 do
             sticks[loop1,loop2]:=true;

     sticks[1,4]:=false;
     sticks[1,5]:=false;
     sticks[1,6]:=false;
     sticks[1,7]:=false;
     sticks[2,6]:=false;
     sticks[2,7]:=false;

     stick_counter[1]:=3;
     stick_counter[2]:=5;
     stick_counter[3]:=7;

     mouse_counter:=1;
     frame_counter[1]:=0;
     frame_counter[2]:=0;
     stick_anm_counter:=1;
     dissolve_counter:=9;
     curr_row:=0;
     turn:=1;
     computer_ai:=false;
     dissolve:=false;

     if (version=HOME) then scrdelay:=3;
     if (version=SCHOOL) then scrdelay:=0;

     last_status:=' ';
     status:=' ';

     for loop1:=1 to 7 do
         temp_grab[loop1]:=false;

     GrabStatus;
end;

procedure DrawScreen;
var loop1,loop2,temp_x,temp_y : integer;
begin
     temp_y:=50;
     for loop1:=1 to 3 do
     begin
          temp_x:=50;
          for loop2:=1 to 7 do
          begin
               if (sticks[loop1,loop2]) then
                  PutImage2(temp_x-8,temp_y-8,stick[stick_anm_counter],NormalPut,vaddr);

                  if (frame_counter[1] > 2) then
                  begin
                       frame_counter[1]:=0;
                       Inc(stick_anm_counter);
                       if (stick_anm_counter > 8) then stick_anm_counter:=1;
                  end;

               temp_x:=temp_x+32;
          end;
          temp_y:=temp_y+32;
     end;

     for loop1:=0 to 20 do
         Hline(0,320,loop1,0,vaddr);
     Box(150,185,10,10,4,vaddr);
end;

procedure ComputerGrab(new_x,new_y : integer; grab : boolean);
var inc_x,inc_y : integer;
begin
     inc_x:=3;
     inc_y:=3;

     while not(mouse_x in [new_x-inc_x..new_x+inc_x]) do
     begin
          if (new_x > mouse_x) then mouse_x:=mouse_x+inc_x else mouse_x:=mouse_x-inc_x;
          UpdateScreen;
     end;

     while not(mouse_y in [new_y-inc_y..new_y+inc_y]) do
     begin
          if (new_y > mouse_y) then mouse_y:=mouse_y+inc_y else mouse_y:=mouse_y-inc_y;
          UpdateScreen;
     end;

     mouse_button1:=grab;
end;

procedure ComputerPut(new_x,new_y : integer);
begin
     ComputerGrab(new_x,new_y,true);
     UpdateScreen;
     ComputerGrab(150,177,false);
     UpdateScreen;
end;

procedure DoComputerAi;
var loop1,base_x,base_y,inc,row,counter,counter2 : integer;
    ai_done : boolean;
begin
     GrabStatus;

     row:=0;
     curr_row:=0;
     counter:=0;
     counter2:=-1;
     computer_ai:=true;
     ai_done:=false;
     base_x:=50;
     base_y:=50;
     inc:=32;
     mouse_x:=160;
     mouse_y:=100;
     UpdateScreen;

     for loop1:=1 to 7 do
         temp_grab[loop1]:=false;

     while not(ai_done) do
     begin
           if (counter > 30) then
              for loop1:=1 to 7 do
                  if (sticks[row,loop1]) then
                     counter2:=counter2+1;

           if (counter2=0) then ai_done:=true;

          if (curr_row=0) then
             row:=random(4);

          while (row=0) or (row=4) or (stick_counter[row]<=0) do row:=random(4);

          case row of
               1 : if (stick_counter[1]=3) then
                   begin
                        ComputerPut(base_x+inc,base_y);
                        ai_done:=true;
                   end;

               2 : if (stick_counter[2]=5) then
                   begin
                        ComputerPut(base_x+inc,base_y+inc);
                        ComputerPut(base_x+inc*2,base_y+inc);
                        ComputerPut(base_x+inc*3,base_y+inc);
                        ai_done:=true;
                   end;

               3 : if (stick_counter[3]=7) then
                   begin
                        ComputerPut(base_x,base_y+inc*2);
                        ComputerPut(base_x+inc,base_y+inc*2);
                        ComputerPut(base_x+inc*2,base_y+inc*2);
                        ComputerPut(base_x+inc*3,base_y+inc*2);
                        ai_done:=true;
                   end;
          end;

          if not(ai_done) then
          begin
               if (sticks[row,1]) then
               begin
                    ComputerPut(base_x,base_y+(inc*(row-1)));
                    if not(sticks[row,1]) then
                       ai_done:=true;
               end;

               if not(ai_done) then
               begin
                    if (sticks[row,2]) then
                    begin
                         ComputerPut(base_x,base_y+(inc*(row-1)));
                         if not(sticks[row,2]) then
                            ai_done:=true;
                    end;
               end;

               if (sticks[row,row+1]) then
               begin
                    ComputerPut(base_x,base_y+(inc*(row-1)));
                    if not(sticks[row,row+1]) then
                       ai_done:=true;
               end;

               case row of
                    1 : if (sticks[1,3]) then
                        begin
                             ComputerPut(base_x+inc*2,base_y);
                             if not(sticks[1,3]) then
                                ai_done:=true;
                        end;

                    2 : if (sticks[2,5]) then
                        begin
                             ComputerPut(base_x+inc*4,base_y+inc);
                             if not(sticks[2,5]) then
                                ai_done:=true;
                        end;

                    3 : if (sticks[3,7]) then
                        begin
                             ComputerPut(base_x+inc*6,base_y+inc*2);
                             if not(sticks[3,7]) then
                                ai_done:=true;
                        end;
               end;

               if not(ai_done) then
               begin
                    case row of
                         2 : if (sticks[2,4]) then
                             begin
                                  ComputerPut(base_x+inc*3,base_y+inc);
                                  if not(sticks[2,4]) then
                                     ai_done:=true;
                             end;

                         3 :
                         begin
                              if (sticks[3,5]) then
                              begin
                                   ComputerPut(base_x+inc*4,base_y+inc*2);
                                   if not(sticks[3,5]) then
                                      ai_done:=true;
                              end;

                              if not(ai_done) then
                                 if (sticks[3,6]) then
                                 begin
                                      ComputerPut(base_x+inc*5,base_y+inc*2);
                                      if not(sticks[3,6]) then
                                         ai_done:=true;
                                 end;
                         end;
                    end;
               end;
          end;
          counter2:=counter2+1;
     end;

     if not(CheckStatus) then DoComputerAi;

     if ((stick_counter[1]+stick_counter[2]+stick_counter[3])=0) then
        EndGame(0);


     curr_row:=0;
     computer_ai:=false;
     turn:=1;

     for loop1:=1 to 7 do
         temp_grab[loop1]:=false;

     GrabStatus;
end;

function CheckRules(row,col : integer) : boolean;
begin
     if not(curr_row=0) and not(row=curr_row) then
     begin
          CheckRules:=false;
          exit;
     end;

     if (curr_row=0) then
     begin
          CheckRules:=true;
          exit;
     end
     else
     begin
          CheckRules:=false;
     end;

     if (temp_grab[col]) then
     begin
          CheckRules:=true;
          exit;
     end
     else
     begin
          CheckRules:=false;
          exit;
     end;

     CheckRules:=true;
end;

procedure UpdateMouse;
var loop1,loop2,temp_x,temp_y : integer;
begin
     if (turn=1) then
        getmouse;

     Box2(mouse_x,mouse_y,options[3],options[4],options[5],options[6],options[2],vaddr);

     if (mouse_button1) then
     begin
          if (mouse_hold) then
          begin
               PutImage2(mouse_x-8,mouse_y-8,stick[mouse_counter],NormalPut,vaddr);
               Inc(mouse_counter);
               if (mouse_counter > 5) then mouse_counter:=1;
               exit;
          end;

          if not(mouse_x in [50..255]) and not(mouse_y in [50..134]) then exit;

          temp_y:=50;
          for loop1:=1 to 3 do
          begin
               temp_x:=50;
               for loop2:=1 to 7 do
               begin
                    if (mouse_x in [temp_x-5..temp_x+5]) and (mouse_y in [temp_y-5..temp_y+5]) and
                       (sticks[loop1,loop2]=true) then
                    begin
                         if not(CheckRules(loop1,loop2)) then exit;

                         sticks[loop1,loop2]:=false;
                         temp_grab[loop2]:=true;
                         temp_grab[loop2-1]:=true;
                         temp_grab[loop2+1]:=true;
                         mouse_hold:=true;

                         if (curr_row=0) then
                            curr_row:=loop1;

                         hold[1]:=loop1;
                         hold[2]:=loop2;
                    end;
                    temp_x:=temp_x+32;
               end;
               temp_y:=temp_y+32;
          end
     end
     else
     begin
          if not(mouse_x in [140..160]) and not(mouse_y in [175..195]) then
          begin
               if (mouse_hold) then
               begin
                    sticks[hold[1],hold[2]]:=true;
                    mouse_hold:=false;
               end;
          end
          else
          begin
               if (mouse_hold) then
               begin
                    dissolve:=true;
                    Dec(stick_counter[hold[1]]);
               end;

               mouse_hold:=false;
          end;
     end;

     if (dissolve) then
     begin
          PutImage2(142,177,stick[dissolve_counter],NormalPut,vaddr);

          if (frame_counter[2] > 3) then
          begin
               frame_counter[2]:=0;
               Inc(dissolve_counter);
               if (dissolve_counter > 17) then
               begin
                    dissolve_counter:=9;
                    dissolve:=false;

                    if ((stick_counter[1]+stick_counter[2]+stick_counter[3])=0) then EndGame(turn);
               end;
          end;
     end;
end;

procedure UpdateScreen;
var loop1 : integer;
begin
     flip(vaddr2,vaddr);
     DrawScreen;
     UpdateMouse;

     if (turn=0) and not(computer_ai) then DoComputerAi;

     for loop1:=0 to 198 do
         Move(mem[vaddr2:loop1*320],mem[vaddr2:loop1*320+1],320);

     Inc(frame_counter[1]);

     if (dissolve) then
        Inc(frame_counter[2]);
     flip(vaddr,vga);
     delay(scrdelay);
end;

procedure GrabStatus;
var loop1,loop2 : integer;
begin
     last_status:=' ';

     for loop1:=1 to 3 do
         for loop2:=1 to 7 do
             if (sticks[loop1,loop2]) then last_status:=last_status+'1'
             else last_status:=last_status+'0';
end;

function CheckStatus : boolean;
var loop1,loop2 : integer;
begin
     status:=' ';

     for loop1:=1 to 3 do
         for loop2:=1 to 7 do
             if (sticks[loop1,loop2]) then status:=status+'1'
             else status:=status+'0';

     if (status=last_status) then
        CheckStatus:=false
     else CheckStatus:=true;

end;

procedure GetKey;
var c : char;
begin
     done:=false;

     while not(done) do
     begin
          if (keypressed) then
          begin
               c:=Readkey;

               case c of
                    'd' : if (CheckStatus) then
                          begin
                               turn:=0;
                               curr_row:=0;
                               computer_ai:=false;
                          end;

                    #27 : done:=true;
               end;
          end;

          UpdateScreen;
     end;
end;

procedure EndGame(loser : integer);
begin
     cls(vga,0);

     if (loser=0) then
        if (version=HOME) then
           ReadPcx('pics\win.pcx',0,0,vaddr)
        else if (version=SCHOOL) then
             ReadPcx('h:\students\hansenm_.__\pics\win.pcx',0,0,vaddr)
     else
         if (version=HOME) then
            ReadPcx('pics\lose.pcx',0,0,vaddr)
         else if (version=SCHOOL) then
              ReadPcx('h:\students\hansenm_.__\pics\lose.pcx',0,0,vaddr);

     flip(vaddr,vga);
     Pause;
     done:=true;
end;

procedure DoOptions;
var loop1 : integer;
    stick1,stick2 : pointer;
begin
     if (version=HOME) then
        SetupButtons('sprites\buttons.anm')
     else if (version=SCHOOL) then
          SetupButtons('h:\stundets\hansenm_.__\sprites\buttons.anm');

     if (version=HOME) then
        Load_anm('sprites\stick.anm')
     else if (version=SCHOOL) then
          Load_anm('h:\students\hansenm_.__\sprites\stick.anm');

     put_anm(0,0,1);
     GetImage2(0,0,16,16,stick1,true);

     if (version=HOME) then
        Load_anm('sprites\stick2.anm')
     else if (version=SCHOOL) then
          Load_anm('h:\students\hansenm_.__\sprites\stick2.anm');

     put_anm(0,0,1);
     GetImage2(0,0,16,16,stick2,true);

     InitButton(200,80,9,9,1);
     InitButton(200,100,9,9,2);
     InitButton(220,90,9,9,3);
     InitButton(180,90,9,9,4);

     InitButton(200,140,9,9,2);
     InitButton(200,160,9,9,1);
     InitButton(220,150,9,9,4);
     InitButton(180,150,9,9,3);

     InitButton(100,90,9,9,1);
     InitButton(100,110,9,9,2);

     InitButton(60,20,9,9,5);
     InitButton(60,40,9,9,6);

     while not(keypressed) do
     begin
          flip(vaddr2,vaddr);

          GetMouse;
          for loop1:=0 to 20 do
              Hline(0,320,loop1,0,vaddr);

          DrawButtons(vaddr);

          Box2(mouse_x,mouse_y,options[3],options[4],options[5],options[6],options[2],vaddr);
          putpixel(mouse_x,mouse_y,4,vaddr);

          Box(90,30,10,10,15,vaddr);

          if (options[1]=1) then
             PutImage2(83,23,stick1,NormalPut,vaddr)
          else PutImage2(83,23,stick2,NormalPut,vaddr);

          if (CheckButton(200,80)) then Inc(options[5]);
          if (CheckButton(200,100)) then Inc(options[6]);
          if (CheckButton(220,90)) then Inc(options[4]);
          if (CheckButton(180,90)) then Inc(options[3]);

          if (CheckButton(200,140)) then Dec(options[5]);
          if (CheckButton(200,160)) then Dec(options[6]);
          if (CheckButton(220,150)) then Dec(options[4]);
          if (CheckButton(180,150)) then Dec(options[3]);

          if (CheckButton(100,90)) then Inc(options[2]);
          if (CheckButton(100,110)) then Dec(options[2]);

          if (CheckButton(60,20)) then options[1]:=1;
          if (CheckButton(60,40)) then options[1]:=2;

          for loop1:=0 to 198 do
              Move(mem[vaddr2:loop1*320],mem[vaddr2:loop1*320+1],320);

          flip(vaddr,vga);
     end;

     if not(options[1]=1) then
        for loop1:=1 to 17 do
        begin
             put_anm(0,0,loop1);
             GetImage2(0,0,16,16,stick[loop1],true);
        end;
end;

procedure StartGame;
var c : char;
    r : integer;
begin
     InitMouse;
     HideMouse;
     GetImages;
     Randomize;

     options[1]:=1;
     options[2]:=2;
     options[3]:=10;
     options[4]:=10;
     options[5]:=10;
     options[6]:=10;

     if (version=HOME) then
        ReadPcx('pics\nim.pcx',0,0,vaddr)
     else if (version=SCHOOL) then
          ReadPcx('h:\students\hansenm_.__\pics\nim.pcx',0,0,vaddr);

     flip(vaddr,vga);

     c:=Readkey;

     if (version=HOME) then
     begin
          r:=random(6);

          case r of
               0 : IncColor(1,1,1,5);
               1 : IncColor(1,1,0,5);
               2 : IncColor(1,0,0,5);
               3 : IncColor(0,1,1,5);
               4 : IncColor(0,0,1,5);
               5 : IncColor(0,1,0,5);
               6 : IncColor(1,0,1,5);
          end;

          FadeDown(10);
          BlackOut;
          cls(vga,0);
          RestorePalette(pal1);
     end;

     if (c='o') then
        DoOptions;
end;

begin
     Setup;
     StartGame;
     SetupGame;
     GetKey;
     ShutDown;
end.

